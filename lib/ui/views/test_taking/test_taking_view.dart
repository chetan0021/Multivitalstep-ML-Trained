import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'test_taking_viewmodel.dart';

class TestTakingView extends StackedView<TestTakingViewModel> {
  const TestTakingView({Key? key, required this.assessment}) : super(key: key);
  final Assessment assessment;
  @override
  Widget builder(
    BuildContext context,
    TestTakingViewModel viewModel,
    Widget? child,
  ) {
    return PopScope(
      // Intercept system back so it always cancels the test properly
      // instead of silently popping and leaving a queued assessment.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) viewModel.cancelTest(assessment: assessment);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: kcDarkGreyColor),
            onPressed: () => viewModel.cancelTest(assessment: assessment),
          ),
          title: const Text(
            "Grip Test",
            style: TextStyle(
                color: kcDarkGreyColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: kcPrimaryColor.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/test.png",
                          height: 140,
                          width: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      verticalSpaceLarge,
                      const CircularProgressIndicator(color: kcPrimaryColor),
                      verticalSpaceMedium,
                      const Text(
                        "Waiting for Device Data...",
                        style: TextStyle(
                            fontSize: 18,
                            color: kcPrimaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      verticalSpaceSmall,
                      const Text(
                        "The test is ready. Please perform the squeeze on the device.\n\nThis screen will close automatically once the results are processed.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, color: kcMediumGrey, height: 1.5),
                      ),
                      const Spacer(),
                      _buildGuidanceCard(),
                      verticalSpaceMedium,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kcSecondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kcSecondaryColor.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: kcSecondaryColor),
          horizontalSpaceSmall,
          Expanded(
            child: Text(
              "Ensure you are sitting upright with your arm at a 90° angle.",
              style: TextStyle(
                  fontSize: 13,
                  color: kcSecondaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  TestTakingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TestTakingViewModel();

  @override
  void onViewModelReady(TestTakingViewModel viewModel) {
    viewModel.takeTest(assessment);
  }
}
