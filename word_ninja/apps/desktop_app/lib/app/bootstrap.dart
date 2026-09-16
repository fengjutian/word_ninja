import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:core/storage/preferences.dart';
import 'package:core/storage/isar_db.dart';
import 'package:core/storage/sqlite/sqlite_init.dart';
import 'package:core/logger/logger.dart';
import 'package:vocabulary/data/datasource/isar_local_datasource.dart';
import 'package:vocabulary/data/datasource/sqlite_local_datasource.dart';

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
      await _migrateVocabulary();
    } catch (e) {
      log.w('SQLite init skipped: $e');
    }

    // 4. Other initialization
    log.i('WordFlow Desktop bootstrapped');
  }

  static Future<void> _migrateVocabulary() async {
    const key = 'vocabulary_sqlite_migration_v1';
    if (Preferences.getBool(key)) return;
    try {
      await SqliteVocabularyLocalDataSource()
          .importLegacy(IsarVocabularyLocalDataSource());
      await Preferences.setBool(key, true);
      log.i('Vocabulary migrated to SQLite');
    } catch (e) {
      // Do not set the flag: the idempotent migration retries next launch.
      log.w('Vocabulary migration deferred: $e');
    }
  }
}
