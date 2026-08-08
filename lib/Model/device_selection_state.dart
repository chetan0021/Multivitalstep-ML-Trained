import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/connection_status.dart';

/// Represents the overall device selection state
class DeviceSelectionState {
  final Device? selectedDevice;
  final Map<String, ConnectionStatus> deviceConnections;
  final bool isSelectionPersisted;
  final DateTime? lastSelectionTime;
  final bool isLoading;

  const DeviceSelectionState({
    this.selectedDevice,
    this.deviceConnections = const {},
    this.isSelectionPersisted = false,
    this.lastSelectionTime,
    this.isLoading = false,
  });

  /// Simple JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'selectedDevice': selectedDevice?.toJson(),
      'deviceConnections': deviceConnections.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'isSelectionPersisted': isSelectionPersisted,
      'lastSelectionTime': lastSelectionTime?.toIso8601String(),
      'isLoading': isLoading,
    };
  }

  /// Simple JSON deserialization
  factory DeviceSelectionState.fromJson(Map<String, dynamic> json) {
    final selectedDeviceJson = json['selectedDevice'] as Map<String, dynamic>?;
    final deviceConnectionsJson = json['deviceConnections'] as Map<String, dynamic>? ?? {};
    
    return DeviceSelectionState(
      selectedDevice: selectedDeviceJson != null ? Device.fromJson(selectedDeviceJson) : null,
      deviceConnections: deviceConnectionsJson.map(
        (key, value) => MapEntry(key, ConnectionStatus.fromJson(value as Map<String, dynamic>)),
      ),
      isSelectionPersisted: json['isSelectionPersisted'] as bool? ?? false,
      lastSelectionTime: json['lastSelectionTime'] != null 
          ? DateTime.parse(json['lastSelectionTime'] as String)
          : null,
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  /// Creates a copy with updated values
  DeviceSelectionState copyWith({
    Device? selectedDevice,
    Map<String, ConnectionStatus>? deviceConnections,
    bool? isSelectionPersisted,
    DateTime? lastSelectionTime,
    bool? isLoading,
  }) {
    return DeviceSelectionState(
      selectedDevice: selectedDevice ?? this.selectedDevice,
      deviceConnections: deviceConnections ?? this.deviceConnections,
      isSelectionPersisted: isSelectionPersisted ?? this.isSelectionPersisted,
      lastSelectionTime: lastSelectionTime ?? this.lastSelectionTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Extension methods for DeviceSelectionState
extension DeviceSelectionStateExtension on DeviceSelectionState {
  /// Returns true if a device is currently selected
  bool get hasSelection => selectedDevice != null;
  
  /// Returns the connection status for a specific device
  ConnectionStatus getConnectionStatus(Device device) {
    return deviceConnections[device.deviceCode] ?? const ConnectionStatus.disconnected();
  }
  
  /// Returns true if the selected device is connected
  bool get isSelectedDeviceConnected {
    if (selectedDevice == null) return false;
    return getConnectionStatus(selectedDevice!).isConnected;
  }
  
  /// Returns true if any device is currently connecting
  bool get hasConnectingDevice {
    return deviceConnections.values.any((status) => status.isConnecting);
  }
  
  /// Returns the number of connected devices
  int get connectedDeviceCount {
    return deviceConnections.values.where((status) => status.isConnected).length;
  }
  
  /// Creates a copy with updated connection status for a device
  DeviceSelectionState withConnectionStatus(Device device, ConnectionStatus status) {
    final updatedConnections = Map<String, ConnectionStatus>.from(deviceConnections);
    updatedConnections[device.deviceCode] = status;
    return copyWith(deviceConnections: updatedConnections);
  }
  
  /// Creates a copy with a new selected device
  DeviceSelectionState withSelectedDevice(Device? device) {
    return copyWith(
      selectedDevice: device,
      lastSelectionTime: device != null ? DateTime.now() : null,
    );
  }
}