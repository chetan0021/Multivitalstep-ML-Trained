/// Represents the connection status of a device
class ConnectionStatus {
  final ConnectionType type;
  final String? errorMessage;

  const ConnectionStatus._({
    required this.type,
    this.errorMessage,
  });

  const ConnectionStatus.disconnected() : this._(type: ConnectionType.disconnected);
  const ConnectionStatus.connecting() : this._(type: ConnectionType.connecting);
  const ConnectionStatus.connected() : this._(type: ConnectionType.connected);
  const ConnectionStatus.failed({String? errorMessage}) : this._(type: ConnectionType.failed, errorMessage: errorMessage);
  const ConnectionStatus.offline() : this._(type: ConnectionType.offline);

  /// Simple JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'errorMessage': errorMessage,
    };
  }

  /// Simple JSON deserialization
  factory ConnectionStatus.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final errorMessage = json['errorMessage'] as String?;
    
    switch (typeName) {
      case 'disconnected':
        return const ConnectionStatus.disconnected();
      case 'connecting':
        return const ConnectionStatus.connecting();
      case 'connected':
        return const ConnectionStatus.connected();
      case 'failed':
        return ConnectionStatus.failed(errorMessage: errorMessage);
      case 'offline':
        return const ConnectionStatus.offline();
      default:
        return const ConnectionStatus.disconnected();
    }
  }
}

enum ConnectionType {
  disconnected,
  connecting,
  connected,
  failed,
  offline,
}

/// Extension methods for ConnectionStatus
extension ConnectionStatusExtension on ConnectionStatus {
  /// Returns true if the device is connected
  bool get isConnected => type == ConnectionType.connected;
  
  /// Returns true if the device is connecting
  bool get isConnecting => type == ConnectionType.connecting;
  
  /// Returns true if the device is disconnected
  bool get isDisconnected => type == ConnectionType.disconnected;
  
  /// Returns true if the connection failed
  bool get isFailed => type == ConnectionType.failed;
  
  /// Returns true if the device is offline
  bool get isOffline => type == ConnectionType.offline;
  
  /// Returns a user-friendly display name for the status
  String get displayName {
    switch (type) {
      case ConnectionType.disconnected:
        return 'Available';
      case ConnectionType.connecting:
        return 'Connecting...';
      case ConnectionType.connected:
        return 'Connected';
      case ConnectionType.failed:
        return 'Connection Failed';
      case ConnectionType.offline:
        return 'Offline';
    }
  }
}