import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/ui/dialogs/add_patient/add_patient_dialog.form.dart';

import 'add_patient_dialog_model.dart';

const double _graphicSize = 60;

@FormView(fields: [
  FormTextField(name: "email"),
  FormTextField(name: "accessCode"),
])
class AddPatientDialog extends StackedView<AddPatientDialogModel>
    with $AddPatientDialog {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const AddPatientDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AddPatientDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                hintText: "Please enter patient's email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              controller: emailController,
            ),
            verticalSpaceSmall,
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                labelText: 'Access Code',
                hintText: "Please enter patient's access code",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              controller: accessCodeController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                    onPressed: () {
                      completer(DialogResponse(confirmed: false));
                    },
                    child: const Text("Cancel")),
                const SizedBox(width: 10),
                MaterialButton(
                  onPressed: () async {
                    await viewModel.addPatient();
                  },
                  child: const Text('Add Patient'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  AddPatientDialogModel viewModelBuilder(BuildContext context) =>
      AddPatientDialogModel();

  @override
  void onViewModelReady(AddPatientDialogModel viewModel) {
    syncFormWithViewModel(viewModel);
  }
}
