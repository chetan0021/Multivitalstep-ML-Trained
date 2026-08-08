import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/research_patient.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/main.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/services/patient_service.dart';

class PatientEditViewModel extends BaseViewModel {
  final _patientService = locator<PatientService>();
  final _modeService = locator<ModeService>();
  final _navigationService = locator<NavigationService>();

  ResearchPatient? patient;
  String name = '';
  String ageText = '';
  String gender = '';
  String contact = '';
  String notes = '';
  String? nameError;
  String? ageError;
  String? genderError;

  Future<void> init() async {
    if (!_modeService.hasActivePatient) return;
    setBusy(true);
    try {
      patient = await _patientService.getPatient(_modeService.activePatientId!);
      if (patient != null) {
        name = patient!.name;
        ageText = patient!.age.toString();
        gender = patient!.gender;
        contact = patient!.contact;
        notes = patient!.notes;
        notifyListeners();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Unable to load patient data');
    } finally {
      setBusy(false);
    }
  }

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

  Future<void> saveChanges() async {
    if (!_validate() || patient == null) return;
    setBusy(true);
    try {
      await patientSupabaseClient
          .from('research_patients')
          .update({
            'name': name.trim(),
            'age': int.parse(ageText),
            'gender': gender,
            'contact': contact.trim(),
            'notes': notes.trim(),
          })
          .eq('id', patient!.id)
          .eq('host_user_id', patient!.hostUserId);
      Fluttertoast.showToast(msg: 'Patient updated successfully');
      _navigationService.back();
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Update failed. Please check your connection and try again.');
    } finally {
      setBusy(false);
    }
  }
}
