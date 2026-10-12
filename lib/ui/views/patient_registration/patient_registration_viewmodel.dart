import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/patient_transfer_objects.dart';
import 'package:vital_step/Model/research_patient.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/services/patient_service.dart';

class PatientRegistrationViewModel extends BaseViewModel {
  final _patientService = locator<PatientService>();
  final _modeService = locator<ModeService>();
  final _navigationService = locator<NavigationService>();

  // ── Basic fields ──────────────────────────────────────────────────────────
  String name = '';
  String ageText = '';
  String gender = '';
  String phone = '';
  String email = '';
  String condition = 'None';
  String conditionOther = ''; // used when condition == 'Other'
  String notes = '';

  /// The value actually saved — if 'Other' is selected, uses the typed text.
  String get effectiveCondition =>
      condition == 'Other' ? conditionOther.trim() : condition;

  // ── Clinical fields (same as sign-up) ────────────────────────────────────
  String dominantHand = '';
  String heightText = '';
  String weightText = '';
  String palmLengthText = '';
  String palmWidthText = '';
  String knuckleLengthText = '';
  DateTime? dob;
  final TextEditingController dobController = TextEditingController();
  bool passwordVisible = false;

  // ── State ─────────────────────────────────────────────────────────────────
  ResearchPatient? registeredPatient;
  String? nameError;
  String? ageError;
  String? genderError;
  String? errorMessage;

  void setDOB(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dob = picked;
      dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      notifyListeners();
    }
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate() {
    nameError = null;
    ageError = null;
    genderError = null;
    bool valid = true;

    if (name.trim().isEmpty || name.length > 100) {
      nameError = name.trim().isEmpty
          ? 'Name is required'
          : 'Name must be 100 characters or less';
      valid = false;
    }
    final age = int.tryParse(ageText);
    if (age == null || age < 0 || age > 150) {
      ageError = 'Age must be between 0 and 150';
      valid = false;
    }
    if (gender.isEmpty) {
      genderError = 'Gender is required';
      valid = false;
    }
    notifyListeners();
    return valid;
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> register() async {
    if (!_validate()) return;
    setBusy(true);
    errorMessage = null;
    try {
      final data = PatientRegistrationData(
        name: name.trim(),
        age: int.parse(ageText),
        gender: gender,
        phone: phone.trim(),
        email: email.trim(),
        condition: effectiveCondition,
        notes: notes.trim(),
        dob: dob != null ? DateFormat('yyyy-MM-dd').format(dob!) : null,
        dominantHand: dominantHand.isNotEmpty ? dominantHand : null,
        height: int.tryParse(heightText),
        weight: int.tryParse(weightText),
        palmLength: double.tryParse(palmLengthText),
        palmWidth: double.tryParse(palmWidthText),
        knuckleLength: double.tryParse(knuckleLengthText),
      );
      registeredPatient = await _patientService.registerPatient(data);
      _modeService.setActivePatient(
        patientId: registeredPatient!.id,
        patientCode: registeredPatient!.patientCode,
        patientName: registeredPatient!.name,
      );
      notifyListeners();
    } catch (e) {
      errorMessage = 'Registration failed: ${e.toString()}';
      Fluttertoast.showToast(
        msg: errorMessage!,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void confirmAndNavigate() {
    _navigationService.clearStackAndShow(Routes.patientSessionView);
  }

  @override
  void dispose() {
    dobController.dispose();
    super.dispose();
  }
}
