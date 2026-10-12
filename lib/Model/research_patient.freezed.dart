// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'research_patient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ResearchPatient _$ResearchPatientFromJson(Map<String, dynamic> json) {
  return _ResearchPatient.fromJson(json);
}

/// @nodoc
mixin _$ResearchPatient {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'patient_code')
  String get patientCode => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  String get contact => throw _privateConstructorUsedError; // legacy
  String get phone => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get condition => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'host_user_id')
  String get hostUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Clinical fields (optional — filled during patient registration)
  @JsonKey(name: 'dob')
  String? get dob => throw _privateConstructorUsedError;
  @JsonKey(name: 'dominant_hand')
  String? get dominantHand => throw _privateConstructorUsedError;
  @JsonKey(name: 'height')
  int? get height => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight')
  int? get weight => throw _privateConstructorUsedError;
  @JsonKey(name: 'palm_length')
  double? get palmLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'palm_width')
  double? get palmWidth => throw _privateConstructorUsedError;
  @JsonKey(name: 'knuckle_length')
  double? get knuckleLength => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ResearchPatientCopyWith<ResearchPatient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResearchPatientCopyWith<$Res> {
  factory $ResearchPatientCopyWith(
          ResearchPatient value, $Res Function(ResearchPatient) then) =
      _$ResearchPatientCopyWithImpl<$Res, ResearchPatient>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'patient_code') String patientCode,
      String name,
      int age,
      String gender,
      String contact,
      String phone,
      String email,
      String condition,
      String notes,
      @JsonKey(name: 'host_user_id') String hostUserId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'dob') String? dob,
      @JsonKey(name: 'dominant_hand') String? dominantHand,
      @JsonKey(name: 'height') int? height,
      @JsonKey(name: 'weight') int? weight,
      @JsonKey(name: 'palm_length') double? palmLength,
      @JsonKey(name: 'palm_width') double? palmWidth,
      @JsonKey(name: 'knuckle_length') double? knuckleLength});
}

/// @nodoc
class _$ResearchPatientCopyWithImpl<$Res, $Val extends ResearchPatient>
    implements $ResearchPatientCopyWith<$Res> {
  _$ResearchPatientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientCode = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? contact = null,
    Object? phone = null,
    Object? email = null,
    Object? condition = null,
    Object? notes = null,
    Object? hostUserId = null,
    Object? createdAt = null,
    Object? dob = freezed,
    Object? dominantHand = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? palmLength = freezed,
    Object? palmWidth = freezed,
    Object? knuckleLength = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientCode: null == patientCode
          ? _value.patientCode
          : patientCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      contact: null == contact
          ? _value.contact
          : contact // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      hostUserId: null == hostUserId
          ? _value.hostUserId
          : hostUserId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      dominantHand: freezed == dominantHand
          ? _value.dominantHand
          : dominantHand // ignore: cast_nullable_to_non_nullable
              as String?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int?,
      palmLength: freezed == palmLength
          ? _value.palmLength
          : palmLength // ignore: cast_nullable_to_non_nullable
              as double?,
      palmWidth: freezed == palmWidth
          ? _value.palmWidth
          : palmWidth // ignore: cast_nullable_to_non_nullable
              as double?,
      knuckleLength: freezed == knuckleLength
          ? _value.knuckleLength
          : knuckleLength // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResearchPatientImplCopyWith<$Res>
    implements $ResearchPatientCopyWith<$Res> {
  factory _$$ResearchPatientImplCopyWith(_$ResearchPatientImpl value,
          $Res Function(_$ResearchPatientImpl) then) =
      __$$ResearchPatientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'patient_code') String patientCode,
      String name,
      int age,
      String gender,
      String contact,
      String phone,
      String email,
      String condition,
      String notes,
      @JsonKey(name: 'host_user_id') String hostUserId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'dob') String? dob,
      @JsonKey(name: 'dominant_hand') String? dominantHand,
      @JsonKey(name: 'height') int? height,
      @JsonKey(name: 'weight') int? weight,
      @JsonKey(name: 'palm_length') double? palmLength,
      @JsonKey(name: 'palm_width') double? palmWidth,
      @JsonKey(name: 'knuckle_length') double? knuckleLength});
}

/// @nodoc
class __$$ResearchPatientImplCopyWithImpl<$Res>
    extends _$ResearchPatientCopyWithImpl<$Res, _$ResearchPatientImpl>
    implements _$$ResearchPatientImplCopyWith<$Res> {
  __$$ResearchPatientImplCopyWithImpl(
      _$ResearchPatientImpl _value, $Res Function(_$ResearchPatientImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientCode = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? contact = null,
    Object? phone = null,
    Object? email = null,
    Object? condition = null,
    Object? notes = null,
    Object? hostUserId = null,
    Object? createdAt = null,
    Object? dob = freezed,
    Object? dominantHand = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? palmLength = freezed,
    Object? palmWidth = freezed,
    Object? knuckleLength = freezed,
  }) {
    return _then(_$ResearchPatientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      patientCode: null == patientCode
          ? _value.patientCode
          : patientCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      contact: null == contact
          ? _value.contact
          : contact // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      hostUserId: null == hostUserId
          ? _value.hostUserId
          : hostUserId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      dominantHand: freezed == dominantHand
          ? _value.dominantHand
          : dominantHand // ignore: cast_nullable_to_non_nullable
              as String?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int?,
      palmLength: freezed == palmLength
          ? _value.palmLength
          : palmLength // ignore: cast_nullable_to_non_nullable
              as double?,
      palmWidth: freezed == palmWidth
          ? _value.palmWidth
          : palmWidth // ignore: cast_nullable_to_non_nullable
              as double?,
      knuckleLength: freezed == knuckleLength
          ? _value.knuckleLength
          : knuckleLength // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResearchPatientImpl extends _ResearchPatient {
  const _$ResearchPatientImpl(
      {required this.id,
      @JsonKey(name: 'patient_code') required this.patientCode,
      required this.name,
      required this.age,
      required this.gender,
      this.contact = '',
      this.phone = '',
      this.email = '',
      this.condition = 'None',
      this.notes = '',
      @JsonKey(name: 'host_user_id') required this.hostUserId,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'dob') this.dob,
      @JsonKey(name: 'dominant_hand') this.dominantHand,
      @JsonKey(name: 'height') this.height,
      @JsonKey(name: 'weight') this.weight,
      @JsonKey(name: 'palm_length') this.palmLength,
      @JsonKey(name: 'palm_width') this.palmWidth,
      @JsonKey(name: 'knuckle_length') this.knuckleLength})
      : super._();

  factory _$ResearchPatientImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResearchPatientImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'patient_code')
  final String patientCode;
  @override
  final String name;
  @override
  final int age;
  @override
  final String gender;
  @override
  @JsonKey()
  final String contact;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String condition;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'host_user_id')
  final String hostUserId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// Clinical fields (optional — filled during patient registration)
  @override
  @JsonKey(name: 'dob')
  final String? dob;
  @override
  @JsonKey(name: 'dominant_hand')
  final String? dominantHand;
  @override
  @JsonKey(name: 'height')
  final int? height;
  @override
  @JsonKey(name: 'weight')
  final int? weight;
  @override
  @JsonKey(name: 'palm_length')
  final double? palmLength;
  @override
  @JsonKey(name: 'palm_width')
  final double? palmWidth;
  @override
  @JsonKey(name: 'knuckle_length')
  final double? knuckleLength;

  @override
  String toString() {
    return 'ResearchPatient(id: $id, patientCode: $patientCode, name: $name, age: $age, gender: $gender, contact: $contact, phone: $phone, email: $email, condition: $condition, notes: $notes, hostUserId: $hostUserId, createdAt: $createdAt, dob: $dob, dominantHand: $dominantHand, height: $height, weight: $weight, palmLength: $palmLength, palmWidth: $palmWidth, knuckleLength: $knuckleLength)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResearchPatientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientCode, patientCode) ||
                other.patientCode == patientCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.contact, contact) || other.contact == contact) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.hostUserId, hostUserId) ||
                other.hostUserId == hostUserId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.dominantHand, dominantHand) ||
                other.dominantHand == dominantHand) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.palmLength, palmLength) ||
                other.palmLength == palmLength) &&
            (identical(other.palmWidth, palmWidth) ||
                other.palmWidth == palmWidth) &&
            (identical(other.knuckleLength, knuckleLength) ||
                other.knuckleLength == knuckleLength));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      patientCode,
      name,
      age,
      gender,
      contact,
      phone,
      email,
      condition,
      notes,
      hostUserId,
      createdAt,
      dob,
      dominantHand,
      height,
      weight,
      palmLength,
      palmWidth,
      knuckleLength);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ResearchPatientImplCopyWith<_$ResearchPatientImpl> get copyWith =>
      __$$ResearchPatientImplCopyWithImpl<_$ResearchPatientImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResearchPatientImplToJson(
      this,
    );
  }
}

abstract class _ResearchPatient extends ResearchPatient {
  const factory _ResearchPatient(
          {required final String id,
          @JsonKey(name: 'patient_code') required final String patientCode,
          required final String name,
          required final int age,
          required final String gender,
          final String contact,
          final String phone,
          final String email,
          final String condition,
          final String notes,
          @JsonKey(name: 'host_user_id') required final String hostUserId,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'dob') final String? dob,
          @JsonKey(name: 'dominant_hand') final String? dominantHand,
          @JsonKey(name: 'height') final int? height,
          @JsonKey(name: 'weight') final int? weight,
          @JsonKey(name: 'palm_length') final double? palmLength,
          @JsonKey(name: 'palm_width') final double? palmWidth,
          @JsonKey(name: 'knuckle_length') final double? knuckleLength}) =
      _$ResearchPatientImpl;
  const _ResearchPatient._() : super._();

  factory _ResearchPatient.fromJson(Map<String, dynamic> json) =
      _$ResearchPatientImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'patient_code')
  String get patientCode;
  @override
  String get name;
  @override
  int get age;
  @override
  String get gender;
  @override
  String get contact; // legacy
  @override
  String get phone;
  @override
  String get email;
  @override
  String get condition;
  @override
  String get notes;
  @override
  @JsonKey(name: 'host_user_id')
  String get hostUserId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override // Clinical fields (optional — filled during patient registration)
  @JsonKey(name: 'dob')
  String? get dob;
  @override
  @JsonKey(name: 'dominant_hand')
  String? get dominantHand;
  @override
  @JsonKey(name: 'height')
  int? get height;
  @override
  @JsonKey(name: 'weight')
  int? get weight;
  @override
  @JsonKey(name: 'palm_length')
  double? get palmLength;
  @override
  @JsonKey(name: 'palm_width')
  double? get palmWidth;
  @override
  @JsonKey(name: 'knuckle_length')
  double? get knuckleLength;
  @override
  @JsonKey(ignore: true)
  _$$ResearchPatientImplCopyWith<_$ResearchPatientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
