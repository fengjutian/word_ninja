import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:core/storage/preferences.dart';
import 'package:core/storage/isar_db.dart';
import 'package:core/storage/sqlite/sqlite_init.dart';
import 'package:core/logger/logger.dart';

/// App initialization bootstrap
class AppBootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 0. Initialize FFI for SQLite on desktop (Windows/Linux)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // 1. Initialize preferences
    await Preferences.init();

    // 2. Initialize local database
    try {
      await IsarDb.init();
      log.i('Isar database initialized');
    } catch (e) {
      log.w('Isar init skipped: $e');
    }

    // 3. Initialize SQLite chat database
    try {
      await SqliteDb.init();
      log.i('SQLite chat database initialized');
    } catch (e) {
      log.w('SQLite init skipped: $e');
    }

    // 4. Other initialization
    log.i('Word Ninja Desktop bootstrapped');
  }
}
