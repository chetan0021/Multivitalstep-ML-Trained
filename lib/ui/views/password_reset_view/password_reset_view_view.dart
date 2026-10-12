import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:vital_step/ui/views/password_reset_view/password_reset_view_view.form.dart';

import 'password_reset_view_viewmodel.dart';

@FormView(fields: [
  FormTextField(
    name: 'email',
  ),
])
class PasswordResetViewView extends StackedView<PasswordResetViewViewModel>
    with $PasswordResetViewView {
  const PasswordResetViewView({Key? key}) : super(key: key);
  static const List<String> _userTypes = ['Specialist', 'Patient'];
  @override
  Widget builder(
    BuildContext context,
    PasswordResetViewViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: viewModel.key,
            child: SizedBox(
              width: 300,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    DropdownButtonFormField<String>(
                      value: viewModel.selectedUserType,
                      decoration: const InputDecoration(
                        labelText: 'Select User Type',
                        fillColor: Color.fromARGB(33, 158, 158, 158),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      items: _userTypes.map((String userType) {
                        return DropdownMenuItem<String>(
                          value: userType,
                          child: Text(userType),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        viewModel.selectedUserType = newValue!;
                        viewModel.notifyListeners();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a user type';
                        }
                        return null;
                      },
                    ),
                    verticalSpaceMedium,
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
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
                              // completer(DialogResponse(confirmed: true));
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
        ),
      ),
    );
  }

  @override
  PasswordResetViewViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PasswordResetViewViewModel();

  @override
  void onViewModelReady(PasswordResetViewViewModel viewModel) {
    syncFormWithViewModel(viewModel);
  }
}
