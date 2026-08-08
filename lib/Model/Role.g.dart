// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoleImpl _$$RoleImplFromJson(Map<String, dynamic> json) => _$RoleImpl(
      doctor: json['doctor'] as String?,
      operator: json['operator'] as String?,
      patient: json['patient'] as String?,
      admin: json['admin'] as String?,
    );

Map<String, dynamic> _$$RoleImplToJson(_$RoleImpl instance) =>
    <String, dynamic>{
      'doctor': instance.doctor,
      'operator': instance.operator,
      'patient': instance.patient,
      'admin': instance.admin,
    };
