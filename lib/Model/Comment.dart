import 'package:freezed_annotation/freezed_annotation.dart';

part 'Comment.g.dart';
part 'Comment.freezed.dart';

@freezed
class Comment with _$Comment {
  Comment._();
  factory Comment({
    required int id,
    required int assessmentId,
    required int AssignerId,
    required String remarks,
    required DateTime createdAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}
