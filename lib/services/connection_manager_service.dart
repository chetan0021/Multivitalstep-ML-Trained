import 'dart:async';

import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/connection_status.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/services/patient_service.dart';

/// Service for managing device connections and connection states
/// This is a minimal implementation focused on basic connection state tracking
class ConnectionManagerService {
  final _logger = getLogger('ConnectionManagerService');

  // Stream controllers for connection status changes
  final Map<String, StreamController<ConnectionStatus>>
      _connectionStatusControllers = {};

  // Current connection states for each device
  final Map<String, ConnectionStatus> _connectionStates = {};

  // Currently active (connected) device
  Device? _activeDevice;

  /// Get the currently active (connected) device
  Device? get activeDevice => _activeDevice;

  /// Get connection status for a specific device
  ConnectionStatus getConnectionStatus(Device device) {
    return _connectionStates[device.deviceCode] ??
        const ConnectionStatus.disconnected();
  }

  /// Get a stream of connection status changes for a specific device
  Stream<ConnectionStatus> getConnectionStatusStream(Device device) {
    final deviceCode = device.deviceCode;

    // Create controller if it doesn't exist
    if (!_connectionStatusControllers.containsKey(deviceCode)) {
      _connectionStatusControllers[deviceCode] =
          StreamController<ConnectionStatus>.broadcast();
    }

    return _connectionStatusControllers[deviceCode]!.stream;
  }

  /// Update connection status for a device
  Future<void> updateConnectionStatus(
      Device device, ConnectionStatus status) async {
    try {
      final deviceCode = device.deviceCode;

      // Update the connection state
      _connectionStates[deviceCode] = status;

      // Update active device based on connection status
      if (status.isConnected) {
        // Trigger patient reading retry queue processing
        _triggerPatientRetryQueue();
        // Disconnect any previously active device
        if (_activeDevice != null && _activeDevice!.deviceCode != deviceCode) {
          await _disconnectDevice(_activeDevice!);
        }
        _activeDevice = device;
        _logger.i('Device connected and set as active: ${device.deviceName}');
      } else if (_activeDevice?.deviceCode == deviceCode) {
        // Clear active device if it's disconnected
        _activeDevice = null;
        _logger.i('Active device disconnected: ${device.deviceName}');
      }

      // Notify listeners of status change
      _notifyStatusChange(device, status);

      _logger.d(
          'Connection status updated for ${device.deviceCode}: ${status.displayName}');
    } catch (e) {
      _logger
          .e('Failed to update connection status for ${device.deviceCode}: $e');
      rethrow;
    }
  }

  /// Attempt to connect to a device (minimal implementation)
  Future<ConnectionResult> connectToDevice(Device device) async {
    try {
      _logger.i('Attempting to connect to device: ${device.deviceName}');

      // Update status to connecting
      await updateConnectionStatus(device, const ConnectionStatus.connecting());

      // Simulate connection process (replace with actual connection logic)
      await Future.delayed(const Duration(milliseconds: 800));

      // For minimal implementation, assume connection succeeds
      // In a real implementation, this would involve actual device communication
      await updateConnectionStatus(device, const ConnectionStatus.connected());

      _logger.i('Successfully connected to device: ${device.deviceName}');
      return ConnectionResult.success(device);
    } catch (e) {
      _logger.e('Failed to connect to device ${device.deviceName}: $e');

      // Update status to failed
      await updateConnectionStatus(
          device, ConnectionStatus.failed(errorMessage: e.toString()));

      return ConnectionResult.failure(e.toString());
    }
  }

  /// Disconnect from a device
  Future<void> disconnectFromDevice(Device device) async {
    try {
      _logger.i('Disconnecting from device: ${device.deviceName}');

      await _disconnectDevice(device);

      _logger.i('Successfully disconnected from device: ${device.deviceName}');
    } catch (e) {
      _logger.e('Failed to disconnect from device ${device.deviceName}: $e');
      rethrow;
    }
  }

  /// Internal method to disconnect a device
  Future<void> _disconnectDevice(Device device) async {
    // Update connection status to disconnected
    await updateConnectionStatus(device, const ConnectionStatus.disconnected());

    // Clear active device if it matches
    if (_activeDevice?.deviceCode == device.deviceCode) {
      _activeDevice = null;
    }
  }

  /// Triggers the patient reading retry queue to process any pending readings
  void _triggerPatientRetryQueue() {
    try {
      final patientService = locator<PatientService>();
      patientService.processRetryQueue();
      _logger.i('Triggered patient reading retry queue processing');
    } catch (e) {
      _logger.w('Could not trigger patient retry queue: $e');
    }
  }

  /// Notify listeners of connection status changes
  void _notifyStatusChange(Device device, ConnectionStatus status) {
    final deviceCode = device.deviceCode;
    final controller = _connectionStatusControllers[deviceCode];

    if (controller != null && !controller.isClosed) {
      controller.add(status);
    }
  }

  /// Check if a device is currently connected
  bool isDeviceConnected(Device device) {
    return getConnectionStatus(device).isConnected;
  }

  /// Check if a device is currently connecting
  bool isDeviceConnecting(Device device) {
    return getConnectionStatus(device).isConnecting;
  }

  /// Get all devices with their current connection states
  Map<String, ConnectionStatus> getAllConnectionStates() {
    return Map.unmodifiable(_connectionStates);
  }

  /// Reset all connection states (useful for testing or app restart)
  Future<void> resetAllConnections() async {
    try {
      _logger.i('Resetting all connection states');

      // Disconnect all devices
      final connectedDevices = _connectionStates.entries
          .where((entry) => entry.value.isConnected)
          .map((entry) => entry.key)
          .toList();

      for (final deviceCode in connectedDevices) {
        _connectionStates[deviceCode] = const ConnectionStatus.disconnected();
        // We can't create a proper Device instance here without id and userId
        // So we'll just notify through the stream controller if it exists
        final controller = _connectionStatusControllers[deviceCode];
        if (controller != null && !controller.isClosed) {
          controller.add(const ConnectionStatus.disconnected());
        }
      }

      _activeDevice = null;

      _logger.i('All connections reset');
    } catch (e) {
      _logger.e('Failed to reset connections: $e');
      rethrow;
    }
  }

  /// Dispose of resources
  void dispose() {
    _logger.d('Disposing ConnectionManagerService');

    // Close all stream controllers
    for (final controller in _connectionStatusControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }

    _connectionStatusControllers.clear();
    _connectionStates.clear();
    _activeDevice = null;
  }
}

/// Result of a connection attempt
class ConnectionResult {
  final bool success;
  final String? errorMessage;
  final Device? device;

  const ConnectionResult._({
    required this.success,
    this.errorMessage,
    this.device,
  });

  /// Create a successful connection result
  factory ConnectionResult.success(Device device) {
    return ConnectionResult._(
      success: true,
      device: device,
    );
  }

  /// Create a failed connection result
  factory ConnectionResult.failure(String errorMessage) {
    return ConnectionResult._(
      success: false,
      errorMessage: errorMessage,
    );
  }

  /// Returns true if the connection was successful
  bool get isSuccess => success;

  /// Returns true if the connection failed
  bool get isFailure => !success;
}
