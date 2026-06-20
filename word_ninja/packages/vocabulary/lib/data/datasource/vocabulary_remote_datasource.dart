import '../model/word.dart';

/// 单词远程数据源
abstract class VocabularyRemoteDataSource {
  Future<List<Word>> fetchWords({int page = 1, int size = 20});
  Future<Word> createWord(Map<String, dynamic> data);
  Future<Word> updateWord(String id, Map<String, dynamic> data);
  Future<void> deleteWord(String id);
  Future<List<Word>> syncWords(List<Word> localWords);
}
