import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/logger/logger.dart';

/// 云同步服务
class SyncService {
  bool _isSyncing = false;
  DateTime? _lastSyncAt;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;

  /// 执行数据同步
  Future<SyncResult> sync() async {
    if (_isSyncing) return SyncResult(false, '正在同步中...');

    _isSyncing = true;
    try {
      log.i('Sync started');

      // TODO 实现各模块的同步逻辑
      await Future.delayed(const Duration(seconds: 2));

      _lastSyncAt = DateTime.now();
      _isSyncing = false;
      log.i('Sync completed');
      return SyncResult(true, '同步成功');
    } catch (e) {
      _isSyncing = false;
      log.e('Sync failed', e);
      return SyncResult(false, '同步失败：$e');
    }
  }

  /// 强制全量同步
  Future<SyncResult> forceSync() async {
    // TODO 全量覆盖同步
    return sync();
  }
}

class SyncResult {
  final bool success;
  final String message;

  const SyncResult(this.success, this.message);
}

/// Sync Provider
final syncProvider = Provider<SyncService>((ref) => SyncService());
