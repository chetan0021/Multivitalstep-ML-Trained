import 'package:freezed_annotation/freezed_annotation.dart';

part 'Patient.g.dart';
part 'Patient.freezed.dart';

@freezed
class Patient with _$Patient {
  const Patient._();
  const factory Patient({required String name}) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}
