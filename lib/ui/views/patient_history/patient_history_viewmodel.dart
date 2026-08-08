import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/patient_reading.dart';
import 'package:vital_step/Model/research_patient.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/services/patient_service.dart';

class PatientHistoryViewModel extends BaseViewModel {
  final _patientService = locator<PatientService>();
  final _modeService = locator<ModeService>();

  ResearchPatient? patient;
  List<PatientReading> readings = [];
  List<FlSpot> leftSpots = [];
  List<FlSpot> rightSpots = [];

  Future<void> init() async {
    if (!_modeService.hasActivePatient) return;
    setBusy(true);
    try {
      patient = await _patientService.getPatient(_modeService.activePatientId!);
      readings =
          await _patientService.getReadings(_modeService.activePatientId!);
      _buildChartData();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Unable to load history');
    } finally {
      setBusy(false);
    }
  }

  Future<void> refresh() async {
    try {
      readings =
          await _patientService.getReadings(_modeService.activePatientId!);
      _buildChartData();
      notifyListeners();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Unable to refresh history');
    }
  }

  Future<void> deleteReading(String readingId) async {
    try {
      await _patientService.deleteReading(readingId);
      readings.removeWhere((r) => r.id == readingId);
      _buildChartData();
      notifyListeners();
      Fluttertoast.showToast(msg: 'Reading deleted');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete reading');
    }
  }

  void _buildChartData() {
    // Get chronological lists (oldest first) for trend display
    final leftReadings =
        readings.where((r) => r.hand == 'Left').toList().reversed.toList();
    final rightReadings =
        readings.where((r) => r.hand == 'Right').toList().reversed.toList();

    leftSpots = leftReadings
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.average))
        .toList();
    rightSpots = rightReadings
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.average))
        .toList();
  }

  bool get hasReadings => readings.isNotEmpty;
  bool get hasChartData => leftSpots.isNotEmpty || rightSpots.isNotEmpty;
}
