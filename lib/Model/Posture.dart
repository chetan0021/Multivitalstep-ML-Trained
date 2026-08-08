import 'package:freezed_annotation/freezed_annotation.dart';
part 'Posture.g.dart';
part 'Posture.freezed.dart';

@freezed
class Posture with _$Posture {
  const Posture._();
  const factory Posture({
    String? fullBodyWeight,
    String? fullArmWeight,
    String? forwardLoading,
    String? backwardOffLoading,
    String? sideLoading,
    String? sideOffLoading,
  }) = _Posture;

  factory Posture.fromJson(Map<String, dynamic> json) =>
      _$PostureFromJson(json);
}
