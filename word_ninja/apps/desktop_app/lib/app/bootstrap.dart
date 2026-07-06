import 'package:flutter/material.dart';
import 'package:core/storage/preferences.dart';
import 'package:core/storage/isar_db.dart';
import 'package:core/logger/logger.dart';

/// App initialization bootstrap
class AppBootstrap {
  static Future<void> init() async {
    // 1. Initialize preferences
    await Preferences.init();

    // 2. Initialize local database
    try {
      await IsarDb.init();
      log.i('Isar database initialized');
    } catch (e) {
      log.w('Isar init skipped: $e');
    }

    // 3. Other initialization
    log.i('Word Ninja Desktop bootstrapped');
  }
}
