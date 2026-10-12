// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accounts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Accounts _$AccountsFromJson(Map<String, dynamic> json) {
  return _Accounts.fromJson(json);
}

/// @nodoc
mixin _$Accounts {
  int get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  int get specialistId => throw _privateConstructorUsedError;
  Profile get user => throw _privateConstructorUsedError;
  ProfileSpecialist? get specialist => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountsCopyWith<Accounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountsCopyWith<$Res> {
  factory $AccountsCopyWith(Accounts value, $Res Function(Accounts) then) =
      _$AccountsCopyWithImpl<$Res, Accounts>;
  @useResult
  $Res call(
      {int id,
      int userId,
      int specialistId,
      Profile user,
      ProfileSpecialist? specialist});

  $ProfileCopyWith<$Res> get user;
  $ProfileSpecialistCopyWith<$Res>? get specialist;
}

/// @nodoc
class _$AccountsCopyWithImpl<$Res, $Val extends Accounts>
    implements $AccountsCopyWith<$Res> {
  _$AccountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? specialistId = null,
    Object? user = null,
    Object? specialist = freezed,
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
      specialistId: null == specialistId
          ? _value.specialistId
          : specialistId // ignore: cast_nullable_to_non_nullable
              as int,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as Profile,
      specialist: freezed == specialist
          ? _value.specialist
          : specialist // ignore: cast_nullable_to_non_nullable
              as ProfileSpecialist?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProfileCopyWith<$Res> get user {
    return $ProfileCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProfileSpecialistCopyWith<$Res>? get specialist {
    if (_value.specialist == null) {
      return null;
    }

    return $ProfileSpecialistCopyWith<$Res>(_value.specialist!, (value) {
      return _then(_value.copyWith(specialist: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AccountsImplCopyWith<$Res>
    implements $AccountsCopyWith<$Res> {
  factory _$$AccountsImplCopyWith(
          _$AccountsImpl value, $Res Function(_$AccountsImpl) then) =
      __$$AccountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int userId,
      int specialistId,
      Profile user,
      ProfileSpecialist? specialist});

  @override
  $ProfileCopyWith<$Res> get user;
  @override
  $ProfileSpecialistCopyWith<$Res>? get specialist;
}

/// @nodoc
class __$$AccountsImplCopyWithImpl<$Res>
    extends _$AccountsCopyWithImpl<$Res, _$AccountsImpl>
    implements _$$AccountsImplCopyWith<$Res> {
  __$$AccountsImplCopyWithImpl(
      _$AccountsImpl _value, $Res Function(_$AccountsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? specialistId = null,
    Object? user = null,
    Object? specialist = freezed,
  }) {
    return _then(_$AccountsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      specialistId: null == specialistId
          ? _value.specialistId
          : specialistId // ignore: cast_nullable_to_non_nullable
              as int,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as Profile,
      specialist: freezed == specialist
          ? _value.specialist
          : specialist // ignore: cast_nullable_to_non_nullable
              as ProfileSpecialist?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountsImpl extends _Accounts {
  const _$AccountsImpl(
      {required this.id,
      required this.userId,
      required this.specialistId,
      required this.user,
      this.specialist})
      : super._();

  factory _$AccountsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountsImplFromJson(json);

  @override
  final int id;
  @override
  final int userId;
  @override
  final int specialistId;
  @override
  final Profile user;
  @override
  final ProfileSpecialist? specialist;

  @override
  String toString() {
    return 'Accounts(id: $id, userId: $userId, specialistId: $specialistId, user: $user, specialist: $specialist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.specialistId, specialistId) ||
                other.specialistId == specialistId) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.specialist, specialist) ||
                other.specialist == specialist));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, specialistId, user, specialist);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountsImplCopyWith<_$AccountsImpl> get copyWith =>
      __$$AccountsImplCopyWithImpl<_$AccountsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountsImplToJson(
      this,
    );
  }
}

abstract class _Accounts extends Accounts {
  const factory _Accounts(
      {required final int id,
      required final int userId,
      required final int specialistId,
      required final Profile user,
      final ProfileSpecialist? specialist}) = _$AccountsImpl;
  const _Accounts._() : super._();

  factory _Accounts.fromJson(Map<String, dynamic> json) =
      _$AccountsImpl.fromJson;

  @override
  int get id;
  @override
  int get userId;
  @override
  int get specialistId;
  @override
  Profile get user;
  @override
  ProfileSpecialist? get specialist;
  @override
  @JsonKey(ignore: true)
  _$$AccountsImplCopyWith<_$AccountsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
