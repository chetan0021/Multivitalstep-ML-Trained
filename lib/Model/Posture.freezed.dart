// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'Posture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Posture _$PostureFromJson(Map<String, dynamic> json) {
  return _Posture.fromJson(json);
}

/// @nodoc
mixin _$Posture {
  String? get fullBodyWeight => throw _privateConstructorUsedError;
  String? get fullArmWeight => throw _privateConstructorUsedError;
  String? get forwardLoading => throw _privateConstructorUsedError;
  String? get backwardOffLoading => throw _privateConstructorUsedError;
  String? get sideLoading => throw _privateConstructorUsedError;
  String? get sideOffLoading => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostureCopyWith<Posture> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostureCopyWith<$Res> {
  factory $PostureCopyWith(Posture value, $Res Function(Posture) then) =
      _$PostureCopyWithImpl<$Res, Posture>;
  @useResult
  $Res call(
      {String? fullBodyWeight,
      String? fullArmWeight,
      String? forwardLoading,
      String? backwardOffLoading,
      String? sideLoading,
      String? sideOffLoading});
}

/// @nodoc
class _$PostureCopyWithImpl<$Res, $Val extends Posture>
    implements $PostureCopyWith<$Res> {
  _$PostureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullBodyWeight = freezed,
    Object? fullArmWeight = freezed,
    Object? forwardLoading = freezed,
    Object? backwardOffLoading = freezed,
    Object? sideLoading = freezed,
    Object? sideOffLoading = freezed,
  }) {
    return _then(_value.copyWith(
      fullBodyWeight: freezed == fullBodyWeight
          ? _value.fullBodyWeight
          : fullBodyWeight // ignore: cast_nullable_to_non_nullable
              as String?,
      fullArmWeight: freezed == fullArmWeight
          ? _value.fullArmWeight
          : fullArmWeight // ignore: cast_nullable_to_non_nullable
              as String?,
      forwardLoading: freezed == forwardLoading
          ? _value.forwardLoading
          : forwardLoading // ignore: cast_nullable_to_non_nullable
              as String?,
      backwardOffLoading: freezed == backwardOffLoading
          ? _value.backwardOffLoading
          : backwardOffLoading // ignore: cast_nullable_to_non_nullable
              as String?,
      sideLoading: freezed == sideLoading
          ? _value.sideLoading
          : sideLoading // ignore: cast_nullable_to_non_nullable
              as String?,
      sideOffLoading: freezed == sideOffLoading
          ? _value.sideOffLoading
          : sideOffLoading // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostureImplCopyWith<$Res> implements $PostureCopyWith<$Res> {
  factory _$$PostureImplCopyWith(
          _$PostureImpl value, $Res Function(_$PostureImpl) then) =
      __$$PostureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? fullBodyWeight,
      String? fullArmWeight,
      String? forwardLoading,
      String? backwardOffLoading,
      String? sideLoading,
      String? sideOffLoading});
}

/// @nodoc
class __$$PostureImplCopyWithImpl<$Res>
    extends _$PostureCopyWithImpl<$Res, _$PostureImpl>
    implements _$$PostureImplCopyWith<$Res> {
  __$$PostureImplCopyWithImpl(
      _$PostureImpl _value, $Res Function(_$PostureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullBodyWeight = freezed,
    Object? fullArmWeight = freezed,
    Object? forwardLoading = freezed,
    Object? backwardOffLoading = freezed,
    Object? sideLoading = freezed,
    Object? sideOffLoading = freezed,
  }) {
    return _then(_$PostureImpl(
      fullBodyWeight: freezed == fullBodyWeight
          ? _value.fullBodyWeight
          : fullBodyWeight // ignore: cast_nullable_to_non_nullable
              as String?,
      fullArmWeight: freezed == fullArmWeight
          ? _value.fullArmWeight
          : fullArmWeight // ignore: cast_nullable_to_non_nullable
              as String?,
      forwardLoading: freezed == forwardLoading
          ? _value.forwardLoading
          : forwardLoading // ignore: cast_nullable_to_non_nullable
              as String?,
      backwardOffLoading: freezed == backwardOffLoading
          ? _value.backwardOffLoading
          : backwardOffLoading // ignore: cast_nullable_to_non_nullable
              as String?,
      sideLoading: freezed == sideLoading
          ? _value.sideLoading
          : sideLoading // ignore: cast_nullable_to_non_nullable
              as String?,
      sideOffLoading: freezed == sideOffLoading
          ? _value.sideOffLoading
          : sideOffLoading // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostureImpl extends _Posture {
  const _$PostureImpl(
      {this.fullBodyWeight,
      this.fullArmWeight,
      this.forwardLoading,
      this.backwardOffLoading,
      this.sideLoading,
      this.sideOffLoading})
      : super._();

  factory _$PostureImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostureImplFromJson(json);

  @override
  final String? fullBodyWeight;
  @override
  final String? fullArmWeight;
  @override
  final String? forwardLoading;
  @override
  final String? backwardOffLoading;
  @override
  final String? sideLoading;
  @override
  final String? sideOffLoading;

  @override
  String toString() {
    return 'Posture(fullBodyWeight: $fullBodyWeight, fullArmWeight: $fullArmWeight, forwardLoading: $forwardLoading, backwardOffLoading: $backwardOffLoading, sideLoading: $sideLoading, sideOffLoading: $sideOffLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostureImpl &&
            (identical(other.fullBodyWeight, fullBodyWeight) ||
                other.fullBodyWeight == fullBodyWeight) &&
            (identical(other.fullArmWeight, fullArmWeight) ||
                other.fullArmWeight == fullArmWeight) &&
            (identical(other.forwardLoading, forwardLoading) ||
                other.forwardLoading == forwardLoading) &&
            (identical(other.backwardOffLoading, backwardOffLoading) ||
                other.backwardOffLoading == backwardOffLoading) &&
            (identical(other.sideLoading, sideLoading) ||
                other.sideLoading == sideLoading) &&
            (identical(other.sideOffLoading, sideOffLoading) ||
                other.sideOffLoading == sideOffLoading));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, fullBodyWeight, fullArmWeight,
      forwardLoading, backwardOffLoading, sideLoading, sideOffLoading);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostureImplCopyWith<_$PostureImpl> get copyWith =>
      __$$PostureImplCopyWithImpl<_$PostureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostureImplToJson(
      this,
    );
  }
}

abstract class _Posture extends Posture {
  const factory _Posture(
      {final String? fullBodyWeight,
      final String? fullArmWeight,
      final String? forwardLoading,
      final String? backwardOffLoading,
      final String? sideLoading,
      final String? sideOffLoading}) = _$PostureImpl;
  const _Posture._() : super._();

  factory _Posture.fromJson(Map<String, dynamic> json) = _$PostureImpl.fromJson;

  @override
  String? get fullBodyWeight;
  @override
  String? get fullArmWeight;
  @override
  String? get forwardLoading;
  @override
  String? get backwardOffLoading;
  @override
  String? get sideLoading;
  @override
  String? get sideOffLoading;
  @override
  @JsonKey(ignore: true)
  _$$PostureImplCopyWith<_$PostureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
