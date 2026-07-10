import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/storage/preferences.dart';
import 'package:core/storage/isar_db.dart';
import 'package:core/storage/sqlite/sqlite_init.dart';
import 'package:core/logger/logger.dart';

/// App 初始化引导
class AppBootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. 初始化偏好设置
    await Preferences.init();

    // 2. 初始化本地数据库
    try {
      await IsarDb.init();
      log.i('Isar database initialized');
    } catch (e) {
      log.w('Isar init skipped: $e');
    }

    // 3. 初始化 SQLite 聊天数据库
    try {
      await SqliteDb.init();
      log.i('SQLite chat database initialized');
    } catch (e) {
      log.w('SQLite init skipped: $e');
    }

    // 4. 其他初始化
    log.i('Word Ninja bootstrapped');
  }
}
