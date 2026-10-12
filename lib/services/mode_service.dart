import 'package:get_storage/get_storage.dart';

/// Manages Host/Patient mode selection and Active Patient state.
/// Persisted via GetStorage so mode survives app restarts.
///
/// Key schema:
///   'app_mode'              → bool   (false = Host_Mode [default], true = Patient_Mode)
///   'active_patient_id'     → String (UUID of selected ResearchPatient)
///   'active_patient_code'   → String (e.g., "PT-0042")
///   'active_patient_name'   → String (patient display name)
class ModeService {
  final _box = GetStorage();

  static const String _modeKey = 'app_mode';
  static const String _activePatientIdKey = 'active_patient_id';
  static const String _activePatientCodeKey = 'active_patient_code';
  static const String _activePatientNameKey = 'active_patient_name';

  /// True when in Patient Mode, false when in Host Mode (default).
  bool get isPatientMode => _box.read<bool>(_modeKey) ?? false;

  /// True when in Host Mode (default behavior).
  bool get isHostMode => !isPatientMode;

  /// Switch modes. Clearing active patient when switching back to Host Mode.
  void setPatientMode(bool value) {
    _box.write(_modeKey, value);
    if (!value) clearActivePatient();
  }

  // ── Active Patient ──────────────────────────────────────────────────────

  /// UUID of the currently selected ResearchPatient (null if none selected).
  String? get activePatientId => _box.read<String>(_activePatientIdKey);

  /// Patient code string, e.g., "PT-0042".
  String? get activePatientCode => _box.read<String>(_activePatientCodeKey);

  /// Patient display name.
  String? get activePatientName => _box.read<String>(_activePatientNameKey);

  /// True when a patient is currently selected in Patient Mode.
  bool get hasActivePatient =>
      activePatientId != null && activePatientId!.isNotEmpty;

  /// Set the active patient for the current session.
  void setActivePatient({
    required String patientId,
    required String patientCode,
    required String patientName,
  }) {
    _box.write(_activePatientIdKey, patientId);
    _box.write(_activePatientCodeKey, patientCode);
    _box.write(_activePatientNameKey, patientName);
  }

  /// Clear the active patient (e.g., when switching to Host Mode or logging out).
  void clearActivePatient() {
    _box.remove(_activePatientIdKey);
    _box.remove(_activePatientCodeKey);
    _box.remove(_activePatientNameKey);
  }
}
