import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vital_step/app/app.logger.dart';

/// Pushes patient registration and test reading data to HubSpot CRM
/// via the VitalStep backend.
///
/// Two-endpoint strategy (based on API schema analysis):
///
///   • Registration → POST /api/v1/hubspot/contacts (primary)
///       Uses HubSpotContactCreate schema which correctly stores
///       gender, condition, device_id, age, dominant_hand.
///       Falls back to POST /sync/contact if /contacts fails (e.g. phone too
///       short, 422 validation, or any other error). The fallback still
///       creates the contact, just without device_id/gender/condition.
///       On 409 (contact already exists) → patches clinical fields via PATCH.
///
///   • Test Reading → POST /api/v1/hubspot/sync/contact
///       Uses HubSpotContactSync which correctly stores all trial fields
///       (trial1/2/3, average_trial, left/right_trial_1/2/3, left/right_avg,
///       posture, test_date). Gender/condition/device_id are persisted from
///       the registration step.
///
/// All calls are fire-and-forget (non-blocking) — failures are logged
/// but never surface to the user.
class HubSpotService {
  final _logger = getLogger('HubSpotService');

  static const String _baseUrl =
      'https://vitalstep.onrender.com/api/v1/hubspot';

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: split "First Last" → firstname + lastname
  // ─────────────────────────────────────────────────────────────────────────

  static Map<String, String> _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return {'firstname': parts[0], 'lastname': ''};
    }
    return {
      'firstname': parts.first,
      'lastname': parts.sublist(1).join(' '),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: find HubSpot contact ID by searching firstname + patient_code
  // ─────────────────────────────────────────────────────────────────────────

  Future<String?> _findContactId(String firstname, String patientCode) async {
    try {
      final uri = Uri.parse('$_baseUrl/contacts').replace(
          queryParameters: {'search': firstname, 'limit': '50'});
      final response =
          await http.get(uri).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;

      final list = jsonDecode(response.body) as List<dynamic>;
      for (final item in list) {
        if (item['patient_code'] == patientCode) {
          return item['id']?.toString();
        }
      }
      return null;
    } catch (e) {
      _logger.w('HubSpot _findContactId error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: PATCH an existing contact with clinical fields
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _patchContact(
      String contactId, Map<String, dynamic> fields) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_baseUrl/contacts/$contactId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(fields),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('HubSpot PATCH contact $contactId OK');
      } else {
        _logger.w('HubSpot PATCH contact $contactId FAILED '
            '${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.w('HubSpot _patchContact error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: normalize phone — strip spaces/dashes, ensure at least 10 digits
  // ─────────────────────────────────────────────────────────────────────────

  /// Normalizes phone by stripping non-digit/+ chars.
  /// Returns null if the result has fewer than 10 digits (backend minimum).
  static String? _normalizePhone(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    // Keep leading + and digits only
    final cleaned = raw.replaceAll(RegExp(r'[^\d+]'), '');
    // Count digits only
    final digitCount = cleaned.replaceAll('+', '').length;
    if (digitCount < 10) return null;
    return cleaned;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sync patient registration to HubSpot
  // ─────────────────────────────────────────────────────────────────────────

  /// Called after a patient is registered.
  ///
  /// Primary: POST /contacts — stores gender, condition, device_id.
  /// Fallback: POST /sync/contact — if /contacts fails for any reason.
  Future<void> syncPatient({
    required String name,
    required String patientCode,
    required String deviceId,
    String? phone,
    String? email,
    int? age,
    String? gender,
    String? dominantHand,
    String? condition,
    String? dob,
  }) async {
    try {
      final effectivePhone = _normalizePhone(phone);
      final effectiveEmail = (email != null && email.isNotEmpty) ? email : null;
      final nameParts = _splitName(name);

      _logger.i(
          'HubSpot syncPatient: $patientCode | phone=$effectivePhone '
          'gender=$gender condition=$condition device_id=$deviceId');

      // ── 1. Require Phone ─────────────────────────────────────────────────
      if (effectivePhone == null) {
        _logger.w(
            'HubSpot syncPatient: SKIPPED for $patientCode — '
            'no valid phone number provided. '
            'Patient is saved in Supabase but NOT synced to HubSpot. '
            'Ensure phone is captured in the registration form.');
        return;
      }

      // ── 2. Primary: POST /contacts ───────────────────────────────────────
      final payload = <String, dynamic>{
        'firstname': nameParts['firstname']!,
        'lastname': nameParts['lastname']!,
        'phone': effectivePhone,
        if (effectiveEmail != null) 'email': effectiveEmail,
        'patient_code': patientCode,
        'device_id': deviceId,
        if (age != null) 'age': age,
        'gender': (gender != null && gender.isNotEmpty) ? gender : 'Unknown',
        'dominant_hand': (dominantHand != null && dominantHand.isNotEmpty)
            ? dominantHand
            : '',
        'condition':
            (condition != null && condition.isNotEmpty) ? condition : 'None',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/contacts'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.i('HubSpot /contacts OK — id: ${json['id']} '
            'gender: ${json['gender']} condition: ${json['condition']}');
        return; // ← Success, done
      } else if (response.statusCode == 409) {
        _logger.i('HubSpot: contact exists for $patientCode — patching');
        final contactId = await _findContactId(nameParts['firstname']!, patientCode);
        if (contactId != null) {
          await _patchContact(contactId, {
            'device_id': deviceId,
            if (age != null) 'age': age,
            'gender': (gender != null && gender.isNotEmpty) ? gender : 'Unknown',
            if (dominantHand != null && dominantHand.isNotEmpty)
              'dominant_hand': dominantHand,
            'condition': (condition != null && condition.isNotEmpty)
                ? condition
                : 'None',
          });
        }
        return; // ← Handled via patch
      } else {
        _logger.w('HubSpot POST /contacts FAILED '
            '${response.statusCode}: ${response.body} — trying /sync/contact fallback');
      }

      // ── 3. Fallback: POST /sync/contact ──────────────────────────────────
      // If the primary endpoint fails (e.g. 500 error from HubSpot backend),
      // try the secondary sync endpoint which is more lenient.
      final fallbackResponse = await http
          .post(
            Uri.parse('$_baseUrl/sync/contact'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'phone': effectivePhone,
              if (effectiveEmail != null) 'email': effectiveEmail,
              'patient_code': patientCode,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (fallbackResponse.statusCode == 200) {
        final json = jsonDecode(fallbackResponse.body) as Map<String, dynamic>;
        _logger.i(
            'HubSpot /sync/contact fallback OK — ${json['status']} id: ${json['hubspot_id']}');
        
        final hid = json['hubspot_id']?.toString();
        if (hid != null) {
          await _patchContact(hid, {
            'device_id': deviceId,
            if (age != null) 'age': age,
            'gender': (gender != null && gender.isNotEmpty) ? gender : 'Unknown',
            if (dominantHand != null && dominantHand.isNotEmpty)
              'dominant_hand': dominantHand,
            'condition': (condition != null && condition.isNotEmpty) ? condition : 'None',
          });
        }
      } else {
        _logger.w('HubSpot /sync/contact fallback also FAILED '
            '${fallbackResponse.statusCode}: ${fallbackResponse.body}');
      }
    } catch (e) {
      _logger.e('HubSpot syncPatient exception: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sync test reading to HubSpot
  // ─────────────────────────────────────────────────────────────────────────

  /// Called after a test result is saved.
  /// Uses POST /sync/contact which correctly stores all trial fields.
  Future<void> syncTestReading({
    required String name,
    required String patientCode,
    String? phone,
    String? email,
    required double trial1,
    required double trial2,
    required double trial3,
    required String hand,
    required String posture,
    required DateTime testDate,
    String? deviceId,
    int? age,
    String? gender,
    String? dominantHand,
    String? condition,
    String? dob,
  }) async {
    try {
      final effectivePhone = _normalizePhone(phone);
      final effectiveEmail = (email != null && email.isNotEmpty) ? email : null;

      if (effectivePhone == null) {
        _logger.w(
            'HubSpot reading sync: phone missing/invalid for $patientCode — skipping');
        return;
      }

      final avg = (trial1 + trial2 + trial3) / 3;
      final isLeft = hand.toLowerCase() == 'left';

      final payload = <String, dynamic>{
        'name': name,
        'phone': effectivePhone,
        if (effectiveEmail != null) 'email': effectiveEmail,
        'patient_code': patientCode,
        // Trials — /sync/contact uses trial1 (no underscore)
        'trial1': trial1,
        'trial2': trial2,
        'trial3': trial3,
        'average_trial': avg,
        'posture': posture,
        'hand': hand,
        'test_date': testDate.toIso8601String(),
        // Hand-specific fields
        if (isLeft) 'left_trial_1': trial1,
        if (isLeft) 'left_trial_2': trial2,
        if (isLeft) 'left_trial_3': trial3,
        if (isLeft) 'left_avg': avg,
        if (!isLeft) 'right_trial_1': trial1,
        if (!isLeft) 'right_trial_2': trial2,
        if (!isLeft) 'right_trial_3': trial3,
        if (!isLeft) 'right_avg': avg,
      };

      _logger.i('HubSpot syncTestReading: $hand for $patientCode | '
          'trials: $trial1/$trial2/$trial3 avg: ${avg.toStringAsFixed(2)}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/sync/contact'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.i(
            'HubSpot reading sync OK — ${json['status']} id: ${json['hubspot_id']}');
      } else {
        _logger.w('HubSpot /sync/contact reading FAILED '
            '${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.e('HubSpot syncTestReading exception: $e');
    }
  }
}
