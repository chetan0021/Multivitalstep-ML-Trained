import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/ui/dialogs/reset_password/reset_password_dialog.form.dart';

import 'reset_password_dialog_model.dart';

@FormView(fields: [
  FormTextField(
    name: "email",
  ),
])
class ResetPasswordDialog extends StackedView<ResetPasswordDialogModel>
    with $ResetPasswordDialog {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ResetPasswordDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ResetPasswordDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Form(
        key: viewModel.key,
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Forgot Password ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                verticalSpaceMedium,
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    labelText: 'Email',
                    hintText: "Enter your registered email ",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  controller: emailController,
                ),
                verticalSpaceSmall,
                const Text(
                  "just enter your email & we'll send you a temporarily password directly to your inbox so you can log in again easily..",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8),
                ),
                verticalSpaceMedium,
                SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (viewModel.busy(viewModel.resettingPassword)) {
                            return;
                          } else {
                            await viewModel.resetPassword();
                          }
                          completer(DialogResponse(confirmed: true));
                        },
                        child: Container(
                          height: 50,
                          width: 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: kcPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: viewModel.busy(viewModel.resettingPassword)
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Send Password over Email',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpaceMedium,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  ResetPasswordDialogModel viewModelBuilder(BuildContext context) =>
      ResetPasswordDialogModel();

  @override
  void onViewModelReady(ResetPasswordDialogModel viewModel) {
    syncFormWithViewModel(viewModel);
  }
}
