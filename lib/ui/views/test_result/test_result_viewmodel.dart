import 'package:get_storage/get_storage.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/test.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:vital_step/services/analysis_service.dart';
import 'package:vital_step/services/ai_service.dart';
import 'package:vital_step/services/hubspot_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/services/patient_service.dart';
import 'package:vital_step/services/login_service.dart';
import 'package:vital_step/Model/patient_transfer_objects.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TestResultViewModel extends BaseViewModel {
  late Future<Test?> testFuture;
  Test? test;
  final _apiCallsService = locator<ApiCallsService>();
  final _analysisService = locator<AnalysisService>();
  final _aiService = locator<AiService>();
  final _hubSpotService = locator<HubSpotService>();
  final _modeService = locator<ModeService>();
  final _patientService = locator<PatientService>();
  final _loginService = locator<LoginService>();
  final _accountsService = locator<AccountsService>();
  final _box = GetStorage();

  // AI insight state
  AiInsight? _aiInsight;
  bool _aiLoading = false;
  bool get aiLoading => _aiLoading;

  // Cache key (matches AiService)
  static const _kTestInsightText = 'ai_cache_test_insight_text';

  /// GetStorage key that holds a Set of "patientId:testId" strings already
  /// dual-written, preventing re-writing the same test if the result screen is
  /// refreshed or revisited.
  static const String _dualWrittenKey = 'dual_written_test_ids';

  Future<Test?> initialise() async {
    // Preload cached AI narrative instantly — but still call ML for fresh recs
    final cached = _box.read<String>(_kTestInsightText);
    if (cached != null && cached.isNotEmpty && _aiInsight == null) {
      // Show cached narrative immediately while ML loads in background
      _aiInsight = AiInsight(
        mlPrediction: MlPrediction(
          average: 0,
          predictedCategory: '',
          confidence: 0,
          percentile: 0,
          recommendations: [], // will be populated when ML responds
        ),
        groqNarrative: cached,
        recommendations: [],
      );
      notifyListeners();
    }
    testFuture = _apiCallsService.getLastTest();
    test = await testFuture;
    if (test != null) {
      _handleDualWrite(test!);
      _loadAiInsight(test!);
    }
    return test;
  }

  /// Loads AI insight asynchronously (ML + Groq) without blocking the UI.
  Future<void> _loadAiInsight(Test t) async {
    _aiLoading = true;
    notifyListeners();
    try {
      int? weight;
      int? height;
      String? gender;
      String? dominantHand;
      double? palmLength;
      double? palmWidth;
      double? knuckleLength;
      String? condition;

      // Get host profile for physical measurements
      try {
        final profile = await _accountsService.getAccountDetails();
        weight = profile.weight;
        height = profile.height;
        gender = profile.gender;
        dominantHand = profile.dominantHand;
        palmLength = profile.palmLength != null
            ? double.tryParse(profile.palmLength.toString())
            : null;
        palmWidth = profile.palmWidth != null
            ? double.tryParse(profile.palmWidth.toString())
            : null;
        knuckleLength = profile.knucklesLength != null
            ? double.tryParse(profile.knucklesLength.toString())
            : null;
      } catch (_) {}

      // In patient mode, get patient-specific data
      if (_modeService.isPatientMode && _modeService.hasActivePatient) {
        try {
          final patient =
              await _patientService.getPatient(_modeService.activePatientId!);
          if (patient != null) {
            condition = patient.condition;
            if (patient.weight != null) weight = patient.weight;
            if (patient.height != null) height = patient.height;
            if (patient.dominantHand != null)
              dominantHand = patient.dominantHand;
            if (patient.palmLength != null) palmLength = patient.palmLength;
            if (patient.palmWidth != null) palmWidth = patient.palmWidth;
            if (patient.knuckleLength != null)
              knuckleLength = patient.knuckleLength;
          }
        } catch (_) {}
      }

      _aiInsight = await _aiService.getTestInsight(
        trial1: double.tryParse(t.trial1) ?? 0,
        trial2: double.tryParse(t.trial2) ?? 0,
        trial3: double.tryParse(t.trial3) ?? 0,
        hand: t.hand,
        posture: t.posture,
        weight: weight,
        height: height,
        gender: gender,
        dominantHand: dominantHand,
        palmLength: palmLength,
        palmWidth: palmWidth,
        knuckleLength: knuckleLength,
        condition: condition,
      );
    } catch (e) {
      // Non-blocking — fall back to rule-based
    } finally {
      _aiLoading = false;
      notifyListeners();
    }
  }

  /// Returns a composite key used to deduplicate dual-writes.
  /// Format: "<patientId>:<testId>"
  String _dualWriteKey(String patientId, int testId) => '$patientId:$testId';

  /// Whether this test has already been written to the patient Supabase DB.
  bool _alreadyDualWritten(String patientId, int testId) {
    final List<dynamic> written = (_box.read<List>(_dualWrittenKey) ?? []);
    return written.contains(_dualWriteKey(patientId, testId));
  }

  /// Marks this test as dual-written so subsequent calls are skipped.
  void _markDualWritten(String patientId, int testId) {
    final List<dynamic> written =
        List.from(_box.read<List>(_dualWrittenKey) ?? []);
    final key = _dualWriteKey(patientId, testId);
    if (!written.contains(key)) {
      written.add(key);
      // Keep the list from growing indefinitely — keep last 200 entries.
      if (written.length > 200) written.removeRange(0, written.length - 200);
      _box.write(_dualWrittenKey, written);
    }
  }

  /// Dual-write guard: saves a copy of the completed test to the Patient Supabase
  /// project when the app is in Patient Mode with an active patient selected.
  ///
  /// Guards:
  ///   • Only fires in Patient Mode with an active patient (Req 4.8).
  ///   • Deduplicates by patientId + testId so refreshing the result screen or
  ///     navigating back to it never writes the same record twice (data-leak fix).
  ///   • The test's createdAt must be recent (within the last 5 minutes) to
  ///     prevent a leftover host-account test from bleeding into a new patient.
  ///
  /// On failure, the reading is enqueued in the GetStorage retry queue and a
  /// non-blocking toast is shown (Req 4.5). Never throws.
  Future<void> _handleDualWrite(Test test) async {
    // Only write to patient Supabase if in Patient Mode with active patient
    if (!_modeService.isPatientMode || !_modeService.hasActivePatient) return;

    final patientId = _modeService.activePatientId!;

    // Deduplication: skip if this exact test was already saved for this patient.
    if (_alreadyDualWritten(patientId, test.id)) return;

    // Staleness guard: only save tests that were taken very recently (within
    // 5 minutes). This prevents an old host-account test from being injected
    // into a freshly-created patient who hasn't taken a test yet.
    final age = DateTime.now().difference(test.createdAt);
    if (age.inMinutes > 5) return;

    try {
      final hostUserId = await _loginService.getUserId() ?? '';
      final data = PatientReadingData(
        patientId: patientId,
        hostUserId: hostUserId,
        trial1: test.trial1,
        trial2: test.trial2,
        trial3: test.trial3,
        hand: test.hand,
        posture: test.posture,
        assessmentType: test.assestmentId.toString(),
        createdAt: test.createdAt,
      );

      await _patientService.saveReading(data);
      // Mark as written only after a successful save.
      _markDualWritten(patientId, test.id);

      // Non-blocking HubSpot sync for the test reading
      _syncReadingToHubSpot(test, patientId);
    } catch (e) {
      // Non-blocking: queue for retry, show toast
      try {
        final hostUserId = await _loginService.getUserId() ?? '';
        _patientService.enqueueReading(PatientReadingData(
          patientId: patientId,
          hostUserId: hostUserId,
          trial1: test.trial1,
          trial2: test.trial2,
          trial3: test.trial3,
          hand: test.hand,
          posture: test.posture,
          assessmentType: test.assestmentId.toString(),
          createdAt: test.createdAt,
        ));
        Fluttertoast.showToast(msg: 'Patient data queued for sync');
      } catch (_) {}
    }
  }

  /// Fires a non-blocking HubSpot sync for a completed test reading.
  void _syncReadingToHubSpot(Test test, String patientId) {
    _patientService.getPatient(patientId).then((patient) {
      if (patient == null) return;
      _hubSpotService
          .syncTestReading(
        name: patient.name,
        patientCode: patient.patientCode,
        phone: patient.phone.isNotEmpty ? patient.phone : null,
        email: patient.email.isNotEmpty ? patient.email : null,
        trial1: double.tryParse(test.trial1) ?? 0,
        trial2: double.tryParse(test.trial2) ?? 0,
        trial3: double.tryParse(test.trial3) ?? 0,
        hand: test.hand,
        posture: test.posture,
        testDate: test.createdAt,
        deviceId: patient.hostUserId,
        age: patient.age,
        gender: patient.gender,
        dominantHand: patient.dominantHand,
        condition: patient.condition,
        dob: patient.dob,
      )
          .catchError((e) {
        // Non-blocking — ignore errors silently
      });
    }).catchError((e) {
      // Non-blocking
    });
  }

  String getAiInsight() {
    if (_aiLoading) return "Analyzing with AI...";
    // Use Groq narrative if available, else ML fallback, else rule-based
    if (_aiInsight != null && _aiInsight!.groqNarrative.isNotEmpty) {
      return _aiInsight!.groqNarrative;
    }
    if (_aiInsight != null) {
      final ml = _aiInsight!.mlPrediction;
      return 'Your grip strength is classified as ${ml.predictedCategory} '
          '(${ml.percentile.toStringAsFixed(0)}th percentile). '
          '${ml.recommendations.isNotEmpty ? ml.recommendations.first : ""}';
    }
    if (test == null) return "Loading analysis...";
    return _analysisService.analyzeTrials(test!);
  }

  String getMlCategory() => _aiInsight?.mlPrediction.predictedCategory ?? '';
  double getMlPercentile() => _aiInsight?.mlPrediction.percentile ?? 0;
  double getMlConfidence() => _aiInsight?.mlPrediction.confidence ?? 0;

  List<String> getRecoveryTips() {
    if (_aiInsight != null && _aiInsight!.recommendations.isNotEmpty) {
      return _aiInsight!.recommendations;
    }
    if (test == null) return [];
    return _analysisService.getRecoveryTips(test!);
  }

  Future<void> shareOnWhatsApp() async {
    if (test == null) return;
    final avg = (double.parse(test!.trial1) +
            double.parse(test!.trial2) +
            double.parse(test!.trial3)) /
        3;
    final message = "Vital Step Assessment Result:\n"
        "Date: ${getDate(test!.createdAt)}\n"
        "Posture: ${test!.posture}\n"
        "Hand: ${test!.hand}\n"
        "Average strength: ${avg.toStringAsFixed(2)} Kg\n"
        "AI Insight: ${getAiInsight()}";

    final url =
        Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  String getDate(DateTime createdAt) {
    return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
  }

  String getTime(DateTime createdAt) {
    return "${createdAt.hour}:${createdAt.minute}";
  }

  Future<void> shareDetailedReport() async {
    if (test == null) return;
    final avg = (double.parse(test!.trial1) +
            double.parse(test!.trial2) +
            double.parse(test!.trial3)) /
        3;
    final message = "Vital Step - Detailed Specialist Report Request:\n"
        "Patient Assessment Date: ${getDate(test!.createdAt)}\n"
        "Symmetry: ${symmetryMetric.toStringAsFixed(1)}%\n"
        "Consistency: ${consistencyMetric.toStringAsFixed(1)}%\n"
        "Peak: ${peakMetric.toStringAsFixed(1)} Kg\n"
        "Average: ${avg.toStringAsFixed(2)} Kg\n"
        "Please review my latest metrics and provide guidance.";

    final url =
        Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  double _symmetryMetric = 30.0;
  double get peakMetric => test != null ? double.parse(test!.trial1) : 0;
  double get consistencyMetric {
    if (test == null) return 0;
    final t1 = double.parse(test!.trial1);
    final t2 = double.parse(test!.trial2);
    final t3 = double.parse(test!.trial3);
    final avg = (t1 + t2 + t3) / 3;
    final variation = (([t1, t2, t3].reduce((a, b) => a > b ? a : b) -
            [t1, t2, t3].reduce((a, b) => a < b ? a : b)) /
        avg);
    return (1 - variation).clamp(0, 1) * 50;
  }

  double get symmetryMetric => _symmetryMetric;

  Future<void> calculateSymmetry() async {
    final Map<String, Test?> hands = await _apiCallsService.getHandsValues();
    if (hands["Left"] != null && hands["Right"] != null) {
      final lAvg = (double.parse(hands["Left"]!.trial1) +
              double.parse(hands["Left"]!.trial2) +
              double.parse(hands["Left"]!.trial3)) /
          3;
      final rAvg = (double.parse(hands["Right"]!.trial1) +
              double.parse(hands["Right"]!.trial2) +
              double.parse(hands["Right"]!.trial3)) /
          3;
      final diff = (lAvg - rAvg).abs();
      _symmetryMetric = (1 - (diff / ((lAvg + rAvg) / 2))).clamp(0, 1) * 50;
      notifyListeners();
    }
  }
}
