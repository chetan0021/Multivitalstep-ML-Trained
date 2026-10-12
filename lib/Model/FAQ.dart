import 'package:freezed_annotation/freezed_annotation.dart';
part 'FAQ.freezed.dart';

@freezed
class FAQ with _$FAQ {
  const FAQ._();
  const factory FAQ({
    required String question,
    required String answer,
  }) = _FAQ;
}
