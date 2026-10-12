// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'Assessment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Assessment _$AssessmentFromJson(Map<String, dynamic> json) {
  return _Assesment.fromJson(json);
}

/// @nodoc
mixin _$Assessment {
  int get id => throw _privateConstructorUsedError;
  set id(int value) => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  set userId(int value) => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  set type(String value) => throw _privateConstructorUsedError;
  String get posture => throw _privateConstructorUsedError;
  set posture(String value) => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  set status(String value) => throw _privateConstructorUsedError;
  bool? get currentlyActive => throw _privateConstructorUsedError;
  set currentlyActive(bool? value) => throw _privateConstructorUsedError;
  int? get queueId => throw _privateConstructorUsedError;
  set queueId(int? value) => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  set createdAt(DateTime value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssessmentCopyWith<Assessment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssessmentCopyWith<$Res> {
  factory $AssessmentCopyWith(
          Assessment value, $Res Function(Assessment) then) =
      _$AssessmentCopyWithImpl<$Res, Assessment>;
  @useResult
  $Res call(
      {int id,
      int userId,
      String type,
      String posture,
      String status,
      bool? currentlyActive,
      int? queueId,
      DateTime createdAt});
}

/// @nodoc
class _$AssessmentCopyWithImpl<$Res, $Val extends Assessment>
    implements $AssessmentCopyWith<$Res> {
  _$AssessmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? posture = null,
    Object? status = null,
    Object? currentlyActive = freezed,
    Object? queueId = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      posture: null == posture
          ? _value.posture
          : posture // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      currentlyActive: freezed == currentlyActive
          ? _value.currentlyActive
          : currentlyActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      queueId: freezed == queueId
          ? _value.queueId
          : queueId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssesmentImplCopyWith<$Res>
    implements $AssessmentCopyWith<$Res> {
  factory _$$AssesmentImplCopyWith(
          _$AssesmentImpl value, $Res Function(_$AssesmentImpl) then) =
      __$$AssesmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int userId,
      String type,
      String posture,
      String status,
      bool? currentlyActive,
      int? queueId,
      DateTime createdAt});
}

/// @nodoc
class __$$AssesmentImplCopyWithImpl<$Res>
    extends _$AssessmentCopyWithImpl<$Res, _$AssesmentImpl>
    implements _$$AssesmentImplCopyWith<$Res> {
  __$$AssesmentImplCopyWithImpl(
      _$AssesmentImpl _value, $Res Function(_$AssesmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? posture = null,
    Object? status = null,
    Object? currentlyActive = freezed,
    Object? queueId = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$AssesmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      posture: null == posture
          ? _value.posture
          : posture // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      currentlyActive: freezed == currentlyActive
          ? _value.currentlyActive
          : currentlyActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      queueId: freezed == queueId
          ? _value.queueId
          : queueId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssesmentImpl extends _Assesment {
  _$AssesmentImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.posture,
      required this.status,
      this.currentlyActive,
      this.queueId,
      required this.createdAt})
      : super._();

  factory _$AssesmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssesmentImplFromJson(json);

  @override
  int id;
  @override
  int userId;
  @override
  String type;
  @override
  String posture;
  @override
  String status;
  @override
  bool? currentlyActive;
  @override
  int? queueId;
  @override
  DateTime createdAt;

  @override
  String toString() {
    return 'Assessment(id: $id, userId: $userId, type: $type, posture: $posture, status: $status, currentlyActive: $currentlyActive, queueId: $queueId, createdAt: $createdAt)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssesmentImplCopyWith<_$AssesmentImpl> get copyWith =>
      __$$AssesmentImplCopyWithImpl<_$AssesmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssesmentImplToJson(
      this,
    );
  }
}

abstract class _Assesment extends Assessment {
  factory _Assesment(
      {required int id,
      required int userId,
      required String type,
      required String posture,
      required String status,
      bool? currentlyActive,
      int? queueId,
      required DateTime createdAt}) = _$AssesmentImpl;
  _Assesment._() : super._();

  factory _Assesment.fromJson(Map<String, dynamic> json) =
      _$AssesmentImpl.fromJson;

  @override
  int get id;
  set id(int value);
  @override
  int get userId;
  set userId(int value);
  @override
  String get type;
  set type(String value);
  @override
  String get posture;
  set posture(String value);
  @override
  String get status;
  set status(String value);
  @override
  bool? get currentlyActive;
  set currentlyActive(bool? value);
  @override
  int? get queueId;
  set queueId(int? value);
  @override
  DateTime get createdAt;
  set createdAt(DateTime value);
  @override
  @JsonKey(ignore: true)
  _$$AssesmentImplCopyWith<_$AssesmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
