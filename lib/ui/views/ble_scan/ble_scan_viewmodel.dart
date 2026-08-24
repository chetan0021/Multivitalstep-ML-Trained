import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/ble_provisioning_service.dart';
import 'package:stacked_services/stacked_services.dart';

class BleScanViewModel extends ReactiveViewModel {
  final _bleService = locator<BleProvisioningService>();
  final _navigationService = locator<NavigationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_bleService];

  List<ScanResult> get discoveredDevices => _bleService.discoveredDevices;
  String get connectionStatus => _bleService.connectionStatus.value;
  bool get isScanning => FlutterBluePlus.isScanningNow;

  void startScan() async {
    try {
      await _bleService.startBleScan();
      notifyListeners();
    } catch (e) {
      print('Scan error: $e');
    }
  }

  void stopScan() async {
    await _bleService.stopBleScan();
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await _bleService.stopBleScan();
    try {
      setBusy(true);
      await _bleService.connectToDevice(device);
      setBusy(false);
      // Navigate to Wi-Fi scan view
      _navigationService.navigateToWifiScanView();
    } catch (e) {
      setBusy(false);
      print('Connect error: $e');
    }
  }

  @override
  void dispose() {
    _bleService.stopBleScan();
    super.dispose();
  }
}
