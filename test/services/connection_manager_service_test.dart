import 'package:flutter_test/flutter_test.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/connection_status.dart';
import 'package:vital_step/services/connection_manager_service.dart';

void main() {
  group('ConnectionManagerService Tests', () {
    late ConnectionManagerService connectionManager;
    late Device testDevice;

    setUp(() {
      connectionManager = ConnectionManagerService();
      testDevice = const Device(
        id: 1,
        userId: 1,
        deviceName: 'Test Device',
        deviceCode: 'TEST001',
      );
    });

    tearDown(() {
      connectionManager.dispose();
    });

    test('should initialize with no active device', () {
      expect(connectionManager.activeDevice, isNull);
    });

    test('should return disconnected status for new device', () {
      final status = connectionManager.getConnectionStatus(testDevice);
      expect(status.isDisconnected, isTrue);
    });

    test('should update connection status correctly', () async {
      // Initially disconnected
      expect(connectionManager.getConnectionStatus(testDevice).isDisconnected, isTrue);

      // Update to connecting
      await connectionManager.updateConnectionStatus(testDevice, const ConnectionStatus.connecting());
      expect(connectionManager.getConnectionStatus(testDevice).isConnecting, isTrue);

      // Update to connected
      await connectionManager.updateConnectionStatus(testDevice, const ConnectionStatus.connected());
      expect(connectionManager.getConnectionStatus(testDevice).isConnected, isTrue);
      expect(connectionManager.activeDevice?.deviceCode, equals(testDevice.deviceCode));
    });

    test('should connect to device successfully', () async {
      final result = await connectionManager.connectToDevice(testDevice);
      
      expect(result.isSuccess, isTrue);
      expect(result.device?.deviceCode, equals(testDevice.deviceCode));
      expect(connectionManager.isDeviceConnected(testDevice), isTrue);
      expect(connectionManager.activeDevice?.deviceCode, equals(testDevice.deviceCode));
    });

    test('should disconnect from device', () async {
      // First connect
      await connectionManager.connectToDevice(testDevice);
      expect(connectionManager.isDeviceConnected(testDevice), isTrue);

      // Then disconnect
      await connectionManager.disconnectFromDevice(testDevice);
      expect(connectionManager.isDeviceConnected(testDevice), isFalse);
      expect(connectionManager.activeDevice, isNull);
    });

    test('should handle multiple devices correctly', () async {
      const device2 = Device(
        id: 2,
        userId: 1,
        deviceName: 'Test Device 2',
        deviceCode: 'TEST002',
      );

      // Connect first device
      await connectionManager.connectToDevice(testDevice);
      expect(connectionManager.activeDevice?.deviceCode, equals(testDevice.deviceCode));

      // Connect second device (should disconnect first)
      await connectionManager.connectToDevice(device2);
      expect(connectionManager.activeDevice?.deviceCode, equals(device2.deviceCode));
      expect(connectionManager.isDeviceConnected(testDevice), isFalse);
      expect(connectionManager.isDeviceConnected(device2), isTrue);
    });

    test('should provide connection status stream', () async {
      final statusStream = connectionManager.getConnectionStatusStream(testDevice);
      
      // Listen to status changes
      final statusUpdates = <ConnectionStatus>[];
      final subscription = statusStream.listen((status) {
        statusUpdates.add(status);
      });

      // Update status
      await connectionManager.updateConnectionStatus(testDevice, const ConnectionStatus.connecting());
      await connectionManager.updateConnectionStatus(testDevice, const ConnectionStatus.connected());

      // Wait a bit for stream updates
      await Future.delayed(const Duration(milliseconds: 10));

      expect(statusUpdates.length, equals(2));
      expect(statusUpdates[0].isConnecting, isTrue);
      expect(statusUpdates[1].isConnected, isTrue);

      await subscription.cancel();
    });

    test('should reset all connections', () async {
      const device2 = Device(
        id: 2,
        userId: 1,
        deviceName: 'Test Device 2',
        deviceCode: 'TEST002',
      );

      // Connect multiple devices
      await connectionManager.connectToDevice(testDevice);
      await connectionManager.updateConnectionStatus(device2, const ConnectionStatus.connected());

      expect(connectionManager.getAllConnectionStates().length, greaterThan(0));

      // Reset all connections
      await connectionManager.resetAllConnections();

      expect(connectionManager.activeDevice, isNull);
      // All devices should be disconnected
      expect(connectionManager.getConnectionStatus(testDevice).isDisconnected, isTrue);
      expect(connectionManager.getConnectionStatus(device2).isDisconnected, isTrue);
    });

    test('should handle connection helper methods correctly', () async {
      expect(connectionManager.isDeviceConnected(testDevice), isFalse);
      expect(connectionManager.isDeviceConnecting(testDevice), isFalse);

      await connectionManager.updateConnectionStatus(testDevice, const ConnectionStatus.connecting());
      expect(connectionManager.isDeviceConnecting(testDevice), isTrue);
      expect(connectionManager.isDeviceConnected(testDevice), isFalse);

      await connectionManager.updateConnectionStatus(testDevice, const ConnectionStatus.connected());
      expect(connectionManager.isDeviceConnected(testDevice), isTrue);
      expect(connectionManager.isDeviceConnecting(testDevice), isFalse);
    });
  });

  group('ConnectionResult Tests', () {
    test('should create successful result', () {
      const device = Device(
        id: 1,
        userId: 1,
        deviceName: 'Test Device',
        deviceCode: 'TEST001',
      );

      final result = ConnectionResult.success(device);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.device, equals(device));
      expect(result.errorMessage, isNull);
    });

    test('should create failure result', () {
      const errorMessage = 'Connection failed';
      final result = ConnectionResult.failure(errorMessage);
      
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, equals(errorMessage));
      expect(result.device, isNull);
    });
  });
}