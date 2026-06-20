import 'package:path_provider/path_provider.dart';
import 'package:core/lib/constants/app_constants.dart';
import 'isar/isar_service.dart';

/// Isar 本地数据库管理器
class IsarDb {
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await IsarService.open(dir.path);
  }

  static Future<void> close() async {
    await IsarService.close();
  }
}
