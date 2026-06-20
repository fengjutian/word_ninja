import 'package:isar/isar.dart';

/// Isar 数据库服务 — 负责打开和关闭数据库
class IsarService {
  static Isar? _isar;

  static Isar get instance {
    if (_isar == null) throw StateError('Isar not initialized');
    return _isar!;
  }

  static Future<Isar> open(String directory) async {
    _isar = await Isar.open(
      [
        UserSchemaSchema,
        WordSchemaSchema,
        ReviewSchemaSchema,
        AchievementSchemaSchema,
        PlanSchemaSchema,
      ],
      directory: directory,
      name: 'word_ninja',
    );
    return _isar!;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
