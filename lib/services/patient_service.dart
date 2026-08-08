import 'dart:async';
import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vital_step/Model/patient_reading.dart';
import 'package:vital_step/Model/patient_transfer_objects.dart';
import 'package:vital_step/Model/research_patient.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/main.dart';
import 'package:vital_step/services/hubspot_service.dart';
import 'package:vital_step/services/login_service.dart';

/// Service for managing research patients and their readings in the New Supabase Project.
/// Uses [patientSupabaseClient] (initialized in main.dart) for all database operations.
class PatientService {
  final _logger = getLogger('PatientService');
  final _box = GetStorage();
  final SupabaseClient _client = patientSupabaseClient;

  /// GetStorage key for the retry queue (JSON-serialised list of pending readings).
  ///
  /// Each item in the queue is a JSON map with the following structure:
  /// ```json
  /// {
  ///   "patientId":      "uuid",
  ///   "hostUserId":     "123",
  ///   "trial1":         "25.5",
  ///   "trial2":         "26.0",
  ///   "trial3":         "24.8",
  ///   "hand":           "Right",
  ///   "posture":        "Seated",
  ///   "assessmentType": "42",
  ///   "createdAt":      "2024-01-15T10:30:00.000Z",
  ///   "enqueuedAt":     "2024-01-15T10:30:01.000Z",
  ///   "attemptCount":   0,
  ///   "nextRetryAt":    "2024-01-15T10:30:03.000Z"
  /// }
  /// ```
  ///
  /// Exponential back-off schedule (Req 11.4):
  ///   Attempt 1 → 2 s delay
  ///   Attempt 2 → 4 s delay
  ///   Attempt 3 → 8 s delay
  ///   Attempt 4 → 16 s delay
  ///   Attempt 5 → 32 s delay
  ///   After attempt 5 → permanently failed; item removed from queue; user notified (Req 11.5)
  static const String _retryQueueKey = 'patient_readings_retry_queue';
  static const int _maxRetryAttempts = 5;
  static const List<int> _retryDelaysSeconds = [2, 4, 8, 16, 32];

  // ──────────────────────────────────────────────────────────────────────────
  // 5.1 — Get Next Patient Code
  // ──────────────────────────────────────────────────────────────────────────

  /// Queries the research_patients table for the highest numeric suffix under
  /// the given [hostUserId], increments it, and returns a zero-padded code.
  /// Returns "PT-0001" if no patients exist yet.
  /// Retries up to 3 times on failure with a 1-second delay between attempts.
  Future<String> getNextPatientCode(String hostUserId) async {
    int attempt = 0;
    const maxAttempts = 3;

    while (attempt < maxAttempts) {
      try {
        _logger.i(
            'Fetching next patient code for hostUserId=$hostUserId (attempt ${attempt + 1})');

        // Query for all patient codes for this host, order by code descending
        final response = await _client
            .from('research_patients')
            .select('patient_code')
            .eq('host_user_id', hostUserId)
            .order('patient_code', ascending: false)
            .limit(1);

        if (response.isEmpty) {
          _logger.i('No existing patients, starting at PT-0001');
          return 'PT-0001';
        }

        final String lastCode = response.first['patient_code'] as String;
        _logger.i('Last patient code: $lastCode');

        // Extract numeric suffix (e.g., "PT-0042" → 42)
        final numericPart = lastCode.replaceFirst('PT-', '');
        final lastNumber = int.tryParse(numericPart) ?? 0;
        final nextNumber = lastNumber + 1;

        if (nextNumber > 9999) {
          _logger.e('Patient code overflow: exceeded PT-9999');
          throw Exception('Maximum patient code limit reached (PT-9999)');
        }

        final nextCode = 'PT-${nextNumber.toString().padLeft(4, '0')}';
        _logger.i('Generated next code: $nextCode');
        return nextCode;
      } catch (e) {
        attempt++;
        _logger.e('Failed to get next patient code (attempt $attempt): $e');

        if (attempt >= maxAttempts) {
          _logger.e('Max retry attempts reached for getNextPatientCode');
          rethrow;
        }

        // Wait 1 second before retry
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // Fallback (should never reach here due to rethrow above)
    throw Exception(
        'Failed to generate patient code after $maxAttempts attempts');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5.2 — Register Patient
  // ──────────────────────────────────────────────────────────────────────────

  /// Validates input lengths, retrieves hostUserId from LoginService,
  /// generates next patient code, and inserts into research_patients.
  /// Retries with next code on unique constraint violation (race condition).
  Future<ResearchPatient> registerPatient(PatientRegistrationData data) async {
    _logger.i('Registering patient: ${data.name}');

    // Validate field lengths
    if (data.name.trim().isEmpty || data.name.length > 100) {
      throw ArgumentError('Name must be 1-100 characters');
    }
    if (data.phone.length > 20) {
      throw ArgumentError('Phone must be 20 characters or less');
    }
    if (data.email.length > 100) {
      throw ArgumentError('Email must be 100 characters or less');
    }
    if (data.notes.length > 500) {
      throw ArgumentError('Notes must be 500 characters or less');
    }
    if (data.age < 0 || data.age > 150) {
      throw ArgumentError('Age must be between 0 and 150');
    }

    // Get hostUserId from LoginService
    final hostUserId = await locator<LoginService>().getUserId();
    if (hostUserId == null || hostUserId.isEmpty) {
      throw Exception('No user logged in');
    }

    // Try up to 3 times in case of code collision (rare race condition)
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        // Generate next patient code
        final patientCode = await getNextPatientCode(hostUserId);

        // Insert into research_patients (include all clinical fields if provided)
        final insertData = <String, dynamic>{
          'patient_code': patientCode,
          'name': data.name.trim(),
          'age': data.age,
          'gender': data.gender,
          'phone': data.phone.trim(),
          'email': data.email.trim(),
          'condition': data.condition,
          'notes': data.notes.trim(),
          'host_user_id': hostUserId,
          if (data.dob != null) 'dob': data.dob,
          if (data.dominantHand != null) 'dominant_hand': data.dominantHand,
          if (data.height != null) 'height': data.height,
          if (data.weight != null) 'weight': data.weight,
          if (data.palmLength != null) 'palm_length': data.palmLength,
          if (data.palmWidth != null) 'palm_width': data.palmWidth,
          if (data.knuckleLength != null) 'knuckle_length': data.knuckleLength,
        };

        _logger.i('Inserting patient with code $patientCode');
        final response = await _client
            .from('research_patients')
            .insert(insertData)
            .select()
            .single();

        _logger.i('Patient registered successfully: ${response['id']}');
        final registered = ResearchPatient.fromJson(response);

        // Non-blocking HubSpot sync — fires after successful registration
        _syncPatientToHubSpot(registered, data, hostUserId);

        return registered;
      } catch (e) {
        attempts++;
        _logger.e('Failed to register patient (attempt $attempts): $e');

        // Check if it's a unique constraint violation (code collision)
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('unique') ||
            errorMessage.contains('duplicate')) {
          _logger
              .w('Patient code collision detected, retrying with next code...');
          if (attempts < maxAttempts) {
            continue; // Retry with next code
          }
        }

        // If not a collision or max attempts reached, rethrow
        rethrow;
      }
    }

    throw Exception('Failed to register patient after $maxAttempts attempts');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HubSpot Sync (non-blocking)
  // ──────────────────────────────────────────────────────────────────────────

  /// Fires a non-blocking HubSpot contact sync after patient registration.
  /// Uses `data` (form input) directly — not the Supabase response object —
  /// to avoid any field mapping or default value issues.
  void _syncPatientToHubSpot(ResearchPatient patient,
      PatientRegistrationData data, String hostUserId) {
    final hubspot = locator<HubSpotService>();
    hubspot
        .syncPatient(
      name: data.name.trim(),
      patientCode: patient.patientCode,
      deviceId: hostUserId,
      phone: data.phone.isNotEmpty ? data.phone : null,
      email: data.email.isNotEmpty ? data.email : null,
      age: data.age,
      // Read gender directly from form data — guaranteed to have the user input
      gender: data.gender.isNotEmpty ? data.gender : null,
      dominantHand: (data.dominantHand != null && data.dominantHand!.isNotEmpty)
          ? data.dominantHand
          : null,
      // condition is always non-empty from the form (defaults to "None")
      condition: data.condition.isNotEmpty ? data.condition : 'None',
      dob: data.dob,
    )
        .catchError((e) {
      _logger.e('HubSpot sync error (ignored): $e');
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5.3 — Search Patients
  // ──────────────────────────────────────────────────────────────────────────

  /// Searches research_patients filtered by host_user_id.
  /// If [query] is non-empty, filters by patient_code or name (case-insensitive).
  /// Returns up to 20 results, ordered by created_at desc.
  Future<List<ResearchPatient>> searchPatients(String query) async {
    try {
      final hostUserId = await locator<LoginService>().getUserId();
      if (hostUserId == null || hostUserId.isEmpty) {
        throw Exception('No user logged in');
      }

      _logger
          .i('Searching patients for hostUserId=$hostUserId, query="$query"');

      var queryBuilder = _client
          .from('research_patients')
          .select()
          .eq('host_user_id', hostUserId);

      // Apply search filter if query is non-empty
      if (query.trim().isNotEmpty) {
        final searchTerm = query.trim();
        // Use ilike for case-insensitive pattern matching
        // Search in both patient_code and name using OR logic
        queryBuilder = queryBuilder.or(
          'patient_code.ilike.%$searchTerm%,name.ilike.%$searchTerm%',
        );
      }

      final response =
          await queryBuilder.order('created_at', ascending: false).limit(20);

      _logger.i('Found ${response.length} patients');
      return response.map((json) => ResearchPatient.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Failed to search patients: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5.4 — Get Patient
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetches a single patient by ID.
  /// Returns null if not found.
  Future<ResearchPatient?> getPatient(String patientId) async {
    try {
      _logger.i('Fetching patient: $patientId');

      final response = await _client
          .from('research_patients')
          .select()
          .eq('id', patientId)
          .maybeSingle();

      if (response == null) {
        _logger.w('Patient not found: $patientId');
        return null;
      }

      return ResearchPatient.fromJson(response);
    } catch (e) {
      _logger.e('Failed to get patient: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5.5 — Save Reading
  // ──────────────────────────────────────────────────────────────────────────

  /// Inserts a new reading into patient_readings.
  Future<void> saveReading(PatientReadingData data) async {
    try {
      _logger.i('Saving reading for patient: ${data.patientId}');

      await _client.from('patient_readings').insert(data.toJson());

      _logger.i('Reading saved successfully');
    } catch (e) {
      _logger.e('Failed to save reading: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5.6 — Get Readings
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetches all readings for a given patient, ordered by created_at desc.
  Future<List<PatientReading>> getReadings(String patientId) async {
    try {
      _logger.i('Fetching readings for patient: $patientId');

      final response = await _client
          .from('patient_readings')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      _logger.i('Found ${response.length} readings');
      return response.map((json) => PatientReading.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Failed to get readings: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5.6b — Delete Reading
  // ──────────────────────────────────────────────────────────────────────────

  /// Deletes a single reading by its UUID from patient_readings.
  Future<void> deleteReading(String readingId) async {
    try {
      _logger.i('Deleting reading: $readingId');
      await _client.from('patient_readings').delete().eq('id', readingId);
      _logger.i('Reading deleted: $readingId');
    } catch (e) {
      _logger.e('Failed to delete reading: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5.7 — Retry Queue Management
  // ──────────────────────────────────────────────────────────────────────────

  /// Adds a failed reading to the retry queue.
  void enqueueReading(PatientReadingData data) {
    try {
      final queue = _getRetryQueue();

      final queueItem = {
        'patientId': data.patientId,
        'hostUserId': data.hostUserId,
        'trial1': data.trial1,
        'trial2': data.trial2,
        'trial3': data.trial3,
        'hand': data.hand,
        'posture': data.posture,
        'assessmentType': data.assessmentType,
        'createdAt': data.createdAt.toIso8601String(),
        'enqueuedAt': DateTime.now().toIso8601String(),
        'attemptCount': 0,
        'nextRetryAt': DateTime.now()
            .add(Duration(seconds: _retryDelaysSeconds[0]))
            .toIso8601String(),
      };

      queue.add(queueItem);
      _saveRetryQueue(queue);

      _logger.i('Reading enqueued for retry (queue size: ${queue.length})');
    } catch (e) {
      _logger.e('Failed to enqueue reading: $e');
    }
  }

  /// Processes all items in the retry queue using exponential backoff.
  /// Items that fail all 5 attempts are removed and logged.
  Future<void> processRetryQueue() async {
    try {
      final queue = _getRetryQueue();
      if (queue.isEmpty) {
        _logger.i('Retry queue is empty');
        return;
      }

      _logger.i('Processing retry queue (${queue.length} items)');

      final remainingQueue = <Map<String, dynamic>>[];

      for (final item in queue) {
        final attemptCount = item['attemptCount'] as int;
        final nextRetryAt = DateTime.parse(item['nextRetryAt'] as String);

        // Check if it's time to retry this item
        if (DateTime.now().isBefore(nextRetryAt)) {
          remainingQueue.add(item);
          continue;
        }

        // Try to save the reading
        try {
          final data = PatientReadingData(
            patientId: item['patientId'] as String,
            hostUserId: item['hostUserId'] as String,
            trial1: item['trial1'] as String,
            trial2: item['trial2'] as String,
            trial3: item['trial3'] as String,
            hand: item['hand'] as String,
            posture: item['posture'] as String,
            assessmentType: item['assessmentType'] as String,
            createdAt: DateTime.parse(item['createdAt'] as String),
          );

          await saveReading(data);
          _logger
              .i('Successfully retried reading for patient ${data.patientId}');
          // Success — don't add back to queue
        } catch (e) {
          final newAttemptCount = attemptCount + 1;

          if (newAttemptCount >= _maxRetryAttempts) {
            _logger.e(
                'Reading failed after $newAttemptCount attempts, removing from queue: $e');
            // Remove from queue (don't add to remainingQueue)
            // TODO: Could trigger a persistent notification here
          } else {
            // Re-enqueue with updated attempt count and next retry time
            final delay = _retryDelaysSeconds[newAttemptCount];
            item['attemptCount'] = newAttemptCount;
            item['nextRetryAt'] =
                DateTime.now().add(Duration(seconds: delay)).toIso8601String();
            remainingQueue.add(item);
            _logger.w(
                'Reading retry failed (attempt $newAttemptCount), will retry in ${delay}s: $e');
          }
        }
      }

      _saveRetryQueue(remainingQueue);
      _logger.i(
          'Retry queue processed (${remainingQueue.length} items remaining)');
    } catch (e) {
      _logger.e('Failed to process retry queue: $e');
    }
  }

  List<Map<String, dynamic>> _getRetryQueue() {
    try {
      final queueJson = _box.read<String>(_retryQueueKey);
      if (queueJson == null || queueJson.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(queueJson) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      _logger.e('Failed to read retry queue: $e');
      return [];
    }
  }

  void _saveRetryQueue(List<Map<String, dynamic>> queue) {
    try {
      _box.write(_retryQueueKey, jsonEncode(queue));
    } catch (e) {
      _logger.e('Failed to save retry queue: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5.8 — CSV Export
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetches patient and all readings, generates CSV string with header:
  /// Patient_Code,Name,Age,Gender,Contact,Test_Date,Hand,Posture,Trial_1_Kg,Trial_2_Kg,Trial_3_Kg,Average_Kg
  /// One row per reading.
  Future<String> exportCSV(String patientId) async {
    try {
      _logger.i('Exporting CSV for patient: $patientId');

      // Fetch patient
      final patient = await getPatient(patientId);
      if (patient == null) {
        throw Exception('Patient not found');
      }

      // Fetch readings
      final readings = await getReadings(patientId);

      // Build CSV
      final buffer = StringBuffer();

      // Header row
      buffer.writeln(
        'Patient_Code,Name,Age,Gender,Phone,Email,Condition,Test_Date,Hand,Posture,Trial_1_Kg,Trial_2_Kg,Trial_3_Kg,Average_Kg',
      );

      // Data rows
      for (final reading in readings) {
        final testDate = _formatDateTime(reading.createdAt);
        final average = reading.average.toStringAsFixed(2);

        buffer.writeln(
          '${_escapeCsvField(patient.patientCode)},'
          '${_escapeCsvField(patient.name)},'
          '${patient.age},'
          '${_escapeCsvField(patient.gender)},'
          '${_escapeCsvField(patient.phone)},'
          '${_escapeCsvField(patient.email)},'
          '${_escapeCsvField(patient.condition)},'
          '$testDate,'
          '${_escapeCsvField(reading.hand)},'
          '${_escapeCsvField(reading.posture)},'
          '${reading.trial1.toStringAsFixed(2)},'
          '${reading.trial2.toStringAsFixed(2)},'
          '${reading.trial3.toStringAsFixed(2)},'
          '$average',
        );
      }

      _logger.i('CSV export complete (${readings.length} rows)');
      return buffer.toString();
    } catch (e) {
      _logger.e('Failed to export CSV: $e');
      rethrow;
    }
  }

  String _formatDateTime(DateTime dt) {
    // Format as YYYY-MM-DD HH:MM:SS
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  String _escapeCsvField(String field) {
    // Escape fields containing commas, quotes, or newlines
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
