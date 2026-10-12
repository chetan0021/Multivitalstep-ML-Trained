import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/ble_provisioning_service.dart';
import 'package:stacked_services/stacked_services.dart';

class WifiScanViewModel extends ReactiveViewModel {
  final _bleService = locator<BleProvisioningService>();
  final _navigationService = locator<NavigationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_bleService];

  List<Map<String, dynamic>> get scannedNetworks => _bleService.scannedNetworks;
  bool get isScanningWifi => _bleService.isScanningWifi.value;

  void startWifiScan() async {
    try {
      await _bleService.requestWifiScan();
    } catch (e) {
      print('Wi-Fi Scan request error: $e');
    }
  }

  void selectNetwork(String ssid) {
    _navigationService.navigateToWifiCredentialsView(ssid: ssid);
  }

  void enterManualNetwork() {
    _navigationService.navigateToWifiCredentialsView(ssid: '');
  }

  void cancel() {
    _bleService.disconnect();
    _navigationService.back();
  }
}
