import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/device_selection_state.dart';
import 'package:vital_step/Model/connection_status.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:vital_step/services/connection_manager_service.dart';
import 'package:vital_step/services/device_selection_service.dart';
import 'package:vital_step/ui/views/device/device_view.form.dart';

class DeviceViewModel extends FormViewModel {
  final _dialogService = locator<DialogService>();
  final _accountsService = locator<AccountsService>();
  final _apiCallsService = locator<ApiCallsService>();
  final _deviceSelectionService = locator<DeviceSelectionService>();
  final _connectionManagerService = locator<ConnectionManagerService>();
  final _logger = getLogger("DeviceViewModel");
  late Future<List<Device>?> devicesFuture;
  List<Device>? devices;
  List<String>? deviceCodes;

  // QR scan state
  String? scannedDeviceCode;

  // Device selection state
  DeviceSelectionState get selectionState => _deviceSelectionService.currentState;
  Device? get selectedDevice => _deviceSelectionService.selectedDevice;
  bool get hasSelectedDevice => selectedDevice != null;
  bool get canContinueWithDevice => hasSelectedDevice && !selectionState.isLoading;

  Future<List<Device>?> init() async {
    // Initialize device selection service
    await _deviceSelectionService.initialize();
    
    // Listen to selection state changes
    _deviceSelectionService.selectionStateStream.listen((_) {
      notifyListeners();
    });
    
    devices = await _accountsService.getDevices();
    await getAllPossibleDevices();
    
    // Notify so the view rebuilds with the loaded device list
    notifyListeners();
    
    // Set up connection status listeners for existing devices
    if (devices != null) {
      for (final device in devices!) {
        _connectionManagerService.getConnectionStatusStream(device).listen((_) {
          notifyListeners();
        });
      }
    }
    
    return devices;
  }

  void onQrScanned(String code) {
    scannedDeviceCode = code;
    notifyListeners();
  }

  void clearScannedCode() {
    scannedDeviceCode = null;
    notifyListeners();
  }

  Future<void> saveScannedDevice(String deviceName) async {
    if (scannedDeviceCode == null || scannedDeviceCode!.isEmpty) {
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: "Device Code Error",
          description: "No device code scanned. Please scan a QR code first.");
      return;
    }
    if (deviceName.trim().isEmpty) {
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: "Device Name Error",
          description: "Please enter a name for this device.");
      return;
    }
    if (deviceCodes != null &&
        deviceCodes!.isNotEmpty &&
        !deviceCodes!.contains(scannedDeviceCode)) {
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: "Invalid Device",
          description:
              "This QR code does not match any registered device. Please try again.");
      return;
    }

    setBusy(true);
    try {
      await _accountsService.addDevice(
          deviceCode: scannedDeviceCode!, deviceName: deviceName.trim());
      Fluttertoast.showToast(msg: "Device added successfully");
      scannedDeviceCode = null;
      devicesFuture = init();
      notifyListeners();
    } catch (e) {
      _logger.e(e.toString());
      Fluttertoast.showToast(msg: "Unable to add device");
    }
    setBusy(false);
  }

  Future<void> saveDevice() async {
    setBusy(true);
    if (deviceCodeValue == null || deviceCodeValue!.isEmpty) {
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: "Device Code Error",
          description: "The device code can not be empty. Please try again.");
    } else if (deviceNameValue == null || deviceNameValue!.isEmpty) {
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: "Device Name Error",
          description: "The device Name can not be empty. Please try again.");
    } else if (deviceCodes == null) {
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: "Device Code Error",
          description: "Unable to fetch device codes. Please try again.");
    } else if (deviceCodes!.isEmpty) {
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: "Device Code Error",
          description: "No device codes available. Please try again.");
    } else if (!deviceCodes!.contains(deviceCodeValue)) {
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: "Device Code Error",
          description:
              "The device code is not valid. Please enter a valid device code.");
    } else {
      try {
        await _accountsService.addDevice(
            deviceCode: deviceCodeValue!, deviceName: deviceNameValue!);
        Fluttertoast.showToast(msg: "Device added successfully");
        devicesFuture = init();
      } catch (e) {
        _logger.e(e.toString());
        Fluttertoast.showToast(msg: "Unable to add device");
      }
    }
    setBusy(false);
  }

  Future<void> getAllPossibleDevices() async {
    try {
      deviceCodes = await _apiCallsService.getAllPossibleDevices();
      _logger.i(deviceCodes);
    } catch (e) {
      _logger.e(e.toString());
      Fluttertoast.showToast(msg: "Unable to fetch devices");
    }
  }

  // Device selection methods

  /// Select a device for connection
  Future<void> selectDevice(Device device) async {
    try {
      _logger.i('Selecting device: ${device.deviceName} (${device.deviceCode})');
      await _deviceSelectionService.selectDevice(device);
      
      // Use ConnectionManagerService to handle the connection
      final connectionResult = await _connectionManagerService.connectToDevice(device);
      
      if (connectionResult.isSuccess) {
        _logger.i('Device selected and connected: ${device.deviceName}');
      } else {
        _logger.e('Failed to connect to selected device: ${connectionResult.errorMessage}');
        Fluttertoast.showToast(msg: "Failed to connect to device: ${connectionResult.errorMessage}");
      }
      
    } catch (e) {
      _logger.e('Failed to select device: $e');
      Fluttertoast.showToast(msg: "Failed to connect to device");
    }
  }

  /// Clear the current device selection
  Future<void> clearSelection() async {
    try {
      // Disconnect from any connected device first
      if (_connectionManagerService.activeDevice != null) {
        await _connectionManagerService.disconnectFromDevice(_connectionManagerService.activeDevice!);
      }
      
      await _deviceSelectionService.clearSelection();
      _logger.i('Device selection cleared');
    } catch (e) {
      _logger.e('Failed to clear selection: $e');
      Fluttertoast.showToast(msg: "Failed to clear selection");
    }
  }

  /// Check if a device is currently selected
  bool isDeviceSelected(Device device) {
    return selectedDevice?.deviceCode == device.deviceCode;
  }

  /// Get connection status for a device
  ConnectionStatus getConnectionStatus(Device device) {
    return _connectionManagerService.getConnectionStatus(device);
  }

  /// Check if a device is connected
  bool isDeviceConnected(Device device) {
    return _connectionManagerService.isDeviceConnected(device);
  }

  /// Check if a device is connecting
  bool isDeviceConnecting(Device device) {
    return _connectionManagerService.isDeviceConnecting(device);
  }

  /// Get display status text for a device
  String getDeviceStatusText(Device device) {
    final status = getConnectionStatus(device);
    if (isDeviceSelected(device)) {
      return status.displayName;
    }
    return 'Available';
  }

  /// Navigate to dashboard with selected device
  Future<void> continueWithSelectedDevice() async {
    if (!canContinueWithDevice) {
      _logger.w('Cannot continue: no device selected or still loading');
      return;
    }

    try {
      _logger.i('Continuing with selected device: ${selectedDevice!.deviceName}');
      
      // TODO: Navigate to dashboard with device context
      // This will be implemented when navigation is set up
      Fluttertoast.showToast(msg: "Continuing with ${selectedDevice!.deviceName}");
      
    } catch (e) {
      _logger.e('Failed to continue with device: $e');
      Fluttertoast.showToast(msg: "Failed to continue with selected device");
    }
  }

  /// Retry connection for a failed device
  Future<void> retryConnection(Device device) async {
    if (getConnectionStatus(device).isFailed) {
      await selectDevice(device);
    }
  }

  /// Get persisted device selection on app start
  Future<Device?> getPersistedSelection() async {
    return await _deviceSelectionService.getPersistedSelection();
  }

  /// Check if there's a persisted selection
  bool hasPersistedSelection() {
    return _deviceSelectionService.hasPersistedSelection();
  }

  @override
  void dispose() {
    // Clean up any subscriptions if needed
    super.dispose();
  }
}
