import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/patient_reading.dart';
import 'package:vital_step/Model/research_patient.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/services/patient_service.dart';

class PatientSessionViewModel extends BaseViewModel {
  final _patientService = locator<PatientService>();
  final _modeService = locator<ModeService>();
  final _navigationService = locator<NavigationService>();

  ResearchPatient? patient;
  List<PatientReading> readings = [];

  Future<void> init() async {
    if (!_modeService.hasActivePatient) return;
    setBusy(true);
    try {
      patient = await _patientService.getPatient(_modeService.activePatientId!);
      readings =
          await _patientService.getReadings(_modeService.activePatientId!);
    } catch (e) {
      // show error toast
      Fluttertoast.showToast(msg: 'Unable to load patient data');
    } finally {
      setBusy(false);
    }
  }

  Future<void> takeTest() async {
    // Navigate to assessment selection. After test completes, TestResultViewModel
    // automatically dual-writes to both Digital Ocean and patient Supabase.
    // When user presses back from test result, they return here (patientSessionView).
    await _navigationService.navigateTo(Routes.assesmentView);
    // Refresh readings after returning from a test session
    await _refreshReadings();
  }

  Future<void> _refreshReadings() async {
    if (!_modeService.hasActivePatient) return;
    try {
      readings =
          await _patientService.getReadings(_modeService.activePatientId!);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteReading(String readingId) async {
    try {
      await _patientService.deleteReading(readingId);
      readings.removeWhere((r) => r.id == readingId);
      notifyListeners();
      Fluttertoast.showToast(msg: 'Reading deleted');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete reading');
    }
  }

  void viewHistory() {
    _navigationService.navigateTo(Routes.patientHistoryView);
  }

  void editPatient() {
    _navigationService.navigateTo(Routes.patientEditView);
  }

  int get failedRetryCount {
    try {
      final box = GetStorage();
      final queueJson = box.read<String>('patient_readings_retry_queue');
      if (queueJson == null || queueJson.isEmpty) return 0;
      final queue = jsonDecode(queueJson) as List;
      return queue
          .where((item) => (item['attemptCount'] as int? ?? 0) >= 5)
          .length;
    } catch (_) {
      return 0;
    }
  }

  bool get hasFailedRetries => failedRetryCount > 0;

  /// Exports the patient's readings as a CSV and opens the Android/iOS
  /// share sheet so the user can send it via Gmail, WhatsApp, Drive, etc.
  Future<void> exportCSV() async {
    if (patient == null) return;
    setBusy(true);
    try {
      final csv = await _patientService.exportCSV(patient!.id);

      // Write to the app's temporary cache directory
      final dir = await getTemporaryDirectory();
      final fileName =
          '${patient!.patientCode}_${DateTime.now().toIso8601String().substring(0, 10)}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csv, flush: true);

      // Open the share sheet — user picks Gmail, WhatsApp, Drive, etc.
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv', name: fileName)],
        subject:
            'Grip Strength Data — ${patient!.name} (${patient!.patientCode})',
        text:
            'Please find the grip strength assessment data for ${patient!.name} attached.',
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Export failed. Please try again.');
    } finally {
      setBusy(false);
    }
  }
}
