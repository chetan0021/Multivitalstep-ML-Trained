import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:stacked/stacked.dart';

class BleProvisioningService with ListenableServiceMixin {
  // UUIDs from Arduino sketch
  static const String serviceUuid = "6b1a0001-4b4a-4a3f-9f0a-3a2b6c8e1a10";
  static const String wifiScanUuid = "6b1a0002-4b4a-4a3f-9f0a-3a2b6c8e1a10";
  static const String wifiCredsUuid = "6b1a0003-4b4a-4a3f-9f0a-3a2b6c8e1a10";
  static const String wifiStatusUuid = "6b1a0004-4b4a-4a3f-9f0a-3a2b6c8e1a10";

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _scanChar;
  BluetoothCharacteristic? _credsChar;
  BluetoothCharacteristic? _statusChar;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _wifiScanSubscription;
  StreamSubscription<List<int>>? _wifiStatusSubscription;

  ReactiveList<ScanResult> discoveredDevices = ReactiveList<ScanResult>();
  ReactiveList<Map<String, dynamic>> scannedNetworks = ReactiveList<Map<String, dynamic>>();

  ReactiveValue<String> connectionStatus = ReactiveValue<String>('Disconnected');
  ReactiveValue<String> wifiProvisionStatus = ReactiveValue<String>('');
  ReactiveValue<bool> isScanningWifi = ReactiveValue<bool>(false);

  BleProvisioningService() {
    listenToReactiveValues([
      discoveredDevices,
      scannedNetworks,
      connectionStatus,
      wifiProvisionStatus,
      isScanningWifi,
    ]);
  }

  Future<void> startBleScan() async {
    discoveredDevices.clear();
    
    // Ensure Bluetooth is on
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      throw Exception('Bluetooth is off');
    }

    _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName.startsWith("PalmPressure") || r.advertisementData.advName.startsWith("PalmPressure")) {
          if (!discoveredDevices.any((d) => d.device.remoteId == r.device.remoteId)) {
            discoveredDevices.add(r);
          }
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> stopBleScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    connectionStatus.value = 'Connecting...';
    try {
      await device.connect(autoConnect: false, timeout: const Duration(seconds: 10), license: License.nonprofit);
      _connectedDevice = device;
      connectionStatus.value = 'Discovering Services...';

      List<BluetoothService> services = await device.discoverServices();
      BluetoothService? targetService;

      for (var service in services) {
        if (service.uuid.toString() == serviceUuid) {
          targetService = service;
          break;
        }
      }

      if (targetService == null) {
        throw Exception("Provisioning service not found on device");
      }

      for (var char in targetService.characteristics) {
        if (char.uuid.toString() == wifiScanUuid) _scanChar = char;
        if (char.uuid.toString() == wifiCredsUuid) _credsChar = char;
        if (char.uuid.toString() == wifiStatusUuid) _statusChar = char;
      }

      if (_statusChar != null) {
        await _statusChar!.setNotifyValue(true);
        _wifiStatusSubscription = _statusChar!.onValueReceived.listen((value) {
          final status = utf8.decode(value);
          wifiProvisionStatus.value = status;
        });
      }

      if (_scanChar != null) {
        await _scanChar!.setNotifyValue(true);
        _wifiScanSubscription = _scanChar!.onValueReceived.listen((value) {
          final jsonStr = utf8.decode(value);
          if (jsonStr.isEmpty) return;
          try {
            final decoded = jsonDecode(jsonStr);
            if (decoded.containsKey('done') && decoded['done'] == true) {
              isScanningWifi.value = false;
            } else if (decoded.containsKey('ssid')) {
              // Ensure no duplicates
              if (!scannedNetworks.any((net) => net['ssid'] == decoded['ssid'])) {
                scannedNetworks.add(decoded as Map<String, dynamic>);
              }
            }
          } catch (e) {
            print("Error parsing Wi-Fi scan result: $e");
          }
        });
      }

      connectionStatus.value = 'Connected';
    } catch (e) {
      connectionStatus.value = 'Failed to connect: $e';
      rethrow;
    }
  }

  Future<void> requestWifiScan() async {
    if (_scanChar == null) throw Exception("Scan characteristic not found");
    scannedNetworks.clear();
    isScanningWifi.value = true;
    
    // Write any value to trigger scan
    await _scanChar!.write(utf8.encode("SCAN"));
  }

  Future<void> sendWifiCredentials(String ssid, String password) async {
    if (_credsChar == null) throw Exception("Credentials characteristic not found");
    
    final payload = jsonEncode({
      "ssid": ssid,
      "password": password,
    });
    
    await _credsChar!.write(utf8.encode(payload));
  }

  Future<void> disconnect() async {
    await _wifiScanSubscription?.cancel();
    await _wifiStatusSubscription?.cancel();
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
    connectionStatus.value = 'Disconnected';
  }
}
