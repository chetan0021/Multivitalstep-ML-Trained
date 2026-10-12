import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vital_step/Model/test.dart';

part 'patient_reading.freezed.dart';
part 'patient_reading.g.dart';

@unfreezed
class PatientReading with _$PatientReading {
  const PatientReading._();

  factory PatientReading({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    required double trial1,
    required double trial2,
    required double trial3,
    required String hand,
    required String posture,
    @JsonKey(name: 'assessment_type') required String assessmentType,
    @JsonKey(name: 'host_user_id') required String hostUserId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PatientReading;

  factory PatientReading.fromJson(Map<String, dynamic> json) =>
      _$PatientReadingFromJson(json);

  double get average => (trial1 + trial2 + trial3) / 3;

  Test toTest() => Test(
        id: 0,
        userId: 0,
        deviceId: 0,
        assestmentId: 0,
        posture: posture,
        trial1: trial1.toString(),
        trial2: trial2.toString(),
        trial3: trial3.toString(),
        hand: hand,
        createdAt: createdAt,
      );
}
