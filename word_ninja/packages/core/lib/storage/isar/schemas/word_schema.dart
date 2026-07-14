import 'package:isar/isar.dart';

part 'word_schema.g.dart';

@collection
class WordSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String wordId;

  late String userId;
  late String word;
  late String meaning;
  String? phonetic;
  String? example;
  late int difficulty;
  late int mastery;
  late String source; // manual, reading, ai, ocr, pdf
  List<String> tags = [];
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? nextReviewDate;
  int reviewCount = 0;
  /// AI 标记的重点分数（0-100），用于强化学习优先调度，默认 0 表示普通词
  int focusScore = 0;
}
