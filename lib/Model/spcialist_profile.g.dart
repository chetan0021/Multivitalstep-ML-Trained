// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spcialist_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileSpecialistImpl _$$ProfileSpecialistImplFromJson(
        Map<String, dynamic> json) =>
    _$ProfileSpecialistImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      countryCode: json['countryCode'] as String,
      email: json['email'] as String,
      dob: json['dob'] as String,
      phone: json['phone'],
      password: json['password'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      pincode: json['pincode'],
      address: json['address'],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      accounts: (json['accounts'] as List<dynamic>?)
          ?.map((e) => Accounts.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProfileSpecialistImplToJson(
        _$ProfileSpecialistImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'countryCode': instance.countryCode,
      'email': instance.email,
      'dob': instance.dob,
      'phone': instance.phone,
      'password': instance.password,
      'city': instance.city,
      'country': instance.country,
      'pincode': instance.pincode,
      'address': instance.address,
      'createdAt': instance.createdAt?.toIso8601String(),
      'accounts': instance.accounts,
    };
