import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/ScreenHeading.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/widgets/common/graph_segment/graph_segment.dart';
import 'package:vital_step/ui/widgets/common/tabular_segment/tabular_segment.dart';

import 'report_viewmodel.dart';

class ReportView extends StackedView<ReportViewModel> {
  const ReportView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ReportViewModel viewModel,
    Widget? child,
  ) {
    final List<String> options = ["Graph", "Data"];
    final List<String> periods = ['7 days', '1 month', '6 months', 'custom'];

    // Sample data for the table
    final List<Map<String, dynamic>> sampleData = [
      {'week': 1, 'left': 40, 'right': 37, 'fbw_diff': 3},
      {'week': 2, 'left': 45, 'right': 34, 'fbw_diff': 11},
      {'week': 3, 'left': 43, 'right': 42, 'fbw_diff': 1},
      {'week': 4, 'left': 46, 'right': 41, 'fbw_diff': 5},
      {'week': 5, 'left': 46, 'right': 37, 'fbw_diff': 9},
      {'week': 6, 'left': 46, 'right': 46, 'fbw_diff': 0},
      {'week': 7, 'left': 46, 'right': 46, 'fbw_diff': 0},
    ];

    List<String> durationType = ["7 days", "1month", "custom"];

    DateTime? fromDate;
    DateTime? toDate;
    Future<void> selectDate(BuildContext context, bool isFromDate) async {
      DateTime initialDate = isFromDate
          ? (viewModel.fromDate ?? DateTime.now())
          : (viewModel.toDate ?? DateTime.now());
      DateTime firstDate = DateTime(2000);
      DateTime lastDate = DateTime(2101);

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
      if (picked != null) {
        if (isFromDate) {
          viewModel.setCustomDates(picked, viewModel.toDate ?? DateTime.now());
        } else {
          viewModel.setCustomDates(viewModel.fromDate ?? DateTime.now(), picked);
        }
      }
    }

    return Column(
      children: [
        ScreenHeading(
          heading: "Report",
          showBackButton: false,
        ),
        DropdownButton<String>(
          value: viewModel.selectedPeriod,
          hint: const Text('Select a period'),
          onChanged: (String? newValue) {
            if (newValue != null) {
              if (newValue == 'custom') {
                showCustomDateRangeDialog(context, viewModel);
              } else {
                viewModel.updatePeriod(newValue);
              }
            }
          },
          items: periods.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => selectDate(context, true),
              child: Text(viewModel.fromDate == null
                  ? 'Select From Date'
                  : 'From: ${viewModel.fromDate.toString().split(' ')[0]}'),
            ),
            ElevatedButton(
              onPressed: () => selectDate(context, false),
              child: Text(viewModel.toDate == null
                  ? 'Select To Date'
                  : 'To: ${viewModel.toDate.toString().split(' ')[0]}'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(width: 1, color: Colors.grey)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: options.map((option) {
              return GestureDetector(
                onTap: () {
                  viewModel.updateSelectedOption(option);
                },
                child: Container(
                  height: 30,
                  width: ((MediaQuery.of(context).size.width - 42) /
                      options.length),
                  decoration: BoxDecoration(
                    color: option == viewModel.selectedOption
                        ? kcPrimaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        color: option == viewModel.selectedOption
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (viewModel.isBusy)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else ...[
          if (viewModel.reportData.isEmpty)
            const Expanded(
                child: Center(child: Text("No data found for this period")))
          else ...[
            viewModel.selectedOption == "Graph"
                ? GraphSegment(data: viewModel.reportData)
                : Expanded(child: TabularSegment(data: viewModel.reportData)),
          ]
        ]
      ],
    );
  }

  @override
  void onViewModelReady(ReportViewModel viewModel) {
    viewModel.init();
  }

  @override
  ReportViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ReportViewModel();

  void showCustomDateRangeDialog(BuildContext context, ReportViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Custom Date Range'),
          content: const Text('Implement custom date range selection here.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
