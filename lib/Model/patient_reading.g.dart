// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientReadingImpl _$$PatientReadingImplFromJson(Map<String, dynamic> json) =>
    _$PatientReadingImpl(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      trial1: (json['trial1'] as num).toDouble(),
      trial2: (json['trial2'] as num).toDouble(),
      trial3: (json['trial3'] as num).toDouble(),
      hand: json['hand'] as String,
      posture: json['posture'] as String,
      assessmentType: json['assessment_type'] as String,
      hostUserId: json['host_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$PatientReadingImplToJson(
        _$PatientReadingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'trial1': instance.trial1,
      'trial2': instance.trial2,
      'trial3': instance.trial3,
      'hand': instance.hand,
      'posture': instance.posture,
      'assessment_type': instance.assessmentType,
      'host_user_id': instance.hostUserId,
      'created_at': instance.createdAt.toIso8601String(),
    };
