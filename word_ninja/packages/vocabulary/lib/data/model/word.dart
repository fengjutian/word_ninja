import 'package:freezed_annotation/freezed_annotation.dart';
part 'word.freezed.dart';
part 'word.g.dart';

/// 单词数据模型（freezed）
@freezed
class Word with _$Word {
  const factory Word({
    required String id,
    required String userId,
    required String word,
    required String meaning,
    @Default('') String phonetic,
    @Default('') String example,
    @Default(1) int difficulty,
    @Default(0) int mastery,
    @Default('manual') String source,
    @Default([]) List<String> tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
