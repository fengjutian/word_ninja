import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/logger/logger.dart';

/// 数据同步服务
class SyncService {
  bool _isSyncing = false;
  DateTime? _lastSyncAt;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;

  /// 执行数据同步
  Future<SyncResult> sync({
    Future<void> Function()? syncWords,
    Future<void> Function()? syncRecords,
    Future<void> Function()? syncPlans,
  }) async {
    if (_isSyncing) return SyncResult(false, '正在同步中...');

    _isSyncing = true;
    try {
      log.i('Sync: 开始同步...');
      final results = <String>[];

      // 逐模块同步
      if (syncWords != null) {
        try {
          await syncWords();
          results.add('单词本 ✅');
        } catch (e) {
          results.add('单词本 ❌');
          log.e('Sync words failed', e);
        }
      }

      if (syncRecords != null) {
        try {
          await syncRecords();
          results.add('学习记录 ✅');
        } catch (e) {
          results.add('学习记录 ❌');
          log.e('Sync records failed', e);
        }
      }

      if (syncPlans != null) {
        try {
          await syncPlans();
          results.add('学习计划 ✅');
        } catch (e) {
          results.add('学习计划 ❌');
          log.e('Sync plans failed', e);
        }
      }

      _lastSyncAt = DateTime.now();
      _isSyncing = false;
      final msg = results.isEmpty ? '同步成功' : results.join(', ');
      log.i('Sync: 完成 — $msg');
      return SyncResult(true, msg);
    } catch (e) {
      _isSyncing = false;
      log.e('Sync failed', e);
      return SyncResult(false, '同步失败：$e');
    }
  }

  /// 强制全量同步
  Future<SyncResult> forceSync({
    Future<void> Function()? syncWords,
    Future<void> Function()? syncRecords,
    Future<void> Function()? syncPlans,
  }) async {
    return sync(syncWords: syncWords, syncRecords: syncRecords, syncPlans: syncPlans);
  }
}

class SyncResult {
  final bool success;
  final String message;
  const SyncResult(this.success, this.message);
}

/// Sync Provider
final syncProvider = Provider<SyncService>((ref) => SyncService());
