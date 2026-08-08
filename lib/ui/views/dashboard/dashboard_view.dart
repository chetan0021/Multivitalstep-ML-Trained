import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'dashboard_viewmodel.dart';

class DashboardView extends StackedView<DashboardViewModel> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, DashboardViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Insights",
              style: TextStyle(
                color: kcDarkGreyColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (viewModel.dataSourceLabel != 'Host')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kcPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Patient: ${viewModel.dataSourceLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: kcPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: kcMediumGrey),
            onPressed: () {},
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : !viewModel.hasData
              ? _buildEmpty()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Metric
                      _buildMainStats(viewModel),
                      verticalSpaceMedium,

                      _buildSectionTitle("Grip Trends"),
                      verticalSpaceSmall,
                      _buildTrendGraph(viewModel),
                      verticalSpaceMedium,

                      _buildSectionTitle("Performance Summary"),
                      verticalSpaceSmall,
                      _buildWeeklySummary(viewModel),
                      verticalSpaceMedium,

                      _buildSectionTitle("Assessment Breakdown"),
                      verticalSpaceSmall,
                      _buildPostureBreakdown(viewModel),
                      verticalSpaceLarge,
                    ],
                  ),
                ),
    );
  }

  Widget _buildMainStats(DashboardViewModel viewModel) {
    return Row(
      children: [
        _buildStatTile(
            "Total Tests", "${viewModel.totalTests}", kcSecondaryColor),
        horizontalSpaceSmall,
        _buildStatTile(
            "Number of Tests", "${viewModel.thisWeekTests}", kcPrimaryColor),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: premiumCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: kcMediumGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            verticalSpaceTiny,
            Text(value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendGraph(DashboardViewModel viewModel) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: premiumCardDecoration,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (v, m) => Text(v.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10, color: kcMediumGrey)))),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.white,
              tooltipBorder: BorderSide(color: Colors.grey.shade200),
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                // barIndex 0 = right hand (green), barIndex 1 = left hand (blue)
                final isRight = spot.barIndex == 0;
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(2)} Kg',
                  TextStyle(
                    color: isRight ? kcPrimaryColor : kcSecondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            // Right hand first (blue - kcSecondaryColor)
            if (viewModel.rightSpots.isNotEmpty)
              LineChartBarData(
                spots: viewModel.rightSpots,
                isCurved: true,
                color: kcSecondaryColor,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                    show: true, color: kcSecondaryColor.withOpacity(0.05)),
              ),
            // Left hand second (green/teal - kcPrimaryColor)
            if (viewModel.leftSpots.isNotEmpty)
              LineChartBarData(
                spots: viewModel.leftSpots,
                isCurved: true,
                color: kcPrimaryColor,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                    show: true, color: kcPrimaryColor.withOpacity(0.05)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: premiumCardDecoration,
      child: Column(
        children: [
          _buildWeeklyRow("Left Hand", viewModel.leftCurrentWeek,
              viewModel.leftLastWeek, kcSecondaryColor,
              hasThisWeek: viewModel.leftCurrentWeek != viewModel.leftAllTime ||
                  viewModel.leftLastWeek > 0),
          const Divider(height: 30),
          _buildWeeklyRow("Right Hand", viewModel.rightCurrentWeek,
              viewModel.rightLastWeek, kcPrimaryColor,
              hasThisWeek:
                  viewModel.rightCurrentWeek != viewModel.rightAllTime ||
                      viewModel.rightLastWeek > 0),
        ],
      ),
    );
  }

  Widget _buildWeeklyRow(String hand, double current, double last, Color color,
      {bool hasThisWeek = true}) {
    bool improved = current >= last;
    final isLeft = hand == "Left Hand";
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Transform(
            alignment: Alignment.center,
            transform: isLeft
                ? (Matrix4.identity()..scale(-1.0, 1.0))
                : Matrix4.identity(),
            child: Icon(Icons.back_hand, color: color, size: 20),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hand,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                last > 0
                    ? "Prev week: ${last.toStringAsFixed(1)} Kg"
                    : "All-time avg",
                style: const TextStyle(color: kcMediumGrey, fontSize: 12),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${current.toStringAsFixed(1)} Kg",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (last > 0)
              Row(
                children: [
                  Icon(improved ? Icons.arrow_upward : Icons.arrow_downward,
                      color: improved ? kcSuccessColor : kcErrorColor,
                      size: 12),
                  Text(
                    "${((current - last).abs()).toStringAsFixed(1)} Kg",
                    style: TextStyle(
                        color: improved ? kcSuccessColor : kcErrorColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: kcDarkGreyColor),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 80, color: kcLightGrey),
          verticalSpaceMedium,
          Text("No Trends Yet",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kcDarkGreyColor)),
          verticalSpaceSmall,
          Text("Keep testing to see your progress analysis.",
              textAlign: TextAlign.center,
              style: TextStyle(color: kcMediumGrey)),
        ],
      ),
    );
  }

  Widget _buildPostureBreakdown(DashboardViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: Column(
        children: vm.postureAverages.entries.map((e) {
          return ListTile(
            title: Text(e.key,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: kcDarkGreyColor)),
            trailing: Text("${e.value.toStringAsFixed(1)} Kg",
                style: const TextStyle(
                    color: kcDarkGreyColor, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) =>
      DashboardViewModel();

  @override
  void onViewModelReady(DashboardViewModel viewModel) => viewModel.init();
}
