import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors.dart';

import 'tabular_segment_model.dart';

class TabularSegment extends StackedView<TabularSegmentModel> {
  final List<Map<String, dynamic>> data;
  const TabularSegment({super.key, required this.data});

  @override
  Widget builder(
    BuildContext context,
    TabularSegmentModel viewModel,
    Widget? child,
  ) {
    return Expanded(
      child: Container(
        color: kcPrimaryColor.withAlpha(30),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Weekly')),
                DataColumn(label: Text('1')),
                DataColumn(label: Text('2')),
                DataColumn(label: Text('3')),
                DataColumn(label: Text('4')),
                DataColumn(label: Text('5')),
                DataColumn(label: Text('6')),
                DataColumn(label: Text('7')),
              ],
              rows: data.map((row) {
                return DataRow(cells: [
                  DataCell(Text(row['week'].toString())),
                  DataCell(Text(row['left'].toString())),
                  DataCell(Text(row['right'].toString())),
                  DataCell(Text(row['fbw_diff'].toString())),
                  DataCell(Text(row['week'].toString())),
                  DataCell(Text(row['left'].toString())),
                  DataCell(Text(row['right'].toString())),
                  DataCell(Text(row['fbw_diff'].toString())),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  TabularSegmentModel viewModelBuilder(
    BuildContext context,
  ) =>
      TabularSegmentModel();
}
