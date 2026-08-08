import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vital_step/Model/profile.dart';
import 'package:vital_step/Model/spcialist_profile.dart';

part 'accounts.g.dart';
part 'accounts.freezed.dart';

@freezed
class Accounts with _$Accounts {
  const Accounts._();
  const factory Accounts(
      {required int id,
      required int userId,
      required int specialistId,
      required Profile user,
      ProfileSpecialist? specialist}) = _Accounts;

  factory Accounts.fromJson(Map<String, dynamic> json) =>
      _$AccountsFromJson(json);
}
