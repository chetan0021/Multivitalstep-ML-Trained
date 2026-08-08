import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/patient_reading.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';

import 'patient_history_viewmodel.dart';

class PatientHistoryView extends StackedView<PatientHistoryViewModel> {
  const PatientHistoryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PatientHistoryViewModel viewModel,
    Widget? child,
  ) {
    final patientCode = viewModel.patient?.patientCode ?? '...';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kcDarkGreyColor),
        title: Text(
          'History: $patientCode',
          style: const TextStyle(
            color: kcDarkGreyColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: viewModel.isBusy
          ? const Center(
              child: CircularProgressIndicator(color: kcPrimaryColor))
          : RefreshIndicator(
              color: kcPrimaryColor,
              onRefresh: viewModel.refresh,
              child: viewModel.hasReadings
                  ? _buildContent(context, viewModel)
                  : _buildEmpty(),
            ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: const [
        SizedBox(height: 80),
        Icon(Icons.history_edu_outlined, size: 72, color: kcLightGrey),
        SizedBox(height: 20),
        Text(
          'No sessions yet. Take a test to start building this patient\'s history.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: kcMediumGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Main content ─────────────────────────────────────────────────────────

  Widget _buildContent(
      BuildContext context, PatientHistoryViewModel viewModel) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Chart section
        _buildSectionTitle('Grip Trends'),
        verticalSpaceSmall,
        if (viewModel.hasChartData)
          _buildChart(viewModel)
        else
          _buildNoChartData(),
        verticalSpaceMedium,

        // Legend
        if (viewModel.hasChartData) ...[
          _buildLegend(),
          verticalSpaceMedium,
        ],

        // Readings list
        _buildSectionTitle('All Sessions'),
        verticalSpaceSmall,
        ...viewModel.readings
            .map((r) => _buildReadingCard(context, r, viewModel)),
        verticalSpaceMedium,
      ],
    );
  }

  // ── Chart ────────────────────────────────────────────────────────────────

  Widget _buildChart(PatientHistoryViewModel viewModel) {
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
                reservedSize: 36,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: kcMediumGrey),
                ),
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.white,
              tooltipBorder: BorderSide(color: Colors.grey.shade200),
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final isLeft = spot.barIndex == 0;
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(2)} Kg',
                  TextStyle(
                    color: isLeft ? kcPrimaryColor : kcSecondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            // Left hand (green/teal – kcPrimaryColor)
            if (viewModel.leftSpots.isNotEmpty)
              LineChartBarData(
                spots: viewModel.leftSpots,
                isCurved: true,
                color: kcPrimaryColor,
                barWidth: 3,
                dotData: FlDotData(
                  show: viewModel.leftSpots.length == 1,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: kcPrimaryColor.withValues(alpha: 0.05),
                ),
              ),
            // Right hand (blue – kcSecondaryColor)
            if (viewModel.rightSpots.isNotEmpty)
              LineChartBarData(
                spots: viewModel.rightSpots,
                isCurved: true,
                color: kcSecondaryColor,
                barWidth: 3,
                dotData: FlDotData(
                  show: viewModel.rightSpots.length == 1,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: kcSecondaryColor.withValues(alpha: 0.05),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChartData() {
    return Container(
      height: 80,
      decoration: premiumCardDecoration,
      alignment: Alignment.center,
      child: const Text(
        'Not enough data for a chart yet.',
        style: TextStyle(color: kcMediumGrey, fontSize: 13),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(kcPrimaryColor),
        horizontalSpaceTiny,
        const Text('Left hand',
            style: TextStyle(fontSize: 12, color: kcMediumGrey)),
        horizontalSpaceMedium,
        _legendDot(kcSecondaryColor),
        horizontalSpaceTiny,
        const Text('Right hand',
            style: TextStyle(fontSize: 12, color: kcMediumGrey)),
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ── Reading card ─────────────────────────────────────────────────────────

  Widget _buildReadingCard(BuildContext context, PatientReading reading,
      PatientHistoryViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: date + hand badge + delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(reading.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: kcMediumGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  _buildHandBadge(reading.hand),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Reading'),
                          content: const Text(
                              'Are you sure you want to delete this reading? This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(_, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(_, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: kcErrorColor)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await viewModel.deleteReading(reading.id);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kcErrorColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 16, color: kcErrorColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          verticalSpaceSmall,

          // Trial values row
          Row(
            children: [
              _buildTrialChip('T1', reading.trial1),
              horizontalSpaceSmall,
              _buildTrialChip('T2', reading.trial2),
              horizontalSpaceSmall,
              _buildTrialChip('T3', reading.trial3),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Avg',
                    style: TextStyle(fontSize: 11, color: kcMediumGrey),
                  ),
                  Text(
                    '${reading.average.toStringAsFixed(2)} Kg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kcDarkGreyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHandBadge(String hand) {
    final isLeft = hand == 'Left';
    final color = isLeft ? kcPrimaryColor : kcSecondaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: isLeft
                ? (Matrix4.identity()..scale(-1.0, 1.0))
                : Matrix4.identity(),
            child: Icon(Icons.back_hand, size: 12, color: color),
          ),
          horizontalSpaceTiny,
          Text(
            hand,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialChip(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: kcMediumGrey),
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kcDarkGreyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kcDarkGreyColor,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }

  @override
  PatientHistoryViewModel viewModelBuilder(BuildContext context) =>
      PatientHistoryViewModel();

  @override
  void onViewModelReady(PatientHistoryViewModel viewModel) => viewModel.init();
}
