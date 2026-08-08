import 'package:flutter_test/flutter_test.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/connection_status.dart';
import 'package:vital_step/Model/device_selection_state.dart';
import 'package:vital_step/Model/device_extensions.dart';

void main() {
  group('Device Selection Models', () {
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

    group('ConnectionStatus', () {
      test('should create different connection statuses', () {
        const disconnected = ConnectionStatus.disconnected();
        const connecting = ConnectionStatus.connecting();
        const connected = ConnectionStatus.connected();
        const failed = ConnectionStatus.failed(errorMessage: 'Test error');
        const offline = ConnectionStatus.offline();

        expect(disconnected.isDisconnected, isTrue);
        expect(connecting.isConnecting, isTrue);
        expect(connected.isConnected, isTrue);
        expect(failed.isFailed, isTrue);
        expect(failed.errorMessage, equals('Test error'));
        expect(offline.isOffline, isTrue);
      });

      test('should have correct display names', () {
        expect(const ConnectionStatus.disconnected().displayName, equals('Available'));
        expect(const ConnectionStatus.connecting().displayName, equals('Connecting...'));
        expect(const ConnectionStatus.connected().displayName, equals('Connected'));
        expect(const ConnectionStatus.failed().displayName, equals('Connection Failed'));
        expect(const ConnectionStatus.offline().displayName, equals('Offline'));
      });

      test('should serialize and deserialize correctly', () {
        const original = ConnectionStatus.failed(errorMessage: 'Network error');
        final json = original.toJson();
        final restored = ConnectionStatus.fromJson(json);

        expect(restored.type, equals(original.type));
        expect(restored.errorMessage, equals(original.errorMessage));
      });
    });

    group('DeviceSelectionState', () {
      test('should create empty state correctly', () {
        expect(testState.hasSelection, isFalse);
        expect(testState.isSelectedDeviceConnected, isFalse);
        expect(testState.hasConnectingDevice, isFalse);
        expect(testState.connectedDeviceCount, equals(0));
      });

      test('should handle device selection', () {
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
      });

      test('should serialize and deserialize correctly', () {
        final stateWithDevice = testState.withSelectedDevice(testDevice);
        final json = stateWithDevice.toJson();
        final restored = DeviceSelectionState.fromJson(json);

        expect(restored.selectedDevice?.deviceCode, equals(testDevice.deviceCode));
        expect(restored.selectedDevice?.deviceName, equals(testDevice.deviceName));
      });
    });

    group('Device Extensions', () {
      test('should check selection status correctly', () {
        final selectedState = testState.withSelectedDevice(testDevice);
        
        expect(testDevice.isSelectedIn(selectedState), isTrue);
        expect(testDevice.isSelectedIn(testState), isFalse);
      });

      test('should check connection status correctly', () {
        const connectedStatus = ConnectionStatus.connected();
        final connectedState = testState.withConnectionStatus(testDevice, connectedStatus);
        
        expect(testDevice.isConnectedIn(connectedState), isTrue);
        expect(testDevice.isConnectingIn(connectedState), isFalse);
        expect(testDevice.isAvailableIn(testState), isTrue);
      });

      test('should generate unique identifier', () {
        expect(testDevice.uniqueIdentifier, equals('TEST001_1'));
      });

      test('should compare devices correctly', () {
        const sameDevice = Device(
          id: 1,
          userId: 123,
          deviceName: 'Test Device',
          deviceCode: 'TEST001',
        );
        
        const differentDevice = Device(
          id: 2,
          userId: 123,
          deviceName: 'Different Device',
          deviceCode: 'TEST002',
        );

        expect(testDevice.isSameDevice(sameDevice), isTrue);
        expect(testDevice.isSameDevice(differentDevice), isFalse);
      });

      test('should serialize with selection data', () {
        const connectionStatus = ConnectionStatus.connected();
        final selectionTime = DateTime.now();
        
        final json = testDevice.toJsonWithSelectionData(
          isSelected: true,
          connectionStatus: connectionStatus,
          selectedAt: selectionTime,
        );

        expect(json['isSelected'], isTrue);
        expect(json['connectionStatus'], isNotNull);
        expect(json['selectedAt'], equals(selectionTime.toIso8601String()));
      });
    });

    group('DeviceSelectionUtils', () {
      test('should validate device selection', () {
        expect(DeviceSelectionUtils.canSelectDevice(testDevice), isTrue);
        
        const invalidDevice = Device(
          id: 1,
          userId: 123,
          deviceName: '',
          deviceCode: '',
        );
        expect(DeviceSelectionUtils.canSelectDevice(invalidDevice), isFalse);
      });

      test('should find device by code', () {
        final devices = [testDevice];
        final found = DeviceSelectionUtils.findDeviceByCode(devices, 'TEST001');
        final notFound = DeviceSelectionUtils.findDeviceByCode(devices, 'NOTFOUND');

        expect(found, equals(testDevice));
        expect(notFound, isNull);
      });

      test('should filter selectable devices', () {
        const offlineDevice = Device(
          id: 2,
          userId: 123,
          deviceName: 'Offline Device',
          deviceCode: 'OFFLINE001',
        );

        final devices = [testDevice, offlineDevice];
        final stateWithOfflineDevice = testState.withConnectionStatus(
          offlineDevice, 
          const ConnectionStatus.offline(),
        );

        final selectableDevices = DeviceSelectionUtils.getSelectableDevices(
          devices, 
          stateWithOfflineDevice,
        );

        expect(selectableDevices.length, equals(1));
        expect(selectableDevices.first, equals(testDevice));
      });
    });
  });
}