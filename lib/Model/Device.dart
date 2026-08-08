import 'package:freezed_annotation/freezed_annotation.dart';

part 'Device.g.dart';
part 'Device.freezed.dart';

@freezed
class Device with _$Device {
  const Device._();
  const factory Device({
    required int id,
    required int userId,
    required String deviceName,
    required String deviceCode,
    DateTime? createdAt,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}
