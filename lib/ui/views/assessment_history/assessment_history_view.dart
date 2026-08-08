import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/Model/test.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:printing/printing.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

import 'package:fl_chart/fl_chart.dart';
import 'assessment_history_viewmodel.dart';

class AssessmentHistoryView extends StackedView<AssessmentHistoryViewModel> {
  const AssessmentHistoryView(
      {Key? key, required this.assessment, this.patientId})
      : super(key: key);
  final Assessment assessment;
  final int? patientId;

  @override
  Widget builder(
    BuildContext context,
    AssessmentHistoryViewModel viewModel,
    Widget? child,
  ) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kcBackgroundColor,
        appBar: AppBar(
          backgroundColor: kcVeryLightGrey,
          elevation: 0,
          title: Text(
            assessment.type,
            style: const TextStyle(color: kcDarkGreyColor, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kcDarkGreyColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: () => viewModel.generatePDF(assessmentId: assessment.id, patientId: patientId),
              icon: const Icon(Icons.ios_share, color: kcPrimaryColor, size: 22),
            )
          ],
          bottom: TabBar(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: kcPrimaryColor.withOpacity(0.08),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: kcPrimaryColor,
            unselectedLabelColor: kcMediumGrey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: "Logs"),
              Tab(text: "Trends"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TableView(viewModel: viewModel, assessment: assessment),
            _GraphView(viewModel: viewModel),
          ],
        ),
      ),
    );
  }

  @override
  AssessmentHistoryViewModel viewModelBuilder(BuildContext context) => AssessmentHistoryViewModel();

  @override
  void onViewModelReady(AssessmentHistoryViewModel viewModel) async {
    viewModel.init(assessmentId: assessment.id, patientUserId: patientId);
    await viewModel.getDominantHand(patientId: patientId);
  }
}

class _TableView extends StatelessWidget {
  final AssessmentHistoryViewModel viewModel;
  final Assessment assessment;
  const _TableView({required this.viewModel, required this.assessment});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isBusy || viewModel.tests == null) {
      return const Center(child: CircularProgressIndicator(color: kcPrimaryColor));
    }

    if (viewModel.tests!.isEmpty) {
      return _buildEmptyState();
    }

    final rightTests = viewModel.getHandTests(hand: "Right", isAscending: false);
    final leftTests = viewModel.getHandTests(hand: "Left", isAscending: false);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle("Comparison Summary"),
        verticalSpaceSmall,
        _buildComparisonCard(viewModel),
        verticalSpaceMedium,
        
        _buildSectionTitle("Right Hand Logs"),
        verticalSpaceSmall,
        ...rightTests.map((test) => _buildTestCard(viewModel, test, assessment, kcPrimaryColor)),
        verticalSpaceMedium,

        _buildSectionTitle("Left Hand Logs"),
        verticalSpaceSmall,
        ...leftTests.map((test) => _buildTestCard(viewModel, test, assessment, kcSecondaryColor)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kcDarkGreyColor));
  }

  Widget _buildComparisonCard(AssessmentHistoryViewModel vm) {
    final rh = vm.getLatestTestAverage(hand: "Right");
    final lh = vm.getLatestTestAverage(hand: "Left");
    final diff = vm.getLatestAverageDifference();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: kcLightGrey.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildMetricColumn("Right Hand", rh, kcPrimaryColor)),
              Container(height: 50, width: 1, color: kcLightGrey.withOpacity(0.3)),
              Expanded(child: _buildMetricColumn("Left Hand", lh, kcSecondaryColor)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1, color: kcLightGrey)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.compare_arrows_rounded, color: kcMediumGrey, size: 18),
              const SizedBox(width: 8),
              const Text("Hand Asymmetry: ", style: TextStyle(color: kcMediumGrey, fontSize: 13, fontWeight: FontWeight.w500)),
              Text("$diff Kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kcDarkGreyColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: kcMediumGrey, fontSize: 12)),
        verticalSpaceTiny,
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTestCard(AssessmentHistoryViewModel vm, Test test, Assessment assessment, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kcLightGrey.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.calendar_today_rounded, color: color, size: 20),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vm.getDate(test.createdAt), style: const TextStyle(fontWeight: FontWeight.bold, color: kcDarkGreyColor, fontSize: 15)),
                verticalSpaceTiny,
                Text("${test.trial1} | ${test.trial2} | ${test.trial3} Kg", style: const TextStyle(color: kcMediumGrey, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${vm.calculateAverage(test)} Kg", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
              const Text("AVG STRENGTH", style: TextStyle(color: kcMediumGrey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: kcLightGrey, size: 20),
            onPressed: () => vm.deleteTest(id: test.id, assessmentId: assessment.id),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: kcLightGrey),
          verticalSpaceMedium,
          Text("No History Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kcDarkGreyColor)),
          verticalSpaceSmall,
          Text("Complete tests to see your progress here.", textAlign: TextAlign.center, style: TextStyle(color: kcMediumGrey)),
        ],
      ),
    );
  }
}

class _GraphView extends StatefulWidget {
  final AssessmentHistoryViewModel viewModel;
  const _GraphView({required this.viewModel});

  @override
  State<_GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<_GraphView> {
  final GlobalKey _chartKey = GlobalKey();
  AssessmentHistoryViewModel get vm => widget.viewModel;

  Future<void> _shareChart() async {
    try {
      RenderRepaintBoundary? boundary = _chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Printing.sharePdf(
        bytes: pngBytes,
        filename: 'VitalStep_Trend_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    } catch (e) {
      debugPrint("Error sharing chart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftData = vm.getChartData('Left');
    final rightData = vm.getChartData('Right');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTrendSummary(leftData, rightData),
        verticalSpaceMedium,
        _buildHowToRead(),
        verticalSpaceMedium,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Grip Strength Trends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kcDarkGreyColor)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt_rounded, color: kcPrimaryColor),
                  onPressed: _shareChart,
                  tooltip: "Share Chart Image",
                ),
                IconButton(
                  icon: Icon(vm.selectedChartType == ChartType.line ? Icons.bar_chart_rounded : Icons.show_chart_rounded, color: kcPrimaryColor),
                  onPressed: () => vm.toggleChartType(),
                  tooltip: "Switch Chart Type",
                ),
              ],
            ),
          ],
        ),
        verticalSpaceSmall,
        _buildPeriodSelector(),
        verticalSpaceSmall,
        _buildChartContainer(leftData, rightData),
        verticalSpaceLarge,
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kcLightGrey.withOpacity(0.3)),
      ),
      child: Row(
        children: ChartPeriod.values.map((period) {
          final isSelected = vm.selectedPeriod == period;
          return Expanded(
            child: InkWell(
              onTap: () => vm.setPeriod(period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? kcPrimaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  period.name[0].toUpperCase() + period.name.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : kcMediumGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendSummary(Map<String, dynamic> left, Map<String, dynamic> right) {
    final leftVal = (left['spots'] as List<FlSpot>).isNotEmpty ? (left['spots'] as List<FlSpot>).last.y : 0.0;
    final rightVal = (right['spots'] as List<FlSpot>).isNotEmpty ? (right['spots'] as List<FlSpot>).last.y : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kcPrimaryColor, kcPrimaryColorDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: kcPrimaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          _buildTrendMetric("Left Hand", leftVal, kcSecondaryColor),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.2)),
          _buildTrendMetric("Right Hand", rightVal, Colors.white),
        ],
      ),
    );
  }

  Widget _buildTrendMetric(String hand, double value, Color dotColor) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              horizontalSpaceTiny,
              Text(hand, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          verticalSpaceTiny,
          Text("${value.toStringAsFixed(1)} Kg", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("current avg", style: TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildChartContainer(Map<String, dynamic> left, Map<String, dynamic> right) {
    return RepaintBoundary(
      key: _chartKey,
      child: Container(
        height: 320,
        padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
        decoration: premiumCardDecoration.copyWith(color: Colors.white),
        child: vm.selectedChartType == ChartType.line 
          ? _buildLineChart(left['spots'], right['spots'], left['labels'])
          : _buildBarChart(left['barGroups'], right['barGroups'], left['labels']),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> leftSpots, List<FlSpot> rightSpots, List<String> labels) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10, getDrawingHorizontalLine: (v) => FlLine(color: kcLightGrey.withOpacity(0.2), strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 11, color: kcMediumGrey, fontWeight: FontWeight.bold)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) {
            if (v.toInt() >= 0 && v.toInt() < labels.length) {
              return Padding(padding: const EdgeInsets.only(top: 8), child: Text(labels[v.toInt()], style: const TextStyle(fontSize: 10, color: kcMediumGrey, fontWeight: FontWeight.bold)));
            }
            return const SizedBox();
          })),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          if (leftSpots.isNotEmpty)
            LineChartBarData(
              spots: leftSpots,
              isCurved: true,
              color: kcSecondaryColor,
              barWidth: 4,
              dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 5, color: Colors.white, strokeWidth: 3, strokeColor: kcSecondaryColor)),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [kcSecondaryColor.withOpacity(0.15), kcSecondaryColor.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
          if (rightSpots.isNotEmpty)
            LineChartBarData(
              spots: rightSpots,
              isCurved: true,
              color: kcPrimaryColor,
              barWidth: 4,
              dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 5, color: Colors.white, strokeWidth: 3, strokeColor: kcPrimaryColor)),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [kcPrimaryColor.withOpacity(0.15), kcPrimaryColor.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => kcDarkGreyColor.withOpacity(0.8),
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) => LineTooltipItem("${s.y.toStringAsFixed(1)} Kg", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<BarChartGroupData> leftGroups, List<BarChartGroupData> rightGroups, List<String> labels) {
    // Merge bar groups for comparison
    final List<BarChartGroupData> mergedGroups = [];
    for (int i = 0; i < labels.length; i++) {
      mergedGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          if (leftGroups.length > i) leftGroups[i].barRods[0].copyWith(color: kcSecondaryColor),
          if (rightGroups.length > i) rightGroups[i].barRods[0].copyWith(color: kcPrimaryColor),
        ],
      ));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: mergedGroups.isEmpty ? 50 : null,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => kcDarkGreyColor.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem("${rod.toY.toStringAsFixed(1)} Kg", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 11, color: kcMediumGrey, fontWeight: FontWeight.bold)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) {
             if (v.toInt() >= 0 && v.toInt() < labels.length) {
              return Padding(padding: const EdgeInsets.only(top: 8), child: Text(labels[v.toInt()], style: const TextStyle(fontSize: 10, color: kcMediumGrey, fontWeight: FontWeight.bold)));
            }
            return const SizedBox();
          })),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10, getDrawingHorizontalLine: (v) => FlLine(color: kcLightGrey.withOpacity(0.1), strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        barGroups: mergedGroups,
      ),
    );
  }

  Widget _buildHowToRead() {
    return Container(
      decoration: premiumCardDecoration,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: const ExpansionTile(
          title: Text("How to read this chart?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kcDarkGreyColor)),
          leading: Icon(Icons.help_outline, color: kcSecondaryColor),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• Data is aggregated by the selected period (Week, Month, Year).", style: TextStyle(color: kcMediumGrey, fontSize: 13)),
                  verticalSpaceTiny,
                  Text("• Use the Bar Chart for direct side-by-side hand comparison.", style: TextStyle(color: kcMediumGrey, fontSize: 13)),
                  verticalSpaceTiny,
                  Text("• Switch to the Line Chart to view smooth progress trends.", style: TextStyle(color: kcMediumGrey, fontSize: 13)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- tiny data classes ---
class _MonthlyData {
  final List<FlSpot> spots;
  final List<String> labels;
  _MonthlyData(this.spots, this.labels);
}

enum _Trend { improving, declining, stable }


