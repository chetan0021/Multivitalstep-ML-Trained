import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'set_reminder_dialog_model.dart';

const double _graphicSize = 60;

class SetReminderDialog extends StackedView<SetReminderDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const SetReminderDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SetReminderDialogModel viewModel,
    Widget? child,
  ) {
    final Assessment assessment = Assessment.fromJson(request.data);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Reminder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(viewModel.selectedDateTime == null
                ? 'No date and time selected!'
                : 'Selected: ${viewModel.getDateAndTime(viewModel.selectedDateTime)}'),
            verticalSpaceSmall,
            GestureDetector(
              onTap: () {
                viewModel.selectDate(context);
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Select start date and time ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            verticalSpaceSmall,
            GestureDetector(
              onTap: () async {
                try {
                  if (viewModel.selectedDateTime == null) {
                    Fluttertoast.showToast(
                        msg: 'Please select a date and time');
                    return;
                  }
                  await viewModel.setReminder(
                    assessment: assessment,
                    selectedDateTime: viewModel.selectedDateTime!,
                  );
                  completer(DialogResponse(confirmed: true));
                } catch (e) {
                  print("Error in setting reminder ${e.toString()}");
                  completer(DialogResponse(confirmed: false));
                  Fluttertoast.showToast(msg: "Failed to set reminder");
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  SetReminderDialogModel viewModelBuilder(BuildContext context) =>
      SetReminderDialogModel();
}
