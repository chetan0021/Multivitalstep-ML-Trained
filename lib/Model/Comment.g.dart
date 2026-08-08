// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: (json['id'] as num).toInt(),
      assessmentId: (json['assessmentId'] as num).toInt(),
      AssignerId: (json['AssignerId'] as num).toInt(),
      remarks: json['remarks'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assessmentId': instance.assessmentId,
      'AssignerId': instance.AssignerId,
      'remarks': instance.remarks,
      'createdAt': instance.createdAt.toIso8601String(),
    };
