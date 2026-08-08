import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vital_step/ui/widgets/common/analysis_radar_chart.dart';
import 'test_result_viewmodel.dart';

class TestResultView extends StackedView<TestResultViewModel> {
  const TestResultView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(TestResultViewModel viewModel) {
    viewModel.initialise();
  }

  @override
  Widget builder(
    BuildContext context,
    TestResultViewModel viewModel,
    Widget? child,
  ) {
    void handleBack() {
      final modeService = locator<ModeService>();
      if (modeService.isPatientMode && modeService.hasActivePatient) {
        // Clear the stack back to patient session so the user can't
        // accidentally pop back into the test taking waiting screen.
        NavigationService().clearStackAndShow(Routes.patientSessionView);
      } else {
        NavigationService().clearStackAndShow(
          Routes.homeView,
          arguments: const HomeViewArguments(firstPage: 1),
        );
      }
    }

    return PopScope(
      // Intercept the Android system back button so it mirrors the AppBar back button
      // instead of letting Flutter pop (or close the app if the stack is empty).
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) handleBack();
      },
      child: Scaffold(
        backgroundColor: kcBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Test Result",
            style: TextStyle(
                color: kcDarkGreyColor,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: handleBack,
            icon: const Icon(Icons.arrow_back_ios_new,
                color: kcDarkGreyColor, size: 20),
          ),
          actions: [
            IconButton(
              onPressed: () {
                viewModel.initialise();
                viewModel.notifyListeners();
              },
              icon: const Icon(Icons.refresh, color: kcPrimaryColor),
            ),
          ],
        ),
        body: FutureBuilder(
          future: viewModel.testFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: kcPrimaryColor));
            }
            final test = snapshot.data;
            if (test == null)
              return const Center(
                  child: Text("Results not found",
                      style: TextStyle(color: kcMediumGrey)));

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumHeader(viewModel, test),
                  verticalSpaceMedium,
                  _buildMetricSection(
                      "AI Performance Insight", _buildAiInsightCard(viewModel)),
                  verticalSpaceMedium,
                  _buildMetricSection(
                      "Detailed Analysis", _buildRadarChartCard(viewModel)),
                  verticalSpaceMedium,
                  _buildMetricSection("Trial Details", _buildTrialsCard(test)),
                  verticalSpaceMedium,
                  // Use viewModel directly so this section rebuilds when
                  // ML recommendations arrive asynchronously
                  _buildRecommendationsSection(viewModel),
                  verticalSpaceLarge,
                  _buildActionButtons(viewModel),
                  verticalSpaceLarge,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kcDarkGreyColor)),
        verticalSpaceSmall,
        content,
      ],
    );
  }

  Widget _buildPremiumHeader(TestResultViewModel vm, dynamic test) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [kcPrimaryColor, kcPrimaryColorDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: kcPrimaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vm.getDate(test.createdAt),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              verticalSpaceTiny,
              const Text("Latest Assessment",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30)),
            child: Text(test.hand.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
          )
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(TestResultViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: premiumCardDecoration.copyWith(
          color: kcPrimaryColor.withOpacity(0.03),
          border: Border.all(color: kcPrimaryColor.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vm.aiLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kcPrimaryColor))
                  : const Icon(Icons.auto_awesome,
                      color: kcPrimaryColor, size: 24),
              horizontalSpaceSmall,
              Expanded(
                child: Text(
                  vm.getAiInsight(),
                  style: const TextStyle(
                      fontSize: 15,
                      color: kcDarkGreyColor,
                      height: 1.5,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          // ML category + percentile badge
          if (!vm.aiLoading && vm.getMlCategory().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _mlBadge(vm.getMlCategory()),
                const SizedBox(width: 8),
                _mlBadge(
                    '${vm.getMlPercentile().toStringAsFixed(0)}th percentile',
                    color: kcSecondaryColor),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _mlBadge(String label, {Color color = kcPrimaryColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRadarChartCard(TestResultViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: premiumCardDecoration,
      child: Center(
        child: AnalysisRadarChart(
          peakStrength: vm.peakMetric,
          consistency: vm.consistencyMetric,
          symmetry: vm.symmetryMetric,
        ),
      ),
    );
  }

  Widget _buildTrialsCard(dynamic test) {
    // Format trial values to 2 decimal places
    String fmt(dynamic val) {
      final d = double.tryParse(val?.toString() ?? '');
      return d != null ? d.toStringAsFixed(2) : (val?.toString() ?? '-');
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: premiumCardDecoration,
      child: Column(
        children: [
          _buildResultRow("Posture", test.posture, isPrimary: true),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: kcLightGrey)),
          _buildResultRow("Trial 1", "${fmt(test.trial1)} Kg"),
          verticalSpaceSmall,
          _buildResultRow("Trial 2", "${fmt(test.trial2)} Kg"),
          verticalSpaceSmall,
          _buildResultRow("Trial 3", "${fmt(test.trial3)} Kg"),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String val, {bool isPrimary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: kcMediumGrey,
                fontSize: 14,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal)),
        Text(val,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kcDarkGreyColor,
                fontSize: 15)),
      ],
    );
  }

  /// Wrapper that shows loading skeleton while ML is fetching,
  /// then renders the real ML recommendations when they arrive.
  Widget _buildRecommendationsSection(TestResultViewModel vm) {
    if (vm.aiLoading) {
      // Show a subtle loading indicator while ML fetches
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AI Recommended Guidance",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kcDarkGreyColor)),
          verticalSpaceSmall,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kcPrimaryColor)),
                SizedBox(width: 12),
                Text('Loading personalised recommendations...',
                    style: TextStyle(color: kcMediumGrey, fontSize: 14)),
              ],
            ),
          ),
        ],
      );
    }

    final tips = vm.getRecoveryTips();
    return _buildRecoverySection(tips);
  }

  Widget _buildRecoverySection(List<String> tips) {
    if (tips.isEmpty) return const SizedBox();
    final categorized = tips.map((tip) => _categorize(tip)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("AI Recommended Guidance",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kcDarkGreyColor)),
        verticalSpaceSmall,
        ...categorized.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: item.color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: item.color.withOpacity(0.15))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, color: item.color, size: 22),
                  horizontalSpaceSmall,
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.label.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(item.label,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: item.color)),
                        ),
                      Text(item.body,
                          style: const TextStyle(
                              fontSize: 14,
                              color: kcDarkGreyColor,
                              fontWeight: FontWeight.w500)),
                    ],
                  )),
                ],
              ),
            )),
      ],
    );
  }

  /// Parses a raw ML recommendation string into a display-ready item.
  _RecItem _categorize(String tip) {
    final lower = tip.toLowerCase();
    if (lower.startsWith('nutrition') ||
        lower.contains('food') ||
        lower.contains('diet') ||
        lower.contains('eat') ||
        lower.contains('fish') ||
        lower.contains('turmeric')) {
      return _RecItem(
        label: 'Nutrition',
        body: _stripPrefix(tip, 'Nutrition:'),
        icon: Icons.restaurant_menu_rounded,
        color: const Color(0xFF4CAF50),
      );
    } else if (lower.startsWith('movement') ||
        lower.contains('exercise') ||
        lower.contains('grip') ||
        lower.contains('stretch') ||
        lower.contains('palm press')) {
      return _RecItem(
        label: 'Movement',
        body: _stripPrefix(tip, 'Movement:'),
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFF2196F3),
      );
    } else if (lower.startsWith('daily habits') ||
        lower.contains('sleep') ||
        lower.contains('water') ||
        lower.contains('rest') ||
        lower.contains('habit')) {
      return _RecItem(
        label: 'Daily Habits',
        body: _stripPrefix(tip, 'Daily habits:'),
        icon: Icons.self_improvement_rounded,
        color: const Color(0xFF9C27B0),
      );
    } else {
      return _RecItem(
        label: '',
        body: tip,
        icon: Icons.check_circle_outline_rounded,
        color: Colors.green,
      );
    }
  }

  String _stripPrefix(String tip, String prefix) {
    final idx = tip.indexOf(':');
    if (idx != -1 && idx < 20) return tip.substring(idx + 1).trim();
    return tip;
  }

  Widget _buildActionButtons(TestResultViewModel vm) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: vm.shareDetailedReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff25D366),
            minimumSize: const Size(double.infinity, 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share, color: Colors.white, size: 20),
              horizontalSpaceSmall,
              Text("Share Detailed Report",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ),
        verticalSpaceSmall,
        TextButton(
          onPressed: () async {
            final url = Uri.parse(
                "https://www.google.com/search?q=hand+specialist+near+me");
            if (await canLaunchUrl(url))
              await launchUrl(url, mode: LaunchMode.externalApplication);
          },
          child: const Text("Find a Hand Specialist Near Me",
              style: TextStyle(
                  color: kcPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  @override
  viewModelBuilder(BuildContext context) => TestResultViewModel();
}

/// Simple data class for a categorized recommendation item.
class _RecItem {
  final String label;
  final String body;
  final IconData icon;
  final Color color;
  const _RecItem({
    required this.label,
    required this.body,
    required this.icon,
    required this.color,
  });
}
