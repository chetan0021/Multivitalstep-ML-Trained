import 'dart:async';

import 'package:get_storage/get_storage.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/device_selection_state.dart';
import 'package:vital_step/Model/connection_status.dart';
import 'package:vital_step/app/app.logger.dart';

/// Service for managing device selection state and persistence
class DeviceSelectionService {
  static const String _selectedDeviceKey = 'selected_device';
  static const String _selectionTimestampKey = 'selection_timestamp';
  static const String _deviceSelectionStateKey = 'device_selection_state';
  
  final _logger = getLogger('DeviceSelectionService');
  final GetStorage _storage = GetStorage();
  
  // Stream controller for selected device changes
  final StreamController<Device?> _selectedDeviceController = 
      StreamController<Device?>.broadcast();
  
  // Stream controller for selection state changes
  final StreamController<DeviceSelectionState> _selectionStateController = 
      StreamController<DeviceSelectionState>.broadcast();
  
  DeviceSelectionState _currentState = const DeviceSelectionState();
  
  /// Stream of selected device changes
  Stream<Device?> get selectedDeviceStream => _selectedDeviceController.stream;
  
  /// Stream of selection state changes
  Stream<DeviceSelectionState> get selectionStateStream => _selectionStateController.stream;
  
  /// Currently selected device
  Device? get selectedDevice => _currentState.selectedDevice;
  
  /// Current selection state
  DeviceSelectionState get currentState => _currentState;
  
  /// Initialize the service and restore persisted selection
  Future<void> initialize() async {
    try {
      await _restorePersistedState();
      _logger.i('DeviceSelectionService initialized');
    } catch (e) {
      _logger.e('Failed to initialize DeviceSelectionService: $e');
    }
  }
  
  /// Select a device and persist the selection
  Future<void> selectDevice(Device device) async {
    try {
      _currentState = _currentState.withSelectedDevice(device);
      await _persistState();
      _selectedDeviceController.add(device);
      _selectionStateController.add(_currentState);
      _logger.i('Device selected: ${device.deviceName} (${device.deviceCode})');
    } catch (e) {
      _logger.e('Failed to select device: $e');
      rethrow;
    }
  }
  
  /// Clear the current selection
  Future<void> clearSelection() async {
    try {
      _currentState = _currentState.withSelectedDevice(null);
      await _persistState();
      _selectedDeviceController.add(null);
      _selectionStateController.add(_currentState);
      _logger.i('Device selection cleared');
    } catch (e) {
      _logger.e('Failed to clear selection: $e');
      rethrow;
    }
  }
  
  /// Update connection status for a device (deprecated - use ConnectionManagerService)
  @Deprecated('Use ConnectionManagerService.updateConnectionStatus instead')
  Future<void> updateConnectionStatus(Device device, ConnectionStatus status) async {
    try {
      _currentState = _currentState.withConnectionStatus(device, status);
      await _persistState();
      _selectionStateController.add(_currentState);
      _logger.d('Connection status updated for ${device.deviceCode}: ${status.displayName}');
    } catch (e) {
      _logger.e('Failed to update connection status: $e');
      rethrow;
    }
  }
  
  /// Get connection status for a device (deprecated - use ConnectionManagerService)
  @Deprecated('Use ConnectionManagerService.getConnectionStatus instead')
  ConnectionStatus getConnectionStatus(Device device) {
    return _currentState.getConnectionStatus(device);
  }
  
  /// Get the persisted device selection (legacy method for backward compatibility)
  Future<Device?> getPersistedSelection() async {
    try {
      final deviceJson = _storage.read(_selectedDeviceKey);
      if (deviceJson != null) {
        final deviceMap = Map<String, dynamic>.from(deviceJson);
        return Device.fromJson(deviceMap);
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get persisted selection: $e');
      return null;
    }
  }
  
  /// Check if a device selection is persisted
  bool hasPersistedSelection() {
    return _storage.hasData(_selectedDeviceKey) || _storage.hasData(_deviceSelectionStateKey);
  }
  
  /// Get the timestamp of the last selection
  DateTime? getSelectionTimestamp() {
    return _currentState.lastSelectionTime;
  }
  
  /// Persist the current selection state
  Future<void> _persistState() async {
    try {
      await _storage.write(_deviceSelectionStateKey, _currentState.toJson());
      
      // Also persist individual device for backward compatibility
      if (_currentState.selectedDevice != null) {
        await _storage.write(_selectedDeviceKey, _currentState.selectedDevice!.toJson());
        await _storage.write(_selectionTimestampKey, DateTime.now().millisecondsSinceEpoch);
      } else {
        await _storage.remove(_selectedDeviceKey);
        await _storage.remove(_selectionTimestampKey);
      }
      
      _logger.d('Device selection state persisted');
    } catch (e) {
      _logger.e('Failed to persist selection state: $e');
      rethrow;
    }
  }
  
  /// Restore selection state from persistent storage
  Future<void> _restorePersistedState() async {
    try {
      // Try to restore from new state format first
      final stateJson = _storage.read(_deviceSelectionStateKey);
      if (stateJson != null) {
        final stateMap = Map<String, dynamic>.from(stateJson);
        _currentState = DeviceSelectionState.fromJson(stateMap);
        _selectedDeviceController.add(_currentState.selectedDevice);
        _selectionStateController.add(_currentState);
        _logger.i('Restored device selection state');
        return;
      }
      
      // Fallback to legacy format
      final persistedDevice = await getPersistedSelection();
      if (persistedDevice != null) {
        _currentState = _currentState.withSelectedDevice(persistedDevice);
        _selectedDeviceController.add(persistedDevice);
        _selectionStateController.add(_currentState);
        _logger.i('Restored legacy device selection: ${persistedDevice.deviceName}');
      }
    } catch (e) {
      _logger.e('Failed to restore persisted state: $e');
      // Don't rethrow here - we want the service to continue working even if restoration fails
    }
  }
  
  /// Set loading state
  void setLoading(bool isLoading) {
    _currentState = _currentState.copyWith(isLoading: isLoading);
    _selectionStateController.add(_currentState);
  }
  
  /// Check if currently loading
  bool get isLoading => _currentState.isLoading;
  
  /// Dispose of resources
  void dispose() {
    _selectedDeviceController.close();
    _selectionStateController.close();
  }
}