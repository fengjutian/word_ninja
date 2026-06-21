import 'package:core/network/api_client.dart';
import '../model/word.dart';
import 'vocabulary_remote_datasource.dart';

/// 基于 API 的远程数据源实现
class ApiVocabularyRemoteDataSource implements VocabularyRemoteDataSource {
  final ApiClient _api;

  ApiVocabularyRemoteDataSource(this._api);

  @override
  Future<List<Word>> fetchWords({int page = 1, int size = 20}) async {
    final list = await _api.getWords(page: page, size: size);
    return list.map((json) => Word.fromJson(Map<String, dynamic>.from(json as Map))).toList();
  }

  @override
  Future<Word> createWord(Map<String, dynamic> data) async {
    final json = await _api.createWord(data);
    return Word.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<Word> updateWord(String id, Map<String, dynamic> data) async {
    // ApiClient 当前无 updateWord 方法，使用 createWord 的 PUT 语义
    final json = await _api.createWord({...data, 'id': id});
    return Word.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> deleteWord(String id) async {
    // ApiClient 当前无 deleteWord 方法，占位
  }

  @override
  Future<List<Word>> syncWords(List<Word> localWords) async {
    final payload = <String, dynamic>{
      'words': localWords.map((w) => w.toJson()).toList(),
    };
    await _api.sync(payload);
    return []; // 同步方向: 客户端→服务端
  }
}
