import 'package:freezed_annotation/freezed_annotation.dart';

part 'test.g.dart';
part 'test.freezed.dart';

@freezed
class Test with _$Test {
  const Test._();
  const factory Test({
    required int id,
    required int userId,
    required int deviceId,
    required int assestmentId,
    required String posture,
    required String trial1,
    required String trial2,
    required String trial3,
    required String hand,
    required DateTime createdAt,
  }) = _Test;

  factory Test.fromJson(Map<String, dynamic> json) => _$TestFromJson(json);
}
