// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssesmentImpl _$$AssesmentImplFromJson(Map<String, dynamic> json) =>
    _$AssesmentImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      type: json['type'] as String,
      posture: json['posture'] as String,
      status: json['status'] as String,
      currentlyActive: json['currentlyActive'] as bool?,
      queueId: (json['queueId'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AssesmentImplToJson(_$AssesmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'posture': instance.posture,
      'status': instance.status,
      'currentlyActive': instance.currentlyActive,
      'queueId': instance.queueId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
