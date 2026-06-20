import 'package:isar/isar.dart';

part 'achievement_schema.g.dart';

@collection
class AchievementSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String achievementId;

  late String userId;
  late String type;    // word_count, reading_count, streak, etc.
  late String title;
  String? description;
  late int progress;
  late int target;
  late bool isUnlocked;
  DateTime? unlockedAt;
  DateTime? createdAt;
}
