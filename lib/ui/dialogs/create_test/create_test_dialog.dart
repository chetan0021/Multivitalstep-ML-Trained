import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'create_test_dialog_model.dart';

const double _graphicSize = 60;

class CreateTestDialog extends StackedView<CreateTestDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const CreateTestDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CreateTestDialogModel viewModel,
    Widget? child,
  ) {
    dynamic data = request.data;
    Assessment assessment;
    if (data is Map<String, dynamic> && data.containsKey('assessment')) {
      assessment = Assessment.fromJson(data['assessment']);
    } else {
      assessment = Assessment.fromJson(data);
    }
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpaceSmall,
            const Text(
              'Select hand',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Row(
              children: [
                Checkbox(
                    value: viewModel.hand == "Right" ? true : false,
                    onChanged: (val) {
                      viewModel.hand = "Right";
                      viewModel.rebuildUi();
                    }),
                horizontalSpaceSmall,
                const Text("Right"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                    value: viewModel.hand == "Left" ? true : false,
                    onChanged: (val) {
                      viewModel.hand = "Left";
                      viewModel.rebuildUi();
                    }),
                horizontalSpaceSmall,
                const Text("Left"),
              ],
            ),
            verticalSpaceSmall,
            const Text(
              'Select the device',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            FutureBuilder<List<Device>?>(
              future: viewModel.devicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text("Error fetching devices");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No devices found");
                } else {
                  final devices = snapshot.data!;
                  final List<String> deviceNames =
                      devices.map((device) => device.deviceName).toList();
                  return SizedBox(
                    width: double.infinity,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: viewModel.dropDownValue,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (String? newValue) {
                        viewModel.dropDownValue = newValue!;
                        viewModel.deviceId = devices
                            .firstWhere(
                                (device) => device.deviceName == newValue)
                            .id
                            .toString();
                        viewModel.rebuildUi();
                      },
                      items: deviceNames
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
            verticalSpaceLarge,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => completer(DialogResponse(confirmed: false)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      side: const BorderSide(color: kcMediumGrey),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: kcDarkGreyColor)),
                  ),
                ),
                horizontalSpaceSmall,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (viewModel.hand == null || viewModel.deviceId == null) {
                        Fluttertoast.showToast(msg: "Please select hand and device");
                        return;
                      }

                      final testResponse = await viewModel.createTest(
                          assessment, viewModel.hand!, viewModel.deviceId!);
                      if (testResponse) {
                        completer(DialogResponse(confirmed: true));
                        NavigationService()
                            .navigateToTestTakingView(assessment: assessment);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                    ),
                    child: viewModel.isBusy
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Start Test',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: kcMediumGrey),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kcPrimaryColor),
        ),
      ),
    );
  }

  Widget _buildHandOption(BuildContext context, CreateTestDialogModel viewModel,
      String hand, IconData icon) {
    return Row(
      children: [
        Checkbox(
            value: viewModel.hand == hand ? true : false,
            onChanged: (val) {
              viewModel.hand = hand;
              viewModel.rebuildUi();
            }),
        horizontalSpaceSmall,
        Text(hand),
      ],
    );
  }

  @override
  CreateTestDialogModel viewModelBuilder(BuildContext context) =>
      CreateTestDialogModel();
  @override
  void onViewModelReady(CreateTestDialogModel viewModel) async {
    String? hand;
    if (request.data is Map<String, dynamic> &&
        (request.data as Map<String, dynamic>).containsKey('hand')) {
      hand = (request.data as Map<String, dynamic>)['hand'];
    }
    viewModel.devicesFuture = viewModel.init(preSelectedHand: hand);
  }
}
