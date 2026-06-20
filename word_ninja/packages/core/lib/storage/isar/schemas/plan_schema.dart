import 'package:isar/isar.dart';

part 'plan_schema.g.dart';

@collection
class PlanSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String planId;

  late String userId;
  late String goal;
  late int dayCount;
  late int currentDay;
  late bool isActive;
  List<String> tasks = [];  // JSON 序列化的任务数组
  DateTime? createdAt;
  DateTime? updatedAt;
}
