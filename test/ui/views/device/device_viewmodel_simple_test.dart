import 'package:flutter_test/flutter_test.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/device_selection_state.dart';
import 'package:vital_step/Model/connection_status.dart';
import 'package:vital_step/ui/views/device/device_viewmodel.dart';

void main() {
  group('DeviceViewModel Selection Logic Tests', () {
    late DeviceViewModel viewModel;

    setUp(() {
      viewModel = DeviceViewModel();
    });

    group('Device Selection State Properties', () {
      test('should have correct initial state', () {
        // These properties should be accessible without initialization
        expect(viewModel.hasSelectedDevice, isFalse);
        expect(viewModel.canContinueWithDevice, isFalse);
      });
    });

    group('Device Selection Helper Methods', () {
      test('isDeviceSelected should work with null selectedDevice', () {
        final testDevice = Device(
          id: 1,
          userId: 1,
          deviceCode: 'TEST001',
          deviceName: 'Test Device',
          createdAt: DateTime.now(),
        );

        // Should return false when no device is selected
        expect(viewModel.isDeviceSelected(testDevice), isFalse);
      });

      test('getDeviceStatusText should return Available for non-selected device', () {
        final testDevice = Device(
          id: 1,
          userId: 1,
          deviceCode: 'TEST001',
          deviceName: 'Test Device',
          createdAt: DateTime.now(),
        );

        // Should return 'Available' for non-selected devices
        final statusText = viewModel.getDeviceStatusText(testDevice);
        expect(statusText, equals('Available'));
      });
    });

    group('Connection Status Methods', () {
      test('getConnectionStatus should return disconnected by default', () {
        final testDevice = Device(
          id: 1,
          userId: 1,
          deviceCode: 'TEST001',
          deviceName: 'Test Device',
          createdAt: DateTime.now(),
        );

        final status = viewModel.getConnectionStatus(testDevice);
        expect(status.isDisconnected, isTrue);
      });

      test('isDeviceConnected should return false by default', () {
        final testDevice = Device(
          id: 1,
          userId: 1,
          deviceCode: 'TEST001',
          deviceName: 'Test Device',
          createdAt: DateTime.now(),
        );

        expect(viewModel.isDeviceConnected(testDevice), isFalse);
      });

      test('isDeviceConnecting should return false by default', () {
        final testDevice = Device(
          id: 1,
          userId: 1,
          deviceCode: 'TEST001',
          deviceName: 'Test Device',
          createdAt: DateTime.now(),
        );

        expect(viewModel.isDeviceConnecting(testDevice), isFalse);
      });
    });

    group('Persistence Methods', () {
      test('hasPersistedSelection should return false by default', () {
        expect(viewModel.hasPersistedSelection(), isFalse);
      });
    });
  });

  group('DeviceSelectionState Tests', () {
    test('should create empty state correctly', () {
      const state = DeviceSelectionState();
      
      expect(state.hasSelection, isFalse);
      expect(state.isSelectedDeviceConnected, isFalse);
      expect(state.hasConnectingDevice, isFalse);
      expect(state.connectedDeviceCount, equals(0));
    });

    test('should create state with selected device', () {
      final device = Device(
        id: 1,
        userId: 1,
        deviceCode: 'TEST001',
        deviceName: 'Test Device',
        createdAt: DateTime.now(),
      );

      final state = DeviceSelectionState(selectedDevice: device);
      
      expect(state.hasSelection, isTrue);
      expect(state.selectedDevice, equals(device));
    });

    test('should get connection status for device', () {
      final device = Device(
        id: 1,
        userId: 1,
        deviceCode: 'TEST001',
        deviceName: 'Test Device',
        createdAt: DateTime.now(),
      );

      const state = DeviceSelectionState();
      final status = state.getConnectionStatus(device);
      
      expect(status.isDisconnected, isTrue);
    });

    test('should create copy with updated connection status', () {
      final device = Device(
        id: 1,
        userId: 1,
        deviceCode: 'TEST001',
        deviceName: 'Test Device',
        createdAt: DateTime.now(),
      );

      const initialState = DeviceSelectionState();
      const connectedStatus = ConnectionStatus.connected();
      
      final updatedState = initialState.withConnectionStatus(device, connectedStatus);
      
      expect(updatedState.getConnectionStatus(device).isConnected, isTrue);
      expect(updatedState.connectedDeviceCount, equals(1));
    });

    test('should create copy with selected device', () {
      final device = Device(
        id: 1,
        userId: 1,
        deviceCode: 'TEST001',
        deviceName: 'Test Device',
        createdAt: DateTime.now(),
      );

      const initialState = DeviceSelectionState();
      final updatedState = initialState.withSelectedDevice(device);
      
      expect(updatedState.hasSelection, isTrue);
      expect(updatedState.selectedDevice, equals(device));
      expect(updatedState.lastSelectionTime, isNotNull);
    });
  });

  group('ConnectionStatus Tests', () {
    test('should create different connection statuses correctly', () {
      const disconnected = ConnectionStatus.disconnected();
      const connecting = ConnectionStatus.connecting();
      const connected = ConnectionStatus.connected();
      const failed = ConnectionStatus.failed(errorMessage: 'Test error');
      const offline = ConnectionStatus.offline();

      expect(disconnected.isDisconnected, isTrue);
      expect(disconnected.displayName, equals('Available'));

      expect(connecting.isConnecting, isTrue);
      expect(connecting.displayName, equals('Connecting...'));

      expect(connected.isConnected, isTrue);
      expect(connected.displayName, equals('Connected'));

      expect(failed.isFailed, isTrue);
      expect(failed.displayName, equals('Connection Failed'));
      expect(failed.errorMessage, equals('Test error'));

      expect(offline.isOffline, isTrue);
      expect(offline.displayName, equals('Offline'));
    });

    test('should serialize and deserialize correctly', () {
      const originalStatus = ConnectionStatus.failed(errorMessage: 'Network error');
      final json = originalStatus.toJson();
      final deserializedStatus = ConnectionStatus.fromJson(json);

      expect(deserializedStatus.isFailed, isTrue);
      expect(deserializedStatus.errorMessage, equals('Network error'));
    });
  });
}