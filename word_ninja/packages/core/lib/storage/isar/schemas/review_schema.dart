import 'package:isar/isar.dart';

part 'review_schema.g.dart';

@collection
class ReviewSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String reviewId;

  late String wordId;
  late DateTime reviewTime;
  late int score;      // 1-5
  late bool isCompleted;
  DateTime? createdAt;
}
