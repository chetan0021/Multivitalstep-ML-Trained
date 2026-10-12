import 'package:freezed_annotation/freezed_annotation.dart';

part 'Role.g.dart';
part 'Role.freezed.dart';

@freezed
class Role with _$Role {
  const Role._();
  const factory Role(
      {String? doctor,
      String? operator,
      String? patient,
      String? admin}) = _Role;
  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
}
