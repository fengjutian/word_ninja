import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/storage/secure_storage.dart';
import 'package:core/storage/isar_db.dart';
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

    // 3. 其他初始化
    log.i('Word Ninja bootstrapped');
  }
}
