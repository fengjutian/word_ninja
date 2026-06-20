import 'package:isar/isar.dart';

part 'user_schema.g.dart';

@collection
class UserSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late String email;
  late String nickname;
  String? avatar;
  late int level;
  late int exp;
  DateTime? lastLoginAt;
  DateTime? createdAt;
  DateTime? updatedAt;
}
