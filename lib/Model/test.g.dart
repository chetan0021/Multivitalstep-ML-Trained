// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TestImpl _$$TestImplFromJson(Map<String, dynamic> json) => _$TestImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      deviceId: (json['deviceId'] as num).toInt(),
      assestmentId: (json['assestmentId'] as num).toInt(),
      posture: json['posture'] as String,
      trial1: json['trial1'] as String,
      trial2: json['trial2'] as String,
      trial3: json['trial3'] as String,
      hand: json['hand'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TestImplToJson(_$TestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'assestmentId': instance.assestmentId,
      'posture': instance.posture,
      'trial1': instance.trial1,
      'trial2': instance.trial2,
      'trial3': instance.trial3,
      'hand': instance.hand,
      'createdAt': instance.createdAt.toIso8601String(),
    };
