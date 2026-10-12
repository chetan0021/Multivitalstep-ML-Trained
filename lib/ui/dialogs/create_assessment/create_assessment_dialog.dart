import 'package:flutter/material.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'create_assessment_dialog_model.dart';

class CreateAssessmentDialog extends StackedView<CreateAssessmentDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const CreateAssessmentDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CreateAssessmentDialogModel viewModel,
    Widget? child,
  ) {
    final patientId = request.data;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Assessment",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      verticalSpaceMedium,
                      DropdownButtonFormField<String>(
                        value: viewModel.selectedAssessmentType,
                        decoration: const InputDecoration(
                          labelText: 'Select Assessment Type',
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
                        items: viewModel.assessmentTypes.map((String userType) {
                          return DropdownMenuItem<String>(
                            value: userType,
                            child: Text(userType),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          viewModel.selectedAssessmentType = newValue!;
                          viewModel.notifyListeners();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a user type';
                          }
                          return null;
                        },
                      ),
                      verticalSpaceSmall,
                      DropdownButtonFormField<String>(
                        value: viewModel.selectedPosture,
                        decoration: const InputDecoration(
                          labelText: 'Select Posture',
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
                        items: viewModel.postureTypes.map((String userType) {
                          return DropdownMenuItem<String>(
                            value: userType,
                            child: Text(userType),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          viewModel.selectedPosture = newValue!;
                          viewModel.notifyListeners();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a Posture type';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => completer(DialogResponse(confirmed: false)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: kcMediumGrey),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: kcDarkGreyColor)),
                  ),
                ),
                horizontalSpaceSmall,
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (await viewModel.createAssessment(patientId) == true) {
                        return completer(DialogResponse(confirmed: true));
                      }
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: viewModel.isBusy
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  CreateAssessmentDialogModel viewModelBuilder(BuildContext context) =>
      CreateAssessmentDialogModel();
}
