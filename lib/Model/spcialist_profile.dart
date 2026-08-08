import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vital_step/Model/accounts.dart';

part 'spcialist_profile.g.dart';
part 'spcialist_profile.freezed.dart';

@freezed
class ProfileSpecialist with _$ProfileSpecialist {
  const ProfileSpecialist._();
  const factory ProfileSpecialist({
    int? id,
    required String name,
    required String countryCode,
    required String email,
    required String dob,
    phone,
    String? password,
    String? city,
    String? country,
    pincode,
    address,
    DateTime? createdAt,
    List<Accounts>? accounts,
  }) = _ProfileSpecialist;

  factory ProfileSpecialist.fromJson(Map<String, dynamic> json) =>
      _$ProfileSpecialistFromJson(json);
}
