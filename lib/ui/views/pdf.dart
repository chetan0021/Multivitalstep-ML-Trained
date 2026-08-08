import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class HandTestData {
  final String id;
  final String date;
  final double trial1;
  final double trial2;
  final double? trial3;
  final double average;

  HandTestData({
    required this.id,
    required this.date,
    required this.trial1,
    required this.trial2,
    this.trial3,
    required this.average,
  });
}

class GraphData {
  final double rightHand;
  final double leftHand;
  final double difference;

  GraphData({
    required this.rightHand,
    required this.leftHand,
    required this.difference,
  });
}

class AssessmentHistoryPage extends StatefulWidget {
  const AssessmentHistoryPage({super.key});

  @override
  _AssessmentHistoryPageState createState() => _AssessmentHistoryPageState();
}

class _AssessmentHistoryPageState extends State<AssessmentHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _graph1Key = GlobalKey();
  final GlobalKey _graph2Key = GlobalKey();

  final List<HandTestData> rightHandData = [
    HandTestData(
        id: '58',
        date: '2024-09-23',
        trial1: 1.497,
        trial2: 5.401,
        trial3: null,
        average: 3.449),
  ];

  final List<HandTestData> leftHandData = [
    HandTestData(
        id: '60',
        date: '2024-09-23',
        trial1: 3.230,
        trial2: 2.337,
        trial3: null,
        average: 2.784),
    HandTestData(
        id: '56',
        date: '2024-09-23',
        trial1: 1.670,
        trial2: 1.646,
        trial3: null,
        average: 1.658),
  ];

  final GraphData graphData =
      GraphData(rightHand: 3.93, leftHand: 2.38, difference: -1.55);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    const customBlue = PdfColor.fromInt(0xFFBCD5DF);
    final logoImage = await imageFromAssetBundle('assets/images/logo.jpeg');
    await Future.delayed(const Duration(milliseconds: 500));

    final tableImage = await _captureWidgetAsImage(_graph1Key);
    final graphImage = await _captureWidgetAsImage(_graph2Key);

    if (tableImage == null || graphImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error capturing graphs. Please try again.')),
      );
      return;
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child:
                  pw.Image(pw.MemoryImage(logoImage), width: 80, height: 80),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                "VITAL STEP",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                "ASSESSMENT HISTORY",
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ["Patient's Detail", ""],
              data: [
                ["Patient's Name", "John Doe"],
                ["Assessment", "Hand Strength Test"],
                ["Date", "2024-09-24"],
                ["Time", "14:30"],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text("1. Right Hand Table",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.TableHelper.fromTextArray(
              headers: [
                "ID",
                "Date",
                "Trial 1 (Kg)",
                "Trial 2 (Kg)",
                "Trial 3 (Kg)",
                "Average"
              ],
              data: rightHandData
                  .map((data) => [
                        data.id,
                        data.date,
                        data.trial1.toString(),
                        data.trial2.toString(),
                        data.trial3?.toString() ?? "-",
                        data.average.toString()
                      ])
                  .toList(),
              headerDecoration: const pw.BoxDecoration(color: customBlue),
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
            ),
            pw.SizedBox(height: 20),
            pw.Text("2. Left Hand Table",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.TableHelper.fromTextArray(
              headers: [
                "ID",
                "Date",
                "Trial 1 (Kg)",
                "Trial 2 (Kg)",
                "Trial 3 (Kg)",
                "Average"
              ],
              data: leftHandData
                  .map((data) => [
                        data.id,
                        data.date,
                        data.trial1.toString(),
                        data.trial2.toString(),
                        data.trial3?.toString() ?? "-",
                        data.average.toString()
                      ])
                  .toList(),
              headerDecoration: const pw.BoxDecoration(color: customBlue),
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
            ),
            pw.SizedBox(height: 20),
            pw.Text("3. Latest Test Difference",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.TableHelper.fromTextArray(
              headers: ["Right Hand", "Left Hand", "Difference"],
              data: [
                [
                  graphData.rightHand.toString(),
                  graphData.leftHand.toString(),
                  graphData.difference.toString()
                ]
              ],
              headerDecoration: const pw.BoxDecoration(color: customBlue),
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("4. Graph",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Image(pw.MemoryImage(tableImage),
                width: double.infinity, height: 200),
            pw.SizedBox(height: 20),
            pw.Text("5. Latest Test Graph",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Image(pw.MemoryImage(graphImage),
                width: double.infinity, height: 200),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<Uint8List> imageFromAssetBundle(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List?> _captureWidgetAsImage(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing image: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assessment History"),
        actions: const [
          // IconButton(
          //   icon: const Icon(Icons.picture_as_pdf),
          //   onPressed: _generatePdf,
          // ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Table"),
            Tab(text: "Graph"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Table View
          tableView(),
          // Graph View
          graphView(),
        ],
      ),
    );
  }

  Widget tableView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Right Hand Table",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DataTable(
            columns: const [
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Trial 1 (Kg)")),
              DataColumn(label: Text("Trial 2 (Kg)")),
            ],
            rows: rightHandData
                .map(
                  (data) => DataRow(
                    cells: [
                      DataCell(Text(data.id)),
                      DataCell(Text(data.trial1.toString())),
                      DataCell(Text(data.trial2.toString())),
                    ],
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text("Left Hand Table",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DataTable(
            columns: const [
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Trial 1 (Kg)")),
              DataColumn(label: Text("Trial 2 (Kg)")),
            ],
            rows: leftHandData
                .map(
                  (data) => DataRow(
                    cells: [
                      DataCell(Text(data.id)),
                      DataCell(Text(data.trial1.toString())),
                      DataCell(Text(data.trial2.toString())),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget graphView() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Right Hand Graph",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RepaintBoundary(
              key: _graph1Key,
              child: SizedBox(
                height: 200,
                child: LineChart(LineChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.red,
                      spots: rightHandData
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                              (entry.key + 1).toDouble(), entry.value.average))
                          .toList(),
                      dotData: const FlDotData(show: true),
                    )
                  ],
                )),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Latest Test Graph",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RepaintBoundary(
              key: _graph2Key,
              child: SizedBox(
                height: 200,
                child: BarChart(BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: graphData.rightHand, color: Colors.green),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(
                          toY: graphData.leftHand, color: Colors.green),
                    ]),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
