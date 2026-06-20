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
}
