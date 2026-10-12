import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'ble_scan_viewmodel.dart';

class BleScanView extends StackedView<BleScanViewModel> {
  const BleScanView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    BleScanViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
        actions: [
          IconButton(
            icon: Icon(viewModel.isScanning ? Icons.stop : Icons.refresh),
            onPressed: viewModel.isScanning
                ? viewModel.stopScan
                : viewModel.startScan,
          )
        ],
      ),
      body: viewModel.isBusy
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  verticalSpaceMedium,
                  Text(viewModel.connectionStatus),
                ],
              ),
            )
          : ListView.builder(
              itemCount: viewModel.discoveredDevices.length,
              itemBuilder: (context, index) {
                final result = viewModel.discoveredDevices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth, color: kcPrimaryColor),
                  title: Text(result.device.platformName.isNotEmpty
                      ? result.device.platformName
                      : result.advertisementData.advName),
                  subtitle: Text(result.device.remoteId.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => viewModel.connectToDevice(result.device),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
    );
  }

  @override
  BleScanViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      BleScanViewModel();

  @override
  void onViewModelReady(BleScanViewModel viewModel) {
    viewModel.startScan();
  }
}
