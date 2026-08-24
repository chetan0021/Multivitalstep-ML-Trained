import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/ble_provisioning_service.dart';
import 'package:stacked_services/stacked_services.dart';

class WifiCredentialsViewModel extends ReactiveViewModel {
  final _bleService = locator<BleProvisioningService>();
  final _navigationService = locator<NavigationService>();

  final String ssid;
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();

  WifiCredentialsViewModel(this.ssid) {
    if (ssid.isNotEmpty) {
      ssidController.text = ssid;
    }
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_bleService];

  String get wifiProvisionStatus => _bleService.wifiProvisionStatus.value;
  bool get isManualEntry => ssid.isEmpty;

  void provisionWifi() async {
    final s = ssidController.text.trim();
    final p = passwordController.text;
    
    if (s.isEmpty) {
      // Show error? For now just return
      return;
    }

    try {
      setBusy(true);
      await _bleService.sendWifiCredentials(s, p);
      setBusy(false);
    } catch (e) {
      print('Provisioning error: $e');
      setBusy(false);
    }
  }

  void complete() {
    _bleService.disconnect();
    _navigationService.clearStackAndShow(Routes.homeView);
  }

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
