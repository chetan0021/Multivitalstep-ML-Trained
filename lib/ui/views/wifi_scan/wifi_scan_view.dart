import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'wifi_scan_viewmodel.dart';

class WifiScanView extends StackedView<WifiScanViewModel> {
  const WifiScanView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    WifiScanViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Wi-Fi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: viewModel.cancel,
        ),
      ),
      body: viewModel.isScanningWifi
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  verticalSpaceMedium,
                  Text('Scanning for nearby networks...'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.scannedNetworks.length,
                    itemBuilder: (context, index) {
                      final net = viewModel.scannedNetworks[index];
                      final ssid = net['ssid'] as String;
                      final isSecure = net['secure'] == true;
                      
                      return ListTile(
                        leading: const Icon(Icons.wifi, color: kcPrimaryColor),
                        title: Text(ssid),
                        trailing: isSecure ? const Icon(Icons.lock, size: 16) : null,
                        onTap: () => viewModel.selectNetwork(ssid),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Enter Wi-Fi manually'),
                    onPressed: viewModel.enterManualNetwork,
                  ),
                )
              ],
            ),
    );
  }

  @override
  WifiScanViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      WifiScanViewModel();

  @override
  void onViewModelReady(WifiScanViewModel viewModel) {
    viewModel.startWifiScan();
  }
}
