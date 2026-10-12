import 'package:fl_chart/fl_chart.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/test.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/analysis_service.dart';
import 'package:vital_step/services/ai_service.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/services/patient_service.dart';

class CompareViewModel extends BaseViewModel {
  final _apiCallsService = locator<ApiCallsService>();
  final _analysisService = locator<AnalysisService>();
  final _aiService = locator<AiService>();
  final _accountsService = locator<AccountsService>();
  final _modeService = locator<ModeService>();
  final _patientService = locator<PatientService>();

  List<Test> _allTests = [];
  double leftAvg = 0.0;
  double rightAvg = 0.0;
  double leftPeak = 0.0;
  double rightPeak = 0.0;
  int leftCount = 0;
  int rightCount = 0;
  String dominantHand = '';
  CompareResult? compareResult;

  // AI state for compare screen
  AiInsight? aiCompareInsight;
  bool aiCompareLoading = false;

  // Cached profile values for AI
  int? _weight;
  int? _height;
  String? _condition;

  Future<void> init() async {
    setBusy(true);
    try {
      final profile = await _accountsService.getAccountDetails();
      dominantHand = profile.dominantHand ?? 'Right';
      _weight = profile.weight;
      _height = profile.height;

      if (_modeService.isPatientMode && _modeService.hasActivePatient) {
        final readings =
            await _patientService.getReadings(_modeService.activePatientId!);
        _allTests = readings.map((r) => r.toTest()).toList();
        try {
          final patient =
              await _patientService.getPatient(_modeService.activePatientId!);
          _condition = patient?.condition;
        } catch (_) {}
      } else {
        _allTests = await _apiCallsService.getAllUserTests();
      }
      _compute();
    } catch (_) {}
    setBusy(false);

    // Fire AI insight non-blocking after UI is ready
    _loadAiCompareInsight();
  }

  Future<void> _loadAiCompareInsight() async {
    if (leftAvg == 0 && rightAvg == 0) return;
    aiCompareLoading = true;
    notifyListeners();
    try {
      aiCompareInsight = await _aiService.getCompareInsight(
        leftAvg: leftAvg,
        rightAvg: rightAvg,
        dominantHand: dominantHand,
        weight: _weight,
        height: _height,
        condition: _condition,
      );
    } catch (_) {}
    aiCompareLoading = false;
    notifyListeners();
  }

  /// Returns AI-generated compare explanation, falling back to rule-based.
  String get compareNarrative {
    if (aiCompareLoading) return 'Generating AI insight...';
    if (aiCompareInsight != null &&
        aiCompareInsight!.groqNarrative.isNotEmpty) {
      return aiCompareInsight!.groqNarrative;
    }
    return compareResult?.explanation ?? '';
  }

  /// Returns AI or ML recommendations, falling back to rule-based.
  List<String> get compareRecommendations {
    if (aiCompareInsight != null &&
        aiCompareInsight!.recommendations.isNotEmpty) {
      return aiCompareInsight!.recommendations;
    }
    return compareResult?.recommendations ?? [];
  }

  double _p(String? s) => double.tryParse(s ?? '0') ?? 0.0;
  double _testAvg(Test t) => (_p(t.trial1) + _p(t.trial2) + _p(t.trial3)) / 3;
  double _testPeak(Test t) {
    final vals = [_p(t.trial1), _p(t.trial2), _p(t.trial3)];
    return vals.reduce((a, b) => a > b ? a : b);
  }

  void _compute() {
    final leftTests = _allTests.where((t) => t.hand == 'Left').toList();
    final rightTests = _allTests.where((t) => t.hand == 'Right').toList();

    leftCount = leftTests.length;
    rightCount = rightTests.length;

    if (leftTests.isNotEmpty) {
      leftAvg =
          leftTests.map(_testAvg).reduce((a, b) => a + b) / leftTests.length;
      leftPeak = leftTests.map(_testPeak).reduce((a, b) => a > b ? a : b);
    }
    if (rightTests.isNotEmpty) {
      rightAvg =
          rightTests.map(_testAvg).reduce((a, b) => a + b) / rightTests.length;
      rightPeak = rightTests.map(_testPeak).reduce((a, b) => a > b ? a : b);
    }

    compareResult = _analysisService.compareHandsStructured(
        leftAvg, rightAvg, dominantHand);
  }

  List<FlSpot> trendData(String hand) {
    final tests = _allTests.where((t) => t.hand == hand).toList();
    final recent = tests.length > 8 ? tests.sublist(tests.length - 8) : tests;
    return recent
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), _testAvg(e.value)))
        .toList();
  }

  bool get hasData => _allTests.isNotEmpty;
}
