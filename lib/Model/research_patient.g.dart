// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResearchPatientImpl _$$ResearchPatientImplFromJson(
        Map<String, dynamic> json) =>
    _$ResearchPatientImpl(
      id: json['id'] as String,
      patientCode: json['patient_code'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      contact: json['contact'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      condition: json['condition'] as String? ?? 'None',
      notes: json['notes'] as String? ?? '',
      hostUserId: json['host_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      dob: json['dob'] as String?,
      dominantHand: json['dominant_hand'] as String?,
      height: (json['height'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
      palmLength: (json['palm_length'] as num?)?.toDouble(),
      palmWidth: (json['palm_width'] as num?)?.toDouble(),
      knuckleLength: (json['knuckle_length'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ResearchPatientImplToJson(
        _$ResearchPatientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_code': instance.patientCode,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'contact': instance.contact,
      'phone': instance.phone,
      'email': instance.email,
      'condition': instance.condition,
      'notes': instance.notes,
      'host_user_id': instance.hostUserId,
      'created_at': instance.createdAt.toIso8601String(),
      'dob': instance.dob,
      'dominant_hand': instance.dominantHand,
      'height': instance.height,
      'weight': instance.weight,
      'palm_length': instance.palmLength,
      'palm_width': instance.palmWidth,
      'knuckle_length': instance.knuckleLength,
    };
