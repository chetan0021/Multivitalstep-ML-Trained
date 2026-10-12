import 'package:flutter_test/flutter_test.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/connection_status.dart';
import 'package:vital_step/Model/device_selection_state.dart';

void main() {
  group('DeviceSelectionService Models Integration', () {
    late Device testDevice;
    late DeviceSelectionState testState;

    setUp(() {
      testDevice = const Device(
        id: 1,
        userId: 123,
        deviceName: 'Test Device',
        deviceCode: 'TEST001',
        createdAt: null,
      );

      testState = const DeviceSelectionState(
        selectedDevice: null,
        deviceConnections: {},
        isSelectionPersisted: false,
        lastSelectionTime: null,
        isLoading: false,
      );
    });

    test('should handle device selection state correctly', () {
      expect(testState.hasSelection, isFalse);
      
      final selectedState = testState.withSelectedDevice(testDevice);
      expect(selectedState.hasSelection, isTrue);
      expect(selectedState.selectedDevice, equals(testDevice));
      expect(selectedState.lastSelectionTime, isNotNull);
    });

    test('should handle connection status updates', () {
      const connectedStatus = ConnectionStatus.connected();
      final updatedState = testState.withConnectionStatus(testDevice, connectedStatus);
      
      expect(updatedState.getConnectionStatus(testDevice).isConnected, isTrue);
      expect(updatedState.connectedDeviceCount, equals(1));
      expect(updatedState.hasConnectingDevice, isFalse);
    });

    test('should handle multiple device connections', () {
      const device1 = Device(id: 1, userId: 123, deviceName: 'Device 1', deviceCode: 'DEV001');
      const device2 = Device(id: 2, userId: 123, deviceName: 'Device 2', deviceCode: 'DEV002');
      
      var state = testState;
      state = state.withConnectionStatus(device1, const ConnectionStatus.connected());
      state = state.withConnectionStatus(device2, const ConnectionStatus.connecting());
      
      expect(state.getConnectionStatus(device1).isConnected, isTrue);
      expect(state.getConnectionStatus(device2).isConnecting, isTrue);
      expect(state.connectedDeviceCount, equals(1));
      expect(state.hasConnectingDevice, isTrue);
    });

    test('should serialize and deserialize state correctly', () {
      final stateWithDevice = testState.withSelectedDevice(testDevice);
      final stateWithConnection = stateWithDevice.withConnectionStatus(
        testDevice, 
        const ConnectionStatus.connected(),
      );
      
      final json = stateWithConnection.toJson();
      final restored = DeviceSelectionState.fromJson(json);

      expect(restored.selectedDevice?.deviceCode, equals(testDevice.deviceCode));
      expect(restored.selectedDevice?.deviceName, equals(testDevice.deviceName));
      expect(restored.getConnectionStatus(testDevice).isConnected, isTrue);
      expect(restored.hasSelection, isTrue);
      expect(restored.connectedDeviceCount, equals(1));
    });

    test('should handle loading state', () {
      expect(testState.isLoading, isFalse);
      
      final loadingState = testState.copyWith(isLoading: true);
      expect(loadingState.isLoading, isTrue);
    });

    test('should check if selected device is connected', () {
      final selectedState = testState.withSelectedDevice(testDevice);
      expect(selectedState.isSelectedDeviceConnected, isFalse);
      
      final connectedState = selectedState.withConnectionStatus(
        testDevice, 
        const ConnectionStatus.connected(),
      );
      expect(connectedState.isSelectedDeviceConnected, isTrue);
    });
  });
}