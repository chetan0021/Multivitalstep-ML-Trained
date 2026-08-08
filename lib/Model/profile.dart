import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/Model/Device.dart';

part 'profile.g.dart';
part 'profile.freezed.dart';

@freezed
class Profile with _$Profile {
  const Profile._();
  const factory Profile({
    int? id,
    String? name,
    phone,
    required String countryCode,
    String? email,
    String? dob,
    String? city,
    String? country,
    pincode,
    String? address,
    required int weight,
    required int height,
    @JsonKey(name: "palm_length") dynamic palmLength,
    @JsonKey(name: "palm_width") dynamic palmWidth,
    @JsonKey(name: "knuckles_length") dynamic knucklesLength,
    @JsonKey(name: "dominant_hand") String? dominantHand,
    String? gender,
    @JsonKey(name: "accessCode") String? access_code,
    List<Device>? device,
    List<Assessment>? assessment,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
// flutter pub run build_runner watch --delete-conflicting-outputs
