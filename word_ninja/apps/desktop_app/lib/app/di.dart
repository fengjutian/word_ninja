import 'package:flutter_riverpod/flutter_riverpod.dart';  
import 'package:vocabulary/data/datasource/in_memory_local_datasource.dart';  
import 'package:vocabulary/data/datasource/vocabulary_local_datasource.dart';  
import 'package:vocabulary/data/datasource/vocabulary_remote_datasource.dart';  
import 'package:vocabulary/data/model/word.dart';  
import 'package:vocabulary/data/repository/vocabulary_repository_impl.dart';  
import 'package:vocabulary/domain/repository/vocabulary_repository.dart';  
import 'package:vocabulary/presentation/providers/word_provider.dart'; 
  
/// Word Ninja Desktop dependency injection  
/// Returns ProviderScope overrides list  
final desktopOverrides = <Override>[  
  vocabularyRepositoryProvider.overrideWithProvider(  
    Provider<VocabularyRepository>((ref) {  
      return VocabularyRepositoryImpl(  
        InMemoryVocabularyLocalDataSource(),  
        _StubRemoteDataSource(),  
      );  
    }),  
  ),  
]; 
  
/// Remote data source stub (desktop uses in-memory only)  
class _StubRemoteDataSource implements VocabularyRemoteDataSource {  
  @override  
  Future<List<Word>> fetchWords({int page = 1, int size = 20}) async => []; 
  
  @override  
  Future<Word> createWord(Map<String, dynamic> data) async =>  
      Word(id: 'stub', userId: '', word: data['word'] ?? '', meaning: data['meaning'] ?? ''); 
  
  @override  
  Future<Word> updateWord(String id, Map<String, dynamic> data) async =>  
      Word(id: id, userId: '', word: data['word'] ?? '', meaning: data['meaning'] ?? '');  
  
  @override  
  Future<void> deleteWord(String id) async { }  
  
  @override  
  Future<List<Word>> syncWords(List<Word> localWords) async => [];  
} 
