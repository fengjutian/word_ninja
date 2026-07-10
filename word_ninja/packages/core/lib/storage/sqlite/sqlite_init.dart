import 'chat_database.dart';
import 'sqlite_chat_repository.dart';
import 'chat_repository.dart';

/// SQLite 聊天数据库管理器
class SqliteDb {
  static SqliteChatRepository? _repository;

  static ChatRepository get repository {
    if (_repository == null) {
      throw StateError('SqliteDb not initialized. Call SqliteDb.init() first.');
    }
    return _repository!;
  }

  static Future<void> init() async {
    await ChatDatabase.open();
    _repository = SqliteChatRepository();
  }

  static Future<void> close() async {
    await ChatDatabase.close();
    _repository = null;
  }
}
