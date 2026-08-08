// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  dynamic get phone => throw _privateConstructorUsedError;
  String get countryCode => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get dob => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  dynamic get pincode => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  int get weight => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  @JsonKey(name: "palm_length")
  dynamic get palmLength => throw _privateConstructorUsedError;
  @JsonKey(name: "palm_width")
  dynamic get palmWidth => throw _privateConstructorUsedError;
  @JsonKey(name: "knuckles_length")
  dynamic get knucklesLength => throw _privateConstructorUsedError;
  @JsonKey(name: "dominant_hand")
  String? get dominantHand => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: "accessCode")
  String? get access_code => throw _privateConstructorUsedError;
  List<Device>? get device => throw _privateConstructorUsedError;
  List<Assessment>? get assessment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call(
      {int? id,
      String? name,
      dynamic phone,
      String countryCode,
      String? email,
      String? dob,
      String? city,
      String? country,
      dynamic pincode,
      String? address,
      int weight,
      int height,
      @JsonKey(name: "palm_length") dynamic palmLength,
      @JsonKey(name: "palm_width") dynamic palmWidth,
      @JsonKey(name: "knuckles_length") dynamic knucklesLength,
      @JsonKey(name: "dominant_hand") String? dominantHand,
      String? gender,
      @JsonKey(name: "accessCode") String? access_code,
      List<Device>? device,
      List<Assessment>? assessment});
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? phone = freezed,
    Object? countryCode = null,
    Object? email = freezed,
    Object? dob = freezed,
    Object? city = freezed,
    Object? country = freezed,
    Object? pincode = freezed,
    Object? address = freezed,
    Object? weight = null,
    Object? height = null,
    Object? palmLength = freezed,
    Object? palmWidth = freezed,
    Object? knucklesLength = freezed,
    Object? dominantHand = freezed,
    Object? gender = freezed,
    Object? access_code = freezed,
    Object? device = freezed,
    Object? assessment = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as dynamic,
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      pincode: freezed == pincode
          ? _value.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as dynamic,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      palmLength: freezed == palmLength
          ? _value.palmLength
          : palmLength // ignore: cast_nullable_to_non_nullable
              as dynamic,
      palmWidth: freezed == palmWidth
          ? _value.palmWidth
          : palmWidth // ignore: cast_nullable_to_non_nullable
              as dynamic,
      knucklesLength: freezed == knucklesLength
          ? _value.knucklesLength
          : knucklesLength // ignore: cast_nullable_to_non_nullable
              as dynamic,
      dominantHand: freezed == dominantHand
          ? _value.dominantHand
          : dominantHand // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      access_code: freezed == access_code
          ? _value.access_code
          : access_code // ignore: cast_nullable_to_non_nullable
              as String?,
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as List<Device>?,
      assessment: freezed == assessment
          ? _value.assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as List<Assessment>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
          _$ProfileImpl value, $Res Function(_$ProfileImpl) then) =
      __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? name,
      dynamic phone,
      String countryCode,
      String? email,
      String? dob,
      String? city,
      String? country,
      dynamic pincode,
      String? address,
      int weight,
      int height,
      @JsonKey(name: "palm_length") dynamic palmLength,
      @JsonKey(name: "palm_width") dynamic palmWidth,
      @JsonKey(name: "knuckles_length") dynamic knucklesLength,
      @JsonKey(name: "dominant_hand") String? dominantHand,
      String? gender,
      @JsonKey(name: "accessCode") String? access_code,
      List<Device>? device,
      List<Assessment>? assessment});
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
      _$ProfileImpl _value, $Res Function(_$ProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? phone = freezed,
    Object? countryCode = null,
    Object? email = freezed,
    Object? dob = freezed,
    Object? city = freezed,
    Object? country = freezed,
    Object? pincode = freezed,
    Object? address = freezed,
    Object? weight = null,
    Object? height = null,
    Object? palmLength = freezed,
    Object? palmWidth = freezed,
    Object? knucklesLength = freezed,
    Object? dominantHand = freezed,
    Object? gender = freezed,
    Object? access_code = freezed,
    Object? device = freezed,
    Object? assessment = freezed,
  }) {
    return _then(_$ProfileImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone ? _value.phone! : phone,
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      pincode: freezed == pincode ? _value.pincode! : pincode,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      palmLength: freezed == palmLength
          ? _value.palmLength
          : palmLength // ignore: cast_nullable_to_non_nullable
              as dynamic,
      palmWidth: freezed == palmWidth
          ? _value.palmWidth
          : palmWidth // ignore: cast_nullable_to_non_nullable
              as dynamic,
      knucklesLength: freezed == knucklesLength
          ? _value.knucklesLength
          : knucklesLength // ignore: cast_nullable_to_non_nullable
              as dynamic,
      dominantHand: freezed == dominantHand
          ? _value.dominantHand
          : dominantHand // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      access_code: freezed == access_code
          ? _value.access_code
          : access_code // ignore: cast_nullable_to_non_nullable
              as String?,
      device: freezed == device
          ? _value._device
          : device // ignore: cast_nullable_to_non_nullable
              as List<Device>?,
      assessment: freezed == assessment
          ? _value._assessment
          : assessment // ignore: cast_nullable_to_non_nullable
              as List<Assessment>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl extends _Profile {
  const _$ProfileImpl(
      {this.id,
      this.name,
      this.phone,
      required this.countryCode,
      this.email,
      this.dob,
      this.city,
      this.country,
      this.pincode,
      this.address,
      required this.weight,
      required this.height,
      @JsonKey(name: "palm_length") this.palmLength,
      @JsonKey(name: "palm_width") this.palmWidth,
      @JsonKey(name: "knuckles_length") this.knucklesLength,
      @JsonKey(name: "dominant_hand") this.dominantHand,
      this.gender,
      @JsonKey(name: "accessCode") this.access_code,
      final List<Device>? device,
      final List<Assessment>? assessment})
      : _device = device,
        _assessment = assessment,
        super._();

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final dynamic phone;
  @override
  final String countryCode;
  @override
  final String? email;
  @override
  final String? dob;
  @override
  final String? city;
  @override
  final String? country;
  @override
  final dynamic pincode;
  @override
  final String? address;
  @override
  final int weight;
  @override
  final int height;
  @override
  @JsonKey(name: "palm_length")
  final dynamic palmLength;
  @override
  @JsonKey(name: "palm_width")
  final dynamic palmWidth;
  @override
  @JsonKey(name: "knuckles_length")
  final dynamic knucklesLength;
  @override
  @JsonKey(name: "dominant_hand")
  final String? dominantHand;
  @override
  final String? gender;
  @override
  @JsonKey(name: "accessCode")
  final String? access_code;
  final List<Device>? _device;
  @override
  List<Device>? get device {
    final value = _device;
    if (value == null) return null;
    if (_device is EqualUnmodifiableListView) return _device;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Assessment>? _assessment;
  @override
  List<Assessment>? get assessment {
    final value = _assessment;
    if (value == null) return null;
    if (_assessment is EqualUnmodifiableListView) return _assessment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, phone: $phone, countryCode: $countryCode, email: $email, dob: $dob, city: $city, country: $country, pincode: $pincode, address: $address, weight: $weight, height: $height, palmLength: $palmLength, palmWidth: $palmWidth, knucklesLength: $knucklesLength, dominantHand: $dominantHand, gender: $gender, access_code: $access_code, device: $device, assessment: $assessment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other.phone, phone) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.country, country) || other.country == country) &&
            const DeepCollectionEquality().equals(other.pincode, pincode) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.height, height) || other.height == height) &&
            const DeepCollectionEquality()
                .equals(other.palmLength, palmLength) &&
            const DeepCollectionEquality().equals(other.palmWidth, palmWidth) &&
            const DeepCollectionEquality()
                .equals(other.knucklesLength, knucklesLength) &&
            (identical(other.dominantHand, dominantHand) ||
                other.dominantHand == dominantHand) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.access_code, access_code) ||
                other.access_code == access_code) &&
            const DeepCollectionEquality().equals(other._device, _device) &&
            const DeepCollectionEquality()
                .equals(other._assessment, _assessment));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        const DeepCollectionEquality().hash(phone),
        countryCode,
        email,
        dob,
        city,
        country,
        const DeepCollectionEquality().hash(pincode),
        address,
        weight,
        height,
        const DeepCollectionEquality().hash(palmLength),
        const DeepCollectionEquality().hash(palmWidth),
        const DeepCollectionEquality().hash(knucklesLength),
        dominantHand,
        gender,
        access_code,
        const DeepCollectionEquality().hash(_device),
        const DeepCollectionEquality().hash(_assessment)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(
      this,
    );
  }
}

abstract class _Profile extends Profile {
  const factory _Profile(
      {final int? id,
      final String? name,
      final dynamic phone,
      required final String countryCode,
      final String? email,
      final String? dob,
      final String? city,
      final String? country,
      final dynamic pincode,
      final String? address,
      required final int weight,
      required final int height,
      @JsonKey(name: "palm_length") final dynamic palmLength,
      @JsonKey(name: "palm_width") final dynamic palmWidth,
      @JsonKey(name: "knuckles_length") final dynamic knucklesLength,
      @JsonKey(name: "dominant_hand") final String? dominantHand,
      final String? gender,
      @JsonKey(name: "accessCode") final String? access_code,
      final List<Device>? device,
      final List<Assessment>? assessment}) = _$ProfileImpl;
  const _Profile._() : super._();

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  dynamic get phone;
  @override
  String get countryCode;
  @override
  String? get email;
  @override
  String? get dob;
  @override
  String? get city;
  @override
  String? get country;
  @override
  dynamic get pincode;
  @override
  String? get address;
  @override
  int get weight;
  @override
  int get height;
  @override
  @JsonKey(name: "palm_length")
  dynamic get palmLength;
  @override
  @JsonKey(name: "palm_width")
  dynamic get palmWidth;
  @override
  @JsonKey(name: "knuckles_length")
  dynamic get knucklesLength;
  @override
  @JsonKey(name: "dominant_hand")
  String? get dominantHand;
  @override
  String? get gender;
  @override
  @JsonKey(name: "accessCode")
  String? get access_code;
  @override
  List<Device>? get device;
  @override
  List<Assessment>? get assessment;
  @override
  @JsonKey(ignore: true)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
