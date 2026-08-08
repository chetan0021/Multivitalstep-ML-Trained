import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/profile.dart';
import 'package:vital_step/Model/test.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

enum ChartPeriod { week, month, year }
enum ChartType { line, bar }

class AssessmentHistoryViewModel extends BaseViewModel {
  List<Test>? tests;
  final _apiCallsService = locator<ApiCallsService>();
  init({required int assessmentId, int? patientUserId}) async {
    tests = null;
    rebuildUi();
    tests = await _apiCallsService.getAllAssessmentTests(
        assessmentId: assessmentId);
    if (tests!.isEmpty) {
      rebuildUi();
      return;
    }
    tests!.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    rebuildUi();
  }

  ChartPeriod _selectedPeriod = ChartPeriod.month;
  ChartPeriod get selectedPeriod => _selectedPeriod;

  ChartType _selectedChartType = ChartType.line;
  ChartType get selectedChartType => _selectedChartType;

  void setPeriod(ChartPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  void toggleChartType() {
    _selectedChartType = _selectedChartType == ChartType.line ? ChartType.bar : ChartType.line;
    notifyListeners();
  }

  String? dominantHand;

  String calculateAverage(Test test) {
    final double trial1 = double.parse(test.trial1);
    final double trial2 = double.parse(test.trial2);
    final double trial3 = double.parse(test.trial3);
    final double average = (trial1 + trial2 + trial3) / 3;
    return average.toStringAsFixed(2);
  }

  String getDate(DateTime string) {
    // dd - mm - yy
    return "${string.day} - ${string.month} - ${string.year}";
  }

  List<Test> getHandTests({required String hand, required bool isAscending}) {
    List<Test> handTests = [];
    try {
      for (var test in tests!) {
        if (test.hand == hand) {
          handTests.add(test);
        }
      }
      // we need to sort the handTest, in decreasing order of createdAt
      if (!isAscending) {
        handTests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        handTests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
    } catch (e) {
      print(e);
    }
    return handTests;
  }

  Map<String, dynamic> getChartData(String hand) {
    if (tests == null || tests!.isEmpty) return {'spots': <FlSpot>[], 'labels': <String>[], 'barGroups': <BarChartGroupData>[]};
    
    final handTests = getHandTests(hand: hand, isAscending: true);
    if (handTests.isEmpty) return {'spots': <FlSpot>[], 'labels': <String>[], 'barGroups': <BarChartGroupData>[]};

    final Map<String, List<double>> groupedData = {};
    final DateFormat formatter = _getFormatterForPeriod(_selectedPeriod);

    for (var t in handTests) {
      final key = formatter.format(t.createdAt);
      final avg = (double.parse(t.trial1) + double.parse(t.trial2) + double.parse(t.trial3)) / 3;
      groupedData.putIfAbsent(key, () => []).add(avg);
    }

    final sortedKeys = groupedData.keys.toList();
    // Sort keys based on date if period is month or week
    if (_selectedPeriod == ChartPeriod.month) {
       sortedKeys.sort((a, b) {
         final d1 = DateFormat('MMM yy').parse(a);
         final d2 = DateFormat('MMM yy').parse(b);
         return d1.compareTo(d2);
       });
    }

    final List<FlSpot> spots = [];
    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final values = groupedData[key]!;
      final avg = values.reduce((a, b) => a + b) / values.length;
      
      spots.add(FlSpot(i.toDouble(), avg));
      labels.add(key);
      
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: avg,
            color: hand == "Right" ? const Color(0xFF00796B) : const Color(0xFF1976D2), // kcPrimaryColor/kcSecondaryColor
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ));
    }

    return {'spots': spots, 'labels': labels, 'barGroups': barGroups};
  }

  DateFormat _getFormatterForPeriod(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.week:
        return DateFormat('dd MMM');
      case ChartPeriod.year:
        return DateFormat('yyyy');
      case ChartPeriod.month:
        return DateFormat('MMM yy');
    }
  }

  String getLatestTestAverage({required String hand}) {
    List<Test> handTests = getHandTests(hand: hand, isAscending: false);
    if (handTests.isEmpty) return "unavailable";
    final latestTest = handTests.first;
    return calculateAverage(latestTest);
  }

  String getLatestAverageDifference() {
    List<Test> rightHandTests = getHandTests(hand: "Right", isAscending: false);
    List<Test> leftHandTests = getHandTests(hand: "Left", isAscending: false);
    if (rightHandTests.isEmpty || leftHandTests.isEmpty) return "unavailable";
    final leftHandLatestTest = leftHandTests.first;
    final rightHandLatestTest = rightHandTests.first;
    final double leftHandAverage =
        double.parse(calculateAverage(leftHandLatestTest));
    final double rightHandAverage =
        double.parse(calculateAverage(rightHandLatestTest));
    final double difference = leftHandAverage - rightHandAverage;
    return difference.toStringAsFixed(2);
  }

  double getMaxAverageOfLastTest() {
    List<Test> rightHandTests = getHandTests(hand: "Right", isAscending: false);
    List<Test> leftHandTests = getHandTests(hand: "Left", isAscending: false);
    double leftHandAverage = 0;
    double rightHandAverage = 0;
    if (leftHandTests.isEmpty) {
      final rightHandLatestTest = rightHandTests.first;
      rightHandAverage = double.parse(calculateAverage(rightHandLatestTest));
      return rightHandAverage;
    }
    if (rightHandTests.isEmpty) {
      final leftHandLatestTest = leftHandTests.first;
      leftHandAverage = double.parse(calculateAverage(leftHandLatestTest));
      return leftHandAverage;
    }

    return leftHandAverage > rightHandAverage
        ? leftHandAverage
        : rightHandAverage;
  }

  double getMinAverageOfLastTest() {
    List<Test> rightHandTests = getHandTests(hand: "Right", isAscending: false);
    List<Test> leftHandTests = getHandTests(hand: "Left", isAscending: false);
    final leftHandLatestTest = leftHandTests.first;
    final rightHandLatestTest = rightHandTests.first;
    final double leftHandAverage =
        double.parse(calculateAverage(leftHandLatestTest));
    final double rightHandAverage =
        double.parse(calculateAverage(rightHandLatestTest));
    return leftHandAverage < rightHandAverage
        ? leftHandAverage
        : rightHandAverage;
  }

  final _accountService = locator<AccountsService>();
  getDominantHand({int? patientId}) async {
    final profile =
        await _accountService.getAccountDetails(patientUserId: patientId);
    dominantHand = profile.dominantHand;
    rebuildUi();
    return dominantHand;
  }

  Future<void> deleteTest({required int id, required int assessmentId}) async {
    await _apiCallsService.deleteTest(id: id);
    await init(assessmentId: assessmentId);
    rebuildUi();
  }

  void generatePDF({required int assessmentId, int? patientId}) async {
    setBusy(true);
    try {
      final Profile profile = await _accountService.getAccountDetails(patientUserId: patientId);

      // Re-fetch to ensure latest data is included (e.g. just-completed test)
      final List<Test> freshTests = await _apiCallsService.getAllAssessmentTests(
          assessmentId: assessmentId);

      // Merge: use fresh fetch but fall back to already-loaded tests if fresh is empty
      final List<Test> tests = freshTests.isNotEmpty
          ? freshTests
          : (this.tests ?? []);

      if (tests.isEmpty) {
        setBusy(false);
        return;
      }

      final pdf = pw.Document();
      const customBlue = PdfColor.fromInt(0xFFBCD5DF);
      
      // Right hand tests
      final rightTests = tests.where((t) => t.hand == "Right").toList();
      final leftTests = tests.where((t) => t.hand == "Left").toList();
      
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            pw.Center(
               child: pw.Text("VITAL STEP", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text("ASSESSMENT HISTORY", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ["Patient's Detail", ""],
              data: [
                ["Patient's Name", (profile.name ?? 'User')],
                ["Assessment ID", assessmentId.toString()],
                ["Date", DateFormat('yyyy-MM-dd').format(DateTime.now())],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text("1. Right Hand Table", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.TableHelper.fromTextArray(
              headers: ["ID", "Date", "Trial 1", "Trial 2", "Trial 3", "Average"],
              data: rightTests.map((t) => [
                t.id.toString(),
                getDate(t.createdAt),
                t.trial1,
                t.trial2,
                t.trial3,
                calculateAverage(t)
              ]).toList(),
              headerDecoration: const pw.BoxDecoration(color: customBlue),
            ),
            pw.SizedBox(height: 20),
            pw.Text("2. Left Hand Table", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.TableHelper.fromTextArray(
              headers: ["ID", "Date", "Trial 1", "Trial 2", "Trial 3", "Average"],
              data: leftTests.map((t) => [
                t.id.toString(),
                getDate(t.createdAt),
                t.trial1,
                t.trial2,
                t.trial3,
                calculateAverage(t)
              ]).toList(),
              headerDecoration: const pw.BoxDecoration(color: customBlue),
            ),
            pw.SizedBox(height: 20),
            pw.Text("3. Latest Assessment Summary", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.TableHelper.fromTextArray(
              headers: ["Hand", "Date", "Trial 1", "Trial 2", "Trial 3", "Average"],
              data: [
                if (rightTests.isNotEmpty) () {
                  final t = rightTests.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
                  return ["Right", getDate(t.createdAt), t.trial1, t.trial2, t.trial3, calculateAverage(t)];
                }(),
                if (leftTests.isNotEmpty) () {
                  final t = leftTests.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
                  return ["Left", getDate(t.createdAt), t.trial1, t.trial2, t.trial3, calculateAverage(t)];
                }(),
              ],
              headerDecoration: const pw.BoxDecoration(color: customBlue),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'VitalStep_Assessment_${assessmentId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf'
      );
    } catch (e) {
      print("Error generating PDF: $e");
    }
    setBusy(false);
  }
}
