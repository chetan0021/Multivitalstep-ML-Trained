// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Posture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostureImpl _$$PostureImplFromJson(Map<String, dynamic> json) =>
    _$PostureImpl(
      fullBodyWeight: json['fullBodyWeight'] as String?,
      fullArmWeight: json['fullArmWeight'] as String?,
      forwardLoading: json['forwardLoading'] as String?,
      backwardOffLoading: json['backwardOffLoading'] as String?,
      sideLoading: json['sideLoading'] as String?,
      sideOffLoading: json['sideOffLoading'] as String?,
    );

Map<String, dynamic> _$$PostureImplToJson(_$PostureImpl instance) =>
    <String, dynamic>{
      'fullBodyWeight': instance.fullBodyWeight,
      'fullArmWeight': instance.fullArmWeight,
      'forwardLoading': instance.forwardLoading,
      'backwardOffLoading': instance.backwardOffLoading,
      'sideLoading': instance.sideLoading,
      'sideOffLoading': instance.sideOffLoading,
    };
