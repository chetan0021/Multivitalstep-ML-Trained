import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/connection_status.dart';
import 'package:vital_step/Model/device_selection_state.dart';

/// Extension methods for Device model to support selection state
extension DeviceSelectionExtension on Device {
  /// Returns true if this device is selected in the given selection state
  bool isSelectedIn(DeviceSelectionState selectionState) {
    return selectionState.selectedDevice?.deviceCode == deviceCode;
  }
  
  /// Returns the connection status for this device in the given selection state
  ConnectionStatus getConnectionStatusIn(DeviceSelectionState selectionState) {
    return selectionState.getConnectionStatus(this);
  }
  
  /// Returns true if this device is connected in the given selection state
  bool isConnectedIn(DeviceSelectionState selectionState) {
    return getConnectionStatusIn(selectionState).isConnected;
  }
  
  /// Returns true if this device is connecting in the given selection state
  bool isConnectingIn(DeviceSelectionState selectionState) {
    return getConnectionStatusIn(selectionState).isConnecting;
  }
  
  /// Returns true if this device is available (disconnected but not offline/failed)
  bool isAvailableIn(DeviceSelectionState selectionState) {
    final status = getConnectionStatusIn(selectionState);
    return status.isDisconnected;
  }
  
  /// Returns a user-friendly display status for this device
  String getDisplayStatusIn(DeviceSelectionState selectionState) {
    return getConnectionStatusIn(selectionState).displayName;
  }
  
  /// Creates a unique identifier for this device (used for persistence)
  String get uniqueIdentifier => '${deviceCode}_$id';
  
  /// Returns true if this device matches another device by code and ID
  bool isSameDevice(Device other) {
    return deviceCode == other.deviceCode && id == other.id;
  }
}

/// Extension methods for Device model to support JSON serialization with selection state
extension DeviceSerializationExtension on Device {
  /// Converts device to JSON with additional selection metadata
  Map<String, dynamic> toJsonWithSelectionData({
    bool isSelected = false,
    ConnectionStatus? connectionStatus,
    DateTime? selectedAt,
  }) {
    final json = toJson();
    json['isSelected'] = isSelected;
    if (connectionStatus != null) {
      json['connectionStatus'] = connectionStatus.toJson();
    }
    if (selectedAt != null) {
      json['selectedAt'] = selectedAt.toIso8601String();
    }
    return json;
  }
  
  /// Creates a device from JSON that may contain selection metadata
  static Device fromJsonWithSelectionData(Map<String, dynamic> json) {
    // Remove selection-specific fields before creating Device
    final deviceJson = Map<String, dynamic>.from(json);
    deviceJson.remove('isSelected');
    deviceJson.remove('connectionStatus');
    deviceJson.remove('selectedAt');
    
    return Device.fromJson(deviceJson);
  }
}

/// Utility class for device selection operations
class DeviceSelectionUtils {
  /// Validates if a device can be selected
  static bool canSelectDevice(Device device) {
    // Basic validation - device must have valid code and name
    return device.deviceCode.isNotEmpty && device.deviceName.isNotEmpty;
  }
  
  /// Compares two devices for selection priority (used for auto-selection)
  static int compareDevicesForSelection(Device a, Device b) {
    // Prioritize by creation date (newer first), then by name
    if (a.createdAt != null && b.createdAt != null) {
      final dateComparison = b.createdAt!.compareTo(a.createdAt!);
      if (dateComparison != 0) return dateComparison;
    }
    return a.deviceName.compareTo(b.deviceName);
  }
  
  /// Finds a device in a list by device code
  static Device? findDeviceByCode(List<Device> devices, String deviceCode) {
    try {
      return devices.firstWhere((device) => device.deviceCode == deviceCode);
    } catch (e) {
      return null;
    }
  }
  
  /// Filters devices that are available for selection
  static List<Device> getSelectableDevices(
    List<Device> devices,
    DeviceSelectionState selectionState,
  ) {
    return devices.where((device) {
      final status = device.getConnectionStatusIn(selectionState);
      // Only allow selection of devices that are not offline or failed
      return !status.isOffline && !status.isFailed;
    }).toList();
  }
}