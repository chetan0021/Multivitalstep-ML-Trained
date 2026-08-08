import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vital_step/ui/common/app_colors.dart';

class AnalysisRadarChart extends StatelessWidget {
  final double peakStrength;
  final double consistency;
  final double symmetry;

  const AnalysisRadarChart({
    Key? key,
    required this.peakStrength,
    required this.consistency,
    required this.symmetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── How to read label ──
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "Performance Radar  (higher = better)",
            style: TextStyle(fontSize: 12, color: kcMediumGrey, fontStyle: FontStyle.italic),
          ),
        ),

        // ── Radar chart ──
        AspectRatio(
          aspectRatio: 1.4,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: kcPrimaryColor.withOpacity(0.35),
                  borderColor: kcPrimaryColor,
                  entryRadius: 4.0,
                  dataEntries: [
                    RadarEntry(value: peakStrength),
                    RadarEntry(value: consistency),
                    RadarEntry(value: symmetry),
                  ],
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(color: Colors.grey, width: 0.5),
              titlePositionPercentageOffset: 0.15,
              titleTextStyle: const TextStyle(
                color: kcDarkGreyColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                switch (index) {
                  case 0: return const RadarChartTitle(text: 'Peak');
                  case 1: return const RadarChartTitle(text: 'Consistency');
                  case 2: return const RadarChartTitle(text: 'Symmetry');
                  default: return const RadarChartTitle(text: '');
                }
              },
              tickCount: 4,
              ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
              gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Readable stat chips below the chart ──
        Row(
          children: [
            _statChip("Peak", "${peakStrength.toStringAsFixed(1)} Kg", Colors.purple),
            const SizedBox(width: 8),
            _statChip("Consistency", "${consistency.toStringAsFixed(1)}%", kcPrimaryColor),
            const SizedBox(width: 8),
            _statChip("Symmetry", "${symmetry.toStringAsFixed(1)}%", kcSecondaryColor),
          ],
        ),

        const SizedBox(height: 8),

        // ── Interpretation hint ──
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hint("Peak", "Max grip force across all 3 trials (Kg)"),
              _Hint("Consistency", "How similar your 3 trials were (100% = identical)"),
              _Hint("Symmetry", "Left vs Right balance (100% = equal strength)"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String term;
  final String meaning;
  const _Hint(this.term, this.meaning);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$term: ", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kcDarkGreyColor)),
          Expanded(child: Text(meaning, style: const TextStyle(fontSize: 11, color: kcMediumGrey))),
        ],
      ),
    );
  }
}
