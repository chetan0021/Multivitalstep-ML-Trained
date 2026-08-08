import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/research_patient.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/services/patient_service.dart';

class PatientSearchViewModel extends BaseViewModel {
  final _patientService = locator<PatientService>();
  final _modeService = locator<ModeService>();
  final _navigationService = locator<NavigationService>();

  List<ResearchPatient> searchResults = [];
  String searchQuery = '';
  Timer? _debounceTimer;

  Future<void> init() async {
    await _loadRecentPatients();
  }

  Future<void> _loadRecentPatients() async {
    setBusy(true);
    try {
      searchResults = await _patientService.searchPatients('');
    } catch (e) {
      searchResults = [];
    } finally {
      setBusy(false);
    }
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      setBusy(true);
      try {
        searchResults = await _patientService.searchPatients(query);
      } catch (e) {
        searchResults = [];
      } finally {
        setBusy(false);
        notifyListeners();
      }
    });
  }

  Future<void> selectPatient(ResearchPatient patient) async {
    final _dialogService = locator<DialogService>();
    final response = await _dialogService.showConfirmationDialog(
      title: 'Select Patient',
      description:
          'Start a session for ${patient.name} (${patient.patientCode})?\n\nAll tests taken will be recorded under this patient.',
      confirmationTitle: 'Start Session',
      cancelTitle: 'Cancel',
      barrierDismissible: true,
    );
    if (response == null || !response.confirmed) return;

    _modeService.setActivePatient(
      patientId: patient.id,
      patientCode: patient.patientCode,
      patientName: patient.name,
    );
    _modeService.setPatientMode(true);
    _navigationService.navigateTo(Routes.patientSessionView);
  }

  void navigateToRegistration() {
    _navigationService.navigateTo(Routes.patientRegistrationView);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
