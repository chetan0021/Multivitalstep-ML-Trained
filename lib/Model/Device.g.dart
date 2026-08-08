// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceImpl _$$DeviceImplFromJson(Map<String, dynamic> json) => _$DeviceImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      deviceName: json['deviceName'] as String,
      deviceCode: json['deviceCode'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DeviceImplToJson(_$DeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'deviceName': instance.deviceName,
      'deviceCode': instance.deviceCode,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
