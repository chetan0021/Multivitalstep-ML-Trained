import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/accounts.dart';
import 'package:vital_step/Model/profile.dart';
import 'package:vital_step/Model/test.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:vital_step/services/notifications_service.dart';
import 'package:vital_step/services/analysis_service.dart';
import 'package:vital_step/services/ai_service.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/services/patient_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/ui/common/app_colors.dart';

class HomeTabViewModel extends BaseViewModel {
  final _apiCallsService = locator<ApiCallsService>();
  final _logger = getLogger("HomeTabViewModel");
  final _accountService = locator<AccountsService>();
  final _accountsService = locator<AccountsService>();
  final _navigationService = locator<NavigationService>();
  final _modeService = locator<ModeService>();
  final _patientService = locator<PatientService>();
  final _analysisService = locator<AnalysisService>();
  final _aiService = locator<AiService>();
  final _box = GetStorage();

  static const String _cachedNameKey = 'host_profile_name';

  Profile? profile;

  String get hostFirstName {
    if (profile?.name != null) return profile!.name!.split(' ')[0];
    final cached = _box.read<String>(_cachedNameKey);
    if (cached != null && cached.isNotEmpty) return cached;
    return 'User';
  }

  String rightHandValue = "";
  String leftHandValue = "";
  bool takeTestToGetHandAnalysis = false;
  List<Test> userTests = [];
  int streak = 0;
  String nudgeMessage = "";

  // AI state
  String aiHealthInsight = "";
  bool aiInsightLoading = false;

  // Cache keys (must match AiService constants)
  static const _kHomeInsightText = 'ai_cache_home_insight_text';

  String get dataSourceLabel {
    if (_modeService.isPatientMode && _modeService.hasActivePatient) {
      return _modeService.activePatientName ?? 'Patient';
    }
    return 'Host';
  }

  String get activePatientCode => _modeService.activePatientCode ?? '';
  String get activePatientName => _modeService.activePatientName ?? '';

  String get leftHandStrength {
    if (userTests.isEmpty) return "0.0";
    final leftTests = userTests.where((t) => t.hand == "Left").toList();
    if (leftTests.isEmpty) return "0.0";
    final latest = leftTests.first;
    try {
      return ((double.parse(latest.trial1) +
                  double.parse(latest.trial2) +
                  double.parse(latest.trial3)) /
              3)
          .toStringAsFixed(1);
    } catch (_) {
      return "0.0";
    }
  }

  String get rightHandStrength {
    if (userTests.isEmpty) return "0.0";
    final rightTests = userTests.where((t) => t.hand == "Right").toList();
    if (rightTests.isEmpty) return "0.0";
    final latest = rightTests.first;
    try {
      return ((double.parse(latest.trial1) +
                  double.parse(latest.trial2) +
                  double.parse(latest.trial3)) /
              3)
          .toStringAsFixed(1);
    } catch (_) {
      return "0.0";
    }
  }

  /// Returns AI (Groq) insight if available, else falls back to rule-based.
  String get healthInsight {
    if (aiHealthInsight.isNotEmpty) return aiHealthInsight;
    if (userTests.isEmpty) {
      return "Welcome to Vital-step! Take your first assessment to begin tracking your hand health and receive personalized insights.";
    }
    double left = double.tryParse(leftHandStrength) ?? 0;
    double right = double.tryParse(rightHandStrength) ?? 0;
    if (left == 0 || right == 0) {
      return "You've started your journey! Complete assessments for both hands to get a comprehensive symmetry analysis.";
    }
    double symmetry = (left > right) ? (right / left) : (left / right);
    if (symmetry > 0.9) {
      return "Excellent symmetry! Your hand strength is well-balanced. Keep up with your regular exercise routine.";
    }
    if (symmetry > 0.8) {
      return "Good balance maintained. There is a slight variance, which is often normal, but worth monitoring over time.";
    }
    return "Significant asymmetry detected. Consider focusing on your non-dominant hand exercises or consult your specialist for a detailed review.";
  }

  Color get healthStatusColor {
    if (userTests.isEmpty) return kcInfoColor;
    double left = double.tryParse(leftHandStrength) ?? 0;
    double right = double.tryParse(rightHandStrength) ?? 0;
    if (left == 0 || right == 0) return kcWarningColor;
    double symmetry = (left > right) ? (right / left) : (left / right);
    if (symmetry > 0.9) return kcSuccessColor;
    if (symmetry > 0.8) return kcWarningColor;
    return kcErrorColor;
  }

  Timer? _pollingTimer;

  Future<void> init() async {
    // Preload cached AI insight instantly (no wait)
    final cached = _box.read<String>(_kHomeInsightText);
    if (cached != null && cached.isNotEmpty) {
      aiHealthInsight = cached;
    }
    setBusy(true);
    await refreshData();
    setBusy(false);
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => refreshData());
  }

  Future<void> refreshData() async {
    try {
      if (profile == null) {
        await getProfile();
        notifyListeners();
      }
      if (profile != null) {
        final isPatient =
            _modeService.isPatientMode && _modeService.hasActivePatient;

        if (isPatient) {
          final readings =
              await _patientService.getReadings(_modeService.activePatientId!);
          userTests = readings.map((r) => r.toTest()).toList();
          _computeHandValuesFromTests();
        } else {
          await getHandsValues();
          userTests = await _apiCallsService.getAllUserTests();
        }

        streak = _analysisService.calculateStreak(userTests);
        nudgeMessage = _analysisService.getNudgeMessage(userTests);
        notifyListeners();

        // Fire AI insight asynchronously — does not block UI
        _loadAiHomeInsight();
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  /// Calls ML model + Groq to generate a personalized health insight.
  /// Non-blocking — UI stays responsive while it loads.
  Future<void> _loadAiHomeInsight() async {
    if (userTests.length < 2) return;
    aiInsightLoading = true;
    notifyListeners();
    try {
      final latest = userTests.first;
      final previous = userTests[1];

      double testAvg(Test t) =>
          ((double.tryParse(t.trial1) ?? 0) +
              (double.tryParse(t.trial2) ?? 0) +
              (double.tryParse(t.trial3) ?? 0)) /
          3;

      final latestAvg = testAvg(latest);
      final previousAvg = testAvg(previous);

      int? weight;
      int? height;
      String? condition;

      try {
        final p = await _accountsService.getAccountDetails();
        weight = p.weight;
        height = p.height;
      } catch (_) {}

      if (_modeService.isPatientMode && _modeService.hasActivePatient) {
        try {
          final patient =
              await _patientService.getPatient(_modeService.activePatientId!);
          condition = patient?.condition;
        } catch (_) {}
      }

      final insight = await _aiService.getHomeInsight(
        latestAvg: latestAvg,
        previousAvg: previousAvg,
        hand: latest.hand,
        weight: weight,
        height: height,
        condition: condition,
      );

      if (insight != null && insight.isNotEmpty) {
        aiHealthInsight = insight;
      }
    } catch (_) {
      // Non-blocking — fallback rule-based text stays
    } finally {
      aiInsightLoading = false;
      notifyListeners();
    }
  }

  void _computeHandValuesFromTests() {
    final dominantHand = profile?.dominantHand;
    final leftTests = userTests.where((t) => t.hand == 'Left').toList();
    final rightTests = userTests.where((t) => t.hand == 'Right').toList();

    double? leftAvg;
    double? rightAvg;

    if (leftTests.isNotEmpty) {
      final latest = leftTests.first;
      leftAvg = ((double.tryParse(latest.trial1) ?? 0) +
              (double.tryParse(latest.trial2) ?? 0) +
              (double.tryParse(latest.trial3) ?? 0)) /
          3;
    }
    if (rightTests.isNotEmpty) {
      final latest = rightTests.first;
      rightAvg = ((double.tryParse(latest.trial1) ?? 0) +
              (double.tryParse(latest.trial2) ?? 0) +
              (double.tryParse(latest.trial3) ?? 0)) /
          3;
    }

    if (leftAvg != null && rightAvg != null) {
      if (dominantHand == 'Right') {
        rightHandValue = '100 %';
        leftHandValue = '${(leftAvg / rightAvg * 100).toStringAsFixed(2)} %';
      } else {
        leftHandValue = '100 %';
        rightHandValue = '${(rightAvg / leftAvg * 100).toStringAsFixed(2)} %';
      }
    } else {
      if (leftAvg != null) leftHandValue = leftAvg.toStringAsFixed(1);
      if (rightAvg != null) rightHandValue = rightAvg.toStringAsFixed(1);
      takeTestToGetHandAnalysis = true;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> getProfile() async {
    profile = await _accountService.getAccountDetails();
    if (profile?.name != null && profile!.name!.isNotEmpty) {
      _box.write(_cachedNameKey, profile!.name!.split(' ')[0]);
    }
  }

  Future<void> getHandsValues() async {
    final dominantHand = profile?.dominantHand;
    try {
      final Map<String, Test?> val = await _apiCallsService.getHandsValues();

      double? rightHandAverage;
      if (val["Right"] != null) {
        rightHandAverage = (double.parse(val["Right"]!.trial1) +
                double.parse(val["Right"]!.trial2) +
                double.parse(val["Right"]!.trial3)) /
            3;
      }

      double? leftHandAverage;
      if (val["Left"] != null) {
        leftHandAverage = (double.parse(val["Left"]!.trial1) +
                double.parse(val["Left"]!.trial2) +
                double.parse(val["Left"]!.trial3)) /
            3;
      }

      if (rightHandAverage != null && leftHandAverage != null) {
        if (dominantHand == "Right") {
          rightHandValue = "100 %";
          leftHandValue =
              "${(leftHandAverage / rightHandAverage * 100).toStringAsFixed(2)} %";
        } else {
          leftHandValue = "100 %";
          rightHandValue =
              "${(rightHandAverage / leftHandAverage * 100).toStringAsFixed(2)} %";
        }
      } else {
        if (leftHandAverage != null) {
          leftHandValue = leftHandAverage.toStringAsFixed(1);
        }
        if (rightHandAverage != null) {
          rightHandValue = rightHandAverage.toStringAsFixed(1);
        }
        takeTestToGetHandAnalysis = true;
      }
    } catch (e) {
      leftHandValue = "";
      rightHandValue = "";
      takeTestToGetHandAnalysis = true;
      rebuildUi();
      _logger.e("Error in fetching hands values $e");
    }
  }

  Future<void> sendNotification() async {
    final NotificationsService notificationsService =
        locator<NotificationsService>();
    final permission = await notificationsService.checkNotificationPermission();
    if (!permission) await notificationsService.requestNotificationPermission();
    await notificationsService.sendNotificationInSomeTime();
  }

  Future<List<Accounts>> getSpecialists() async {
    return await _apiCallsService.getSpecialists();
  }

  Future<void> createNewTest() async {
    await _navigationService.navigateTo(Routes.assesmentView);
    await refreshData();
  }

  Future<void> navigateToAnalysis() async {
    if (userTests.isEmpty) {
      Fluttertoast.showToast(
        msg: "No test data yet. Take a test first to see your analysis!",
        toastLength: Toast.LENGTH_LONG,
      );
      _navigationService.navigateTo(Routes.assesmentView);
    } else {
      _navigationService.navigateTo(Routes.testResultView);
    }
  }

  Future<void> navigateToCompare() async {
    _navigationService.navigateTo(Routes.compareView);
  }

  void navigateToPatientSession() {
    _navigationService.navigateTo(Routes.patientSearchView);
  }

  void clearActivePatient() {
    _modeService.clearActivePatient();
    NavigationService().clearStackAndShow(
      Routes.homeView,
      arguments: const HomeViewArguments(firstPage: 0),
    );
  }

  Future<void> startHandTest(String hand) async {
    await _navigationService.navigateTo(Routes.assesmentView);
    Fluttertoast.showToast(msg: "Select an assessment for your $hand hand");
  }

  Future<void> takeTest() async {
    final DialogService dialogService = locator<DialogService>();
    final DialogResponse? response = await dialogService.showConfirmationDialog(
      title: "Select Hand",
      description: "Which hand would you like to test?",
      confirmationTitle: "Right Hand",
      cancelTitle: "Left Hand",
      barrierDismissible: true,
    );
    if (response == null) return;
    final selectedHand = response.confirmed ? "Right" : "Left";
    final box = GetStorage();
    box.write("preSelectedHand", selectedHand);
    await _navigationService.navigateTo(Routes.assesmentView);
    Fluttertoast.showToast(
      msg:
          "Assigned to $selectedHand hand. Please select or create an assessment.",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  List<FlSpot> getGraphData(String hand) {
    if (userTests.isEmpty) return [];
    final handTests = userTests.where((t) => t.hand == hand).toList();
    final recentTests = handTests.length > 10
        ? handTests.sublist(handTests.length - 10)
        : handTests;
    List<FlSpot> spots = [];
    for (int i = 0; i < recentTests.length; i++) {
      double avg = (double.parse(recentTests[i].trial1) +
              double.parse(recentTests[i].trial2) +
              double.parse(recentTests[i].trial3)) /
          3;
      spots.add(FlSpot(i.toDouble(), avg));
    }
    return spots;
  }

  Future<void> contactSpecialistViaWhatsApp(
      String? phone, String? countryCode) async {
    if (phone == null || phone.isEmpty) {
      Fluttertoast.showToast(msg: "No specialist number available");
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final cleanCode = (countryCode ?? "+91").replaceAll(RegExp(r'\D'), '');
    final url =
        "whatsapp://send?phone=$cleanCode$cleanPhone&text=Hello, I am using the VitalStep app and would like to discuss my assessments.";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      final webUrl = "https://wa.me/$cleanCode$cleanPhone";
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> contactSpecialistViaCall(String? phone) async {
    if (phone == null || phone.isEmpty) {
      Fluttertoast.showToast(msg: "No specialist number available");
      return;
    }
    final url = "tel:${phone.replaceAll(RegExp(r'\D'), '')}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Fluttertoast.showToast(msg: "Could not launch dialer");
    }
  }
}
