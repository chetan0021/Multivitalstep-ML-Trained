// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PatientReading _$PatientReadingFromJson(Map<String, dynamic> json) {
  return _PatientReading.fromJson(json);
}

/// @nodoc
mixin _$PatientReading {
  String get id => throw _privateConstructorUsedError;
  set id(String value) => throw _privateConstructorUsedError;
  @JsonKey(name: 'patient_id')
  String get patientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'patient_id')
  set patientId(String value) => throw _privateConstructorUsedError;
  double get trial1 => throw _privateConstructorUsedError;
  set trial1(double value) => throw _privateConstructorUsedError;
  double get trial2 => throw _privateConstructorUsedError;
  set trial2(double value) => throw _privateConstructorUsedError;
  double get trial3 => throw _privateConstructorUsedError;
  set trial3(double value) => throw _privateConstructorUsedError;
  String get hand => throw _privateConstructorUsedError;
  set hand(String value) => throw _privateConstructorUsedError;
  String get posture => throw _privateConstructorUsedError;
  set posture(String value) => throw _privateConstructorUsedError;
  @JsonKey(name: 'assessment_type')
  String get assessmentType => throw _privateConstructorUsedError;
  @JsonKey(name: 'assessment_type')
  set assessmentType(String value) => throw _privateConstructorUsedError;
  @JsonKey(name: 'host_user_id')
  String get hostUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'host_user_id')
  set hostUserId(String value) => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  set createdAt(DateTime value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PatientReadingCopyWith<PatientReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientReadingCopyWith<$Res> {
  factory $PatientReadingCopyWith(
          PatientReading value, $Res Function(PatientReading) then) =
      _$PatientReadingCopyWithImpl<$Res, PatientReading>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'patient_id') String patientId,
      double trial1,
      double trial2,
      double trial3,
      String hand,
      String posture,
      @JsonKey(name: 'assessment_type') String assessmentType,
      @JsonKey(name: 'host_user_id') String hostUserId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$PatientReadingCopyWithImpl<$Res, $Val extends PatientReading>
    implements $PatientReadingCopyWith<$Res> {
  _$PatientReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? trial1 = null,
    Object? trial2 = null,
    Object? trial3 = null,
    Object? hand = null,
    Object? posture = null,
    Object? assessmentType = null,
    Object? hostUserId = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      trial1: null == trial1
          ? _value.trial1
          : trial1 // ignore: cast_nullable_to_non_nullable
              as double,
      trial2: null == trial2
          ? _value.trial2
          : trial2 // ignore: cast_nullable_to_non_nullable
              as double,
      trial3: null == trial3
          ? _value.trial3
          : trial3 // ignore: cast_nullable_to_non_nullable
              as double,
      hand: null == hand
          ? _value.hand
          : hand // ignore: cast_nullable_to_non_nullable
              as String,
      posture: null == posture
          ? _value.posture
          : posture // ignore: cast_nullable_to_non_nullable
              as String,
      assessmentType: null == assessmentType
          ? _value.assessmentType
          : assessmentType // ignore: cast_nullable_to_non_nullable
              as String,
      hostUserId: null == hostUserId
          ? _value.hostUserId
          : hostUserId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientReadingImplCopyWith<$Res>
    implements $PatientReadingCopyWith<$Res> {
  factory _$$PatientReadingImplCopyWith(_$PatientReadingImpl value,
          $Res Function(_$PatientReadingImpl) then) =
      __$$PatientReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'patient_id') String patientId,
      double trial1,
      double trial2,
      double trial3,
      String hand,
      String posture,
      @JsonKey(name: 'assessment_type') String assessmentType,
      @JsonKey(name: 'host_user_id') String hostUserId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$PatientReadingImplCopyWithImpl<$Res>
    extends _$PatientReadingCopyWithImpl<$Res, _$PatientReadingImpl>
    implements _$$PatientReadingImplCopyWith<$Res> {
  __$$PatientReadingImplCopyWithImpl(
      _$PatientReadingImpl _value, $Res Function(_$PatientReadingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? trial1 = null,
    Object? trial2 = null,
    Object? trial3 = null,
    Object? hand = null,
    Object? posture = null,
    Object? assessmentType = null,
    Object? hostUserId = null,
    Object? createdAt = null,
  }) {
    return _then(_$PatientReadingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as String,
      trial1: null == trial1
          ? _value.trial1
          : trial1 // ignore: cast_nullable_to_non_nullable
              as double,
      trial2: null == trial2
          ? _value.trial2
          : trial2 // ignore: cast_nullable_to_non_nullable
              as double,
      trial3: null == trial3
          ? _value.trial3
          : trial3 // ignore: cast_nullable_to_non_nullable
              as double,
      hand: null == hand
          ? _value.hand
          : hand // ignore: cast_nullable_to_non_nullable
              as String,
      posture: null == posture
          ? _value.posture
          : posture // ignore: cast_nullable_to_non_nullable
              as String,
      assessmentType: null == assessmentType
          ? _value.assessmentType
          : assessmentType // ignore: cast_nullable_to_non_nullable
              as String,
      hostUserId: null == hostUserId
          ? _value.hostUserId
          : hostUserId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientReadingImpl extends _PatientReading {
  _$PatientReadingImpl(
      {required this.id,
      @JsonKey(name: 'patient_id') required this.patientId,
      required this.trial1,
      required this.trial2,
      required this.trial3,
      required this.hand,
      required this.posture,
      @JsonKey(name: 'assessment_type') required this.assessmentType,
      @JsonKey(name: 'host_user_id') required this.hostUserId,
      @JsonKey(name: 'created_at') required this.createdAt})
      : super._();

  factory _$PatientReadingImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientReadingImplFromJson(json);

  @override
  String id;
  @override
  @JsonKey(name: 'patient_id')
  String patientId;
  @override
  double trial1;
  @override
  double trial2;
  @override
  double trial3;
  @override
  String hand;
  @override
  String posture;
  @override
  @JsonKey(name: 'assessment_type')
  String assessmentType;
  @override
  @JsonKey(name: 'host_user_id')
  String hostUserId;
  @override
  @JsonKey(name: 'created_at')
  DateTime createdAt;

  @override
  String toString() {
    return 'PatientReading(id: $id, patientId: $patientId, trial1: $trial1, trial2: $trial2, trial3: $trial3, hand: $hand, posture: $posture, assessmentType: $assessmentType, hostUserId: $hostUserId, createdAt: $createdAt)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientReadingImplCopyWith<_$PatientReadingImpl> get copyWith =>
      __$$PatientReadingImplCopyWithImpl<_$PatientReadingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientReadingImplToJson(
      this,
    );
  }
}

abstract class _PatientReading extends PatientReading {
  factory _PatientReading(
          {required String id,
          @JsonKey(name: 'patient_id') required String patientId,
          required double trial1,
          required double trial2,
          required double trial3,
          required String hand,
          required String posture,
          @JsonKey(name: 'assessment_type') required String assessmentType,
          @JsonKey(name: 'host_user_id') required String hostUserId,
          @JsonKey(name: 'created_at') required DateTime createdAt}) =
      _$PatientReadingImpl;
  _PatientReading._() : super._();

  factory _PatientReading.fromJson(Map<String, dynamic> json) =
      _$PatientReadingImpl.fromJson;

  @override
  String get id;
  set id(String value);
  @override
  @JsonKey(name: 'patient_id')
  String get patientId;
  @JsonKey(name: 'patient_id')
  set patientId(String value);
  @override
  double get trial1;
  set trial1(double value);
  @override
  double get trial2;
  set trial2(double value);
  @override
  double get trial3;
  set trial3(double value);
  @override
  String get hand;
  set hand(String value);
  @override
  String get posture;
  set posture(String value);
  @override
  @JsonKey(name: 'assessment_type')
  String get assessmentType;
  @JsonKey(name: 'assessment_type')
  set assessmentType(String value);
  @override
  @JsonKey(name: 'host_user_id')
  String get hostUserId;
  @JsonKey(name: 'host_user_id')
  set hostUserId(String value);
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @JsonKey(name: 'created_at')
  set createdAt(DateTime value);
  @override
  @JsonKey(ignore: true)
  _$$PatientReadingImplCopyWith<_$PatientReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
