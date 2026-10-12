// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SignUpInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignUpInfoImpl _$$SignUpInfoImplFromJson(Map<String, dynamic> json) =>
    _$SignUpInfoImpl(
      name: json['name'] as String,
      phone: (json['phone'] as num).toInt(),
      countryCode: json['countryCode'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      dob: json['dob'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
      pincode: (json['pincode'] as num?)?.toInt(),
      address: json['address'] as String?,
      weight: (json['weight'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      palmLength: (json['palm_length'] as num?)?.toDouble(),
      palmWidth: (json['palm_width'] as num?)?.toDouble(),
      knuckleLength: (json['knuckles_length'] as num?)?.toDouble(),
      dominantHand: json['dominant_hand'] as String,
      gender: json['gender'] as String,
    );

Map<String, dynamic> _$$SignUpInfoImplToJson(_$SignUpInfoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'countryCode': instance.countryCode,
      'email': instance.email,
      'password': instance.password,
      'dob': instance.dob,
      'city': instance.city,
      'country': instance.country,
      'pincode': instance.pincode,
      'address': instance.address,
      'weight': instance.weight,
      'height': instance.height,
      'palm_length': instance.palmLength,
      'palm_width': instance.palmWidth,
      'knuckles_length': instance.knuckleLength,
      'dominant_hand': instance.dominantHand,
      'gender': instance.gender,
    };
