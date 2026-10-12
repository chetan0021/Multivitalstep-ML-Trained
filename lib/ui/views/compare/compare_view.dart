import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/services/analysis_service.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'compare_viewmodel.dart';

const Color _leftColor = kcSecondaryColor; // Left Hand = blue
const Color _rightColor = kcPrimaryColor; // Right Hand = green

class CompareView extends StackedView<CompareViewModel> {
  const CompareView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, CompareViewModel vm, Widget? child) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        backgroundColor: kcVeryLightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: kcDarkGreyColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hand Comparison',
            style: TextStyle(
                color: kcDarkGreyColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: vm.isBusy
          ? const Center(child: CircularProgressIndicator())
          : !vm.hasData
              ? _buildEmpty()
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Balance Score Card (most prominent) ──
                      if (vm.compareResult != null)
                        _buildBalanceScoreCard(vm.compareResult!),
                      verticalSpaceMedium,

                      // ── 2. Bar chart w/ inline legend ──
                      _buildLabel('Average Palm Pressure Strength'),
                      const SizedBox(height: 4),
                      _buildLegendRow(),
                      verticalSpaceSmall,
                      _buildBarChart(vm),
                      verticalSpaceMedium,

                      // ── 3. Side-by-side stat cards ──
                      _buildStatCards(vm),
                      verticalSpaceMedium,

                      // ── 4. Plain-English explanation ──
                      if (vm.compareResult != null) ...[
                        _buildLabel('What this means for you'),
                        verticalSpaceSmall,
                        _buildExplanationCard(vm.compareResult!,
                            vm.compareNarrative, vm.aiCompareLoading),
                        verticalSpaceMedium,
                      ],

                      // ── 5. Recommendations ──
                      if (vm.compareRecommendations.isNotEmpty) ...[
                        _buildLabel('AI Recommended Actions'),
                        verticalSpaceSmall,
                        _buildRecommendations(
                            vm.compareResult!, vm.compareRecommendations),
                        verticalSpaceMedium,
                      ],

                      // ── 6. Trend chart w/ legend ──
                      _buildLabel('Recent Trend (Last 8 Tests per Hand)'),
                      const SizedBox(height: 4),
                      _buildLegendRow(),
                      verticalSpaceSmall,
                      _buildTrendChart(vm),
                      const SizedBox(height: 8),
                      _buildChartCaption(
                          'Each point = average palm pressure force (Kg) of one test session. '
                          'Upward = improving. Aim for the two lines to stay close together.'),
                      verticalSpaceLarge,
                    ],
                  ),
                ),
    );
  }

  // ─────────────────────────────────────────────
  //  Balance Score Card
  // ─────────────────────────────────────────────
  Widget _buildBalanceScoreCard(CompareResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: result.severityColor.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: result.severityColor.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Severity chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: result.severityColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.severity,
              style: TextStyle(
                color: result.severityColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Score circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: result.balanceScore / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade100,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(result.severityColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result.balanceScore.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: result.severityColor,
                    ),
                  ),
                  const Text('/ 100',
                      style: TextStyle(fontSize: 12, color: kcMediumGrey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Balance Score',
            style: TextStyle(
                fontSize: 12, color: kcMediumGrey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            result.headline,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kcDarkGreyColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Colour-zone key
          _buildZoneLegend(),
        ],
      ),
    );
  }

  Widget _buildZoneLegend() {
    final zones = [
      ('≥ 90', '✓ Balanced', const Color(0xFF4CAF50)),
      ('80–89', 'Mild', const Color(0xFFFF9800)),
      ('70–79', 'Moderate', const Color(0xFFFF5722)),
      ('< 70', 'Significant', const Color(0xFFF44336)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: zones
          .map((z) => Column(
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: z.$3, shape: BoxShape.circle)),
                  const SizedBox(height: 2),
                  Text(z.$1,
                      style: const TextStyle(fontSize: 9, color: kcMediumGrey)),
                  Text(z.$2,
                      style: TextStyle(
                          fontSize: 9,
                          color: z.$3,
                          fontWeight: FontWeight.bold)),
                ],
              ))
          .toList(),
    );
  }

  // ─────────────────────────────────────────────
  //  Legend Row
  // ─────────────────────────────────────────────
  Widget _buildLegendRow() {
    return Row(
      children: [
        _legendDot(_leftColor, 'Left Hand (Kg)'),
        const SizedBox(width: 16),
        _legendDot(_rightColor, 'Right Hand (Kg)'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 12, color: kcDarkGreyColor)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Bar Chart
  // ─────────────────────────────────────────────
  Widget _buildBarChart(CompareViewModel vm) {
    final maxY =
        [vm.leftAvg, vm.rightAvg, 1.0].reduce((a, b) => a > b ? a : b) * 1.35;
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10)
        ],
      ),
      child: BarChart(BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) {
              final hand = group.x == 0 ? 'Left' : 'Right';
              return BarTooltipItem(
                '$hand Hand\n${rod.toY.toStringAsFixed(2)} Kg avg',
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                switch (v.toInt()) {
                  case 0:
                    return const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Left',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)));
                  case 1:
                    return const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Right',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Kg',
                style: TextStyle(fontSize: 10, color: kcMediumGrey)),
            axisNameSize: 16,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: maxY / 4 > 0 ? maxY / 4 : 1,
              getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10, color: kcMediumGrey)),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: vm.leftAvg,
              gradient: const LinearGradient(
                  colors: [kcSecondaryColor, Color(0xFF80CBC4)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter),
              width: 44,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              toY: vm.rightAvg,
              gradient: const LinearGradient(
                  colors: [kcPrimaryColor, Color(0xFF90CAF9)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter),
              width: 44,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
          ]),
        ],
      )),
    );
  }

  // ─────────────────────────────────────────────
  //  Stat Cards
  // ─────────────────────────────────────────────
  Widget _buildStatCards(CompareViewModel vm) {
    return Row(
      children: [
        _buildStatCard('Left Hand', vm.leftAvg, vm.leftPeak, vm.leftCount,
            _leftColor, vm.dominantHand == 'Left'),
        horizontalSpaceSmall,
        _buildStatCard('Right Hand', vm.rightAvg, vm.rightPeak, vm.rightCount,
            _rightColor, vm.dominantHand == 'Right'),
      ],
    );
  }

  Widget _buildStatCard(String hand, double avg, double peak, int count,
      Color color, bool isDominant) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDominant
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.back_hand, color: color, size: 16),
              const SizedBox(width: 5),
              Expanded(
                  child: Text(hand,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color))),
              if (isDominant)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('Dominant',
                      style: TextStyle(
                          fontSize: 9,
                          color: color,
                          fontWeight: FontWeight.w600)),
                ),
            ]),
            verticalSpaceSmall,
            Text('${avg.toStringAsFixed(2)} Kg',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kcDarkGreyColor)),
            const Text('all-time avg',
                style: TextStyle(fontSize: 11, color: kcMediumGrey)),
            verticalSpaceTiny,
            _miniStat(Icons.bolt, 'Peak', '${peak.toStringAsFixed(1)} Kg'),
            _miniStat(Icons.assignment, 'Tests taken', '$count'),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 12, color: kcMediumGrey),
          const SizedBox(width: 4),
          Text('$label: ',
              style: const TextStyle(fontSize: 11, color: kcMediumGrey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 11,
                  color: kcDarkGreyColor,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Explanation Card
  // ─────────────────────────────────────────────
  Widget _buildExplanationCard(
      CompareResult result, String narrative, bool loading) {
    final displayText = narrative.isNotEmpty ? narrative : result.explanation;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.severityColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: result.severityColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_severityIcon(result.severity),
                      color: result.severityColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.headline,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: result.severityColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(displayText,
              style: const TextStyle(
                  fontSize: 13, color: kcDarkGreyColor, height: 1.6)),
        ],
      ),
    );
  }

  IconData _severityIcon(String severity) {
    if (severity.contains('Balanced')) return Icons.check_circle;
    if (severity.contains('Mild')) return Icons.info_outline;
    if (severity.contains('Moderate')) return Icons.warning_amber_rounded;
    return Icons.error_outline;
  }

  // ─────────────────────────────────────────────
  //  Recommendations
  // ─────────────────────────────────────────────
  Widget _buildRecommendations(CompareResult result, List<String> recs) {
    final color = result.severityColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: Column(
        children: recs.asMap().entries.map((e) {
          final isLast = e.key == recs.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withOpacity(0.12),
                  child: Text(
                    '${e.key + 1}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ),
                title: Text(e.value,
                    style: const TextStyle(
                        fontSize: 13, color: kcDarkGreyColor, height: 1.4)),
              ),
              if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Trend Chart
  // ─────────────────────────────────────────────
  Widget _buildTrendChart(CompareViewModel vm) {
    final leftData = vm.trendData('Left');
    final rightData = vm.trendData('Right');
    if (leftData.isEmpty && rightData.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: LineChart(LineChartData(
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Kg',
                style: TextStyle(fontSize: 10, color: kcMediumGrey)),
            axisNameSize: 16,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 9, color: kcMediumGrey)),
            ),
          ),
        ),
        lineBarsData: [
          if (leftData.isNotEmpty)
            LineChartBarData(
              spots: leftData,
              isCurved: true,
              color: _leftColor,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 3, color: _leftColor, strokeWidth: 0),
              ),
              belowBarData:
                  BarAreaData(show: true, color: _leftColor.withOpacity(0.08)),
            ),
          if (rightData.isNotEmpty)
            LineChartBarData(
              spots: rightData,
              isCurved: true,
              color: _rightColor,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 3, color: _rightColor, strokeWidth: 0),
              ),
              belowBarData:
                  BarAreaData(show: true, color: _rightColor.withOpacity(0.08)),
            ),
        ],
      )),
    );
  }

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────
  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: kcDarkGreyColor),
      );

  Widget _buildChartCaption(String text) => Text(
        text,
        style: const TextStyle(fontSize: 11, color: kcMediumGrey, height: 1.5),
      );

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows, size: 80, color: kcMediumGrey),
          verticalSpaceMedium,
          Text('No test data yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kcDarkGreyColor)),
          verticalSpaceSmall,
          Text(
            'Complete tests on both hands to see\nyour balance comparison.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kcMediumGrey),
          ),
        ],
      ),
    );
  }

  @override
  CompareViewModel viewModelBuilder(BuildContext context) => CompareViewModel();

  @override
  void onViewModelReady(CompareViewModel vm) => vm.init();
}
