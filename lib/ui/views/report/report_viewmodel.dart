import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/test.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportViewModel extends BaseViewModel {
  final _apiCallsService = locator<ApiCallsService>();

  List<Test> _userTests = [];
  List<Test> get userTests => _userTests;

  List<Map<String, dynamic>> reportData = [];

  String selectedOption = "Graph";
  final List<String> periods = ['7 days', '1 month', '6 months', 'custom'];
  String selectedPeriod = '7 days';
  DateTime? fromDate;
  DateTime? toDate;

  Future<void> init() async {
    _userTests = await _apiCallsService.getAllUserTests();
    _filterData();
    notifyListeners();
  }

  void updateSelectedOption(String option) {
    selectedOption = option;
    notifyListeners();
  }

  void updatePeriod(String period) {
    selectedPeriod = period;
    final now = DateTime.now();
    
    if (period == '7 days') {
      fromDate = now.subtract(const Duration(days: 7));
      toDate = now;
    } else if (period == '1 month') {
      fromDate = DateTime(now.year, now.month - 1, now.day);
      toDate = now;
    } else if (period == '6 months') {
      fromDate = DateTime(now.year, now.month - 6, now.day);
      toDate = now;
    }
    
    _filterData();
    notifyListeners();
  }

  void setSelectedOption(String option) {
    selectedOption = option;
    notifyListeners();
  }

  void setCustomDates(DateTime from, DateTime to) {
    fromDate = from;
    toDate = to;
    selectedPeriod = 'custom';
    _filterData();
    notifyListeners();
  }

  void _filterData() {
    if (fromDate == null || toDate == null) return;

    final filtered = _userTests.where((t) => 
      t.createdAt.isAfter(fromDate!) && t.createdAt.isBefore(toDate!.add(const Duration(days: 1)))
    ).toList();

    reportData = filtered.asMap().entries.map((entry) {
      final t = entry.value;
      final avg = (double.parse(t.trial1) + double.parse(t.trial2) + double.parse(t.trial3)) / 3;
      return {
        'week': entry.key + 1,
        'timestamp': t.createdAt,
        'date': t.createdAt,
        'pressure_value': avg,
        'left': t.hand == 'Left' ? avg : 0.0,
        'right': t.hand == 'Right' ? avg : 0.0,
        'fbw_diff': 0.0,
      };
    }).toList();
  }

  List<FlSpot> getGraphData(String hand) {
    final handTests = _userTests.where((t) => t.hand == hand).toList();
    List<FlSpot> spots = [];
    for (int i = 0; i < handTests.length; i++) {
        double avg = (double.parse(handTests[i].trial1) + 
                      double.parse(handTests[i].trial2) + 
                      double.parse(handTests[i].trial3)) / 3;
        spots.add(FlSpot(i.toDouble(), avg));
    }
    return spots;
  }
}
