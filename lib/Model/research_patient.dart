import 'package:freezed_annotation/freezed_annotation.dart';

part 'research_patient.g.dart';
part 'research_patient.freezed.dart';

@freezed
class ResearchPatient with _$ResearchPatient {
  const ResearchPatient._();
  const factory ResearchPatient({
    required String id,
    @JsonKey(name: 'patient_code') required String patientCode,
    required String name,
    required int age,
    required String gender,
    @Default('')
    String contact, // legacy — kept for backward compat with old rows
    @Default('') String phone,
    @Default('') String email,
    @Default('None') String condition,
    @Default('') String notes,
    @JsonKey(name: 'host_user_id') required String hostUserId,
    @JsonKey(name: 'created_at') required DateTime createdAt,

    // Clinical fields (optional — filled during patient registration)
    @JsonKey(name: 'dob') String? dob,
    @JsonKey(name: 'dominant_hand') String? dominantHand,
    @JsonKey(name: 'height') int? height,
    @JsonKey(name: 'weight') int? weight,
    @JsonKey(name: 'palm_length') double? palmLength,
    @JsonKey(name: 'palm_width') double? palmWidth,
    @JsonKey(name: 'knuckle_length') double? knuckleLength,
  }) = _ResearchPatient;

  factory ResearchPatient.fromJson(Map<String, dynamic> json) =>
      _$ResearchPatientFromJson(json);
}
