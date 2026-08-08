import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'existing_devices_model.dart';

class ExistingDevices extends StackedView<ExistingDevicesModel> {
  const ExistingDevices({super.key});

  @override
  Widget builder(
    BuildContext context,
    ExistingDevicesModel viewModel,
    Widget? child,
  ) {
    return FutureBuilder<List<String>?>(
      future: viewModel.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
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
          return SizedBox(
            height: devices.length * 50.0,
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: devices.length,
                itemBuilder: (BuildContext buildContext, int index) {
                  return ListTile(
                    leading: Text((index + 1).toString()),
                    title: Text(devices[index]),
                  );
                }),
          );
        }
      },
    );
  }

  @override
  ExistingDevicesModel viewModelBuilder(
    BuildContext context,
  ) =>
      ExistingDevicesModel();
}
