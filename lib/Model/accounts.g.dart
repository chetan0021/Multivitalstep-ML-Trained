// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountsImpl _$$AccountsImplFromJson(Map<String, dynamic> json) =>
    _$AccountsImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      specialistId: (json['specialistId'] as num).toInt(),
      user: Profile.fromJson(json['user'] as Map<String, dynamic>),
      specialist: json['specialist'] == null
          ? null
          : ProfileSpecialist.fromJson(
              json['specialist'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AccountsImplToJson(_$AccountsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'specialistId': instance.specialistId,
      'user': instance.user,
      'specialist': instance.specialist,
    };
