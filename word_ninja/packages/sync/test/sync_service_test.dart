import 'package:flutter_test/flutter_test.dart';
import 'package:sync/sync_service.dart';

void main() {
  test('reports failure when no sync task is configured', () async {
    final result = await SyncService().sync();
    expect(result.success, isFalse);
    expect(result.message, contains('没有可执行'));
  });

  test('reports failure when any module fails', () async {
    final service = SyncService();
    final result = await service.sync(
      syncWords: () async => throw StateError('offline'),
      syncRecords: () async {},
    );
    expect(result.success, isFalse);
    expect(result.message, contains('单词本 ❌'));
    expect(service.lastSyncAt, isNull);
  });

  test('records successful synchronization time', () async {
    final service = SyncService();
    final result = await service.sync(syncWords: () async {});
    expect(result.success, isTrue);
    expect(service.lastSyncAt, isNotNull);
  });
}
