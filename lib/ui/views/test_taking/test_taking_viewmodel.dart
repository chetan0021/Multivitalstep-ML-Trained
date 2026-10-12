import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:vital_step/Model/test.dart';
import 'package:url_launcher/url_launcher.dart';

class TestTakingViewModel extends BaseViewModel {
  final ApiCallsService _apiCallsService = locator<ApiCallsService>();
  final _dialogService = locator<DialogService>();

  bool _isPolling = false;
  bool get isPolling => _isPolling;

  void takeTest(Assessment assessment) async {
    _isPolling = true;
    notifyListeners();

    // Poll until the queue is empty (meaning the test is processed/completed by backend)
    bool isComplete = false;
    int attempts = 0;
    const int maxAttempts = 120; // 120 seconds timeout for better tolerance

    try {
      while (!isComplete && attempts < maxAttempts) {
        final assessmentQueue = await _apiCallsService.getAssessmentQueue(
            assessmentId: assessment.id.toString());

        // If the queue for this assessment is empty, it means the test has been processed
        if (assessmentQueue.isEmpty) {
          isComplete = true;
        } else {
          // Still in progress, wait and try again
          await Future.delayed(const Duration(seconds: 2));
          attempts++;
        }
      }

      if (isComplete) {
        // Navigate to results using navigateTo so the system back button has a
        // stack entry to return to (dashboard / patient session), instead of
        // clearStackAndShow which would leave an empty stack and close the app.
        NavigationService().navigateTo(Routes.testResultView);
      } else {
        _isPolling = false;
        notifyListeners();
        await _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Test Timeout',
          description:
              'The test timed out. Please ensure you have completed the squeeze on the dynamometer.',
        );
      }
    } catch (e) {
      _isPolling = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Error during test: $e');
    }
  }

  void cancelTest({required Assessment assessment}) async {
    try {
      if (assessment.queueId != null) {
        await _apiCallsService.cancelAssessment(queueId: assessment.queueId!);
      } else {
        int queueId = await _apiCallsService.getQueueId(assessment);
        await _apiCallsService.cancelAssessment(queueId: queueId);
      }
      // cancelAssessment already navigates via clearStackAndShow — don't call back()
    } catch (e) {
      Fluttertoast.showToast(msg: 'Test not cancelled');
      // Navigate to home safely on error — never close the app
      NavigationService().clearStackAndShow(Routes.homeView,
          arguments: const HomeViewArguments(firstPage: 1));
    }
  }

  Future<void> shareOnWhatsApp(Test test) async {
    final message = "Vital Step Assessment Result:\n"
        "Date: ${test.createdAt.toString().split(' ')[0]}\n"
        "Posture: ${test.posture}\n"
        "Hand: ${test.hand}\n"
        "Average: ${((double.parse(test.trial1) + double.parse(test.trial2) + double.parse(test.trial3)) / 3).toStringAsFixed(2)} Kg";

    final url =
        Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
