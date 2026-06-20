import 'package:freezed_annotation/freezed_annotation.dart';
part 'review.freezed.dart';
part 'review.g.dart';

/// 复习记录模型（艾宾浩斯）
@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    required String wordId,
    required DateTime reviewTime,
    @Default(0) int score,
    @Default(false) bool isCompleted,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}
