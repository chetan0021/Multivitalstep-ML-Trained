import 'package:freezed_annotation/freezed_annotation.dart';
part 'Assessment.g.dart';
part 'Assessment.freezed.dart';

@unfreezed
class Assessment with _$Assessment {
  Assessment._();
  factory Assessment({
    required int id,
    required int userId,
    required String type,
    required String posture,
    required String status,
    bool? currentlyActive,
    int? queueId,
    required DateTime createdAt,
  }) = _Assesment;
  factory Assessment.fromJson(Map<String, dynamic> json) =>
      _$AssessmentFromJson(json);
}
