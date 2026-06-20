import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:core/lib/constants/app_constants.dart';

/// Isar 本地数据库管理器
class IsarDb {
  static Isar? _instance;

  static Isar get instance {
    if (_instance == null) {
      throw StateError('IsarDb is not initialized. Call IsarDb.init() first.');
    }
    return _instance!;
  }

  static Future<void> init() async {
    if (_instance != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [], // TODO 注册所有 schema: [UserSchema, WordSchema, ReviewSchema, ...]
      directory: dir.path,
      name: AppConstants.isarDbName,
    );
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
