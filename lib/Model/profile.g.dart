// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      phone: json['phone'],
      countryCode: json['countryCode'] as String,
      email: json['email'] as String?,
      dob: json['dob'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      pincode: json['pincode'],
      address: json['address'] as String?,
      weight: (json['weight'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      palmLength: json['palm_length'],
      palmWidth: json['palm_width'],
      knucklesLength: json['knuckles_length'],
      dominantHand: json['dominant_hand'] as String?,
      gender: json['gender'] as String?,
      access_code: json['accessCode'] as String?,
      device: (json['device'] as List<dynamic>?)
          ?.map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList(),
      assessment: (json['assessment'] as List<dynamic>?)
          ?.map((e) => Assessment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'countryCode': instance.countryCode,
      'email': instance.email,
      'dob': instance.dob,
      'city': instance.city,
      'country': instance.country,
      'pincode': instance.pincode,
      'address': instance.address,
      'weight': instance.weight,
      'height': instance.height,
      'palm_length': instance.palmLength,
      'palm_width': instance.palmWidth,
      'knuckles_length': instance.knucklesLength,
      'dominant_hand': instance.dominantHand,
      'gender': instance.gender,
      'accessCode': instance.access_code,
      'device': instance.device,
      'assessment': instance.assessment,
    };
