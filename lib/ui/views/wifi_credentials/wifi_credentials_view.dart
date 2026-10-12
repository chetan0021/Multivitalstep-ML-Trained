import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'wifi_credentials_viewmodel.dart';

class WifiCredentialsView extends StackedView<WifiCredentialsViewModel> {
  final String ssid;
  const WifiCredentialsView({Key? key, required this.ssid}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    WifiCredentialsViewModel viewModel,
    Widget? child,
  ) {
    bool isConnected = viewModel.wifiProvisionStatus.startsWith('CONNECTED');
    bool isFailed = viewModel.wifiProvisionStatus.startsWith('FAILED');
    bool isConnecting = viewModel.wifiProvisionStatus.startsWith('CONNECTING') || viewModel.isBusy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Credentials'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (viewModel.isManualEntry) ...[
              const Text('Network Name (SSID)'),
              verticalSpaceSmall,
              TextField(
                controller: viewModel.ssidController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter SSID',
                ),
              ),
              verticalSpaceMedium,
            ] else ...[
              Text(
                'Connecting to: ${viewModel.ssid}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              verticalSpaceMedium,
            ],
            const Text('Password (leave empty if open)'),
            verticalSpaceSmall,
            TextField(
              controller: viewModel.passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Password',
              ),
            ),
            verticalSpaceLarge,
            if (isConnecting)
              const Center(child: CircularProgressIndicator())
            else if (isConnected) ...[
              const Center(
                child: Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              verticalSpaceMedium,
              Center(
                child: Text(
                  'Successfully connected!\n${viewModel.wifiProvisionStatus}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              verticalSpaceLarge,
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.complete,
                  child: const Text('Done'),
                ),
              )
            ] else if (isFailed) ...[
              const Center(
                child: Icon(Icons.error, color: Colors.red, size: 64),
              ),
              verticalSpaceMedium,
              Center(
                child: Text(
                  'Connection Failed: ${viewModel.wifiProvisionStatus}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
              verticalSpaceLarge,
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.provisionWifi,
                  child: const Text('Retry'),
                ),
              )
            ] else ...[
              if (viewModel.wifiProvisionStatus.isNotEmpty) ...[
                Center(child: Text(viewModel.wifiProvisionStatus)),
                verticalSpaceMedium,
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.provisionWifi,
                  child: const Text('Send Credentials'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  WifiCredentialsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      WifiCredentialsViewModel(ssid);
}
