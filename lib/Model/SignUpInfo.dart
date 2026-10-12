import 'package:freezed_annotation/freezed_annotation.dart';

part 'SignUpInfo.freezed.dart';
part 'SignUpInfo.g.dart';

@freezed
class SignUpInfo with _$SignUpInfo {
  const SignUpInfo._();
  const factory SignUpInfo({
    required String name,
    required int phone,
    required String countryCode,
    required String email,
    required String password,
    required String dob,
    String? city,
    String? country,
    int? pincode,
    String? address,
    required int weight,
    required int height,
    @JsonKey(name: "palm_length") double? palmLength,
    @JsonKey(name: "palm_width") double? palmWidth,
    @JsonKey(name: "knuckles_length") double? knuckleLength,
    @JsonKey(name: "dominant_hand") required String dominantHand,
    required String gender,
  }) = _SignUpInfo;

  factory SignUpInfo.fromJson(Map<String, dynamic> json) =>
      _$SignUpInfoFromJson(json);
}
