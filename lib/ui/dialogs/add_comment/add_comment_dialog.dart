import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'add_comment_dialog_model.dart';

class AddCommentDialog extends StackedView<AddCommentDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const AddCommentDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AddCommentDialogModel viewModel,
    Widget? child,
  ) {
    final assessment = Assessment.fromJson(request.data);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Create Remark",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            verticalSpaceMedium,
            TextFormField(
              controller: viewModel.remarkController,
              minLines: 3,
              maxLines: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: () {
                    completer(DialogResponse(confirmed: false));
                  },
                  child: const Text("Cancel"),
                ),
                MaterialButton(
                  onPressed: () async {
                    try {
                      if (await viewModel.submitComment(
                          assessmentId: assessment.id,
                          comment: viewModel.remarkController.text)) {
                        return completer(DialogResponse(confirmed: true));
                      }
                    } catch (e) {
                      Fluttertoast.showToast(
                          msg: "Unable to add the comment, ${e.toString()}");
                    }
                  },
                  child: const Text("Submit"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  AddCommentDialogModel viewModelBuilder(BuildContext context) =>
      AddCommentDialogModel();
}
