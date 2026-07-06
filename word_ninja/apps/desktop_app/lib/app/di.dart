import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabulary/data/datasource/isar_local_datasource.dart';
import 'package:vocabulary/data/datasource/vocabulary_local_datasource.dart';
import 'package:vocabulary/data/datasource/vocabulary_remote_datasource.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/data/repository/vocabulary_repository_impl.dart';
import 'package:vocabulary/domain/repository/vocabulary_repository.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
import 'package:auth/presentation/providers/auth_provider.dart';
import 'package:auth/domain/repository/auth_repository.dart';
import 'package:auth/domain/entities/user.dart';

/// Word Ninja Desktop dependency injection
/// Returns ProviderScope overrides list
final desktopOverrides = <Override>[
  authRepositoryProvider.overrideWithProvider(
    Provider<AuthRepository>((ref) => _StubAuthRepository()),
  ),
  vocabularyRepositoryProvider.overrideWithProvider(
    Provider<VocabularyRepository>((ref) {
      return VocabularyRepositoryImpl(
        IsarVocabularyLocalDataSource(),
        _StubRemoteDataSource(),
      );
    }),
  ),
];

/// Stub auth repository (desktop has no login — offline mode)
class _StubAuthRepository implements AuthRepository {
  User? _user;

  @override
  User? get currentUser => _user;

  @override
  Future<User> login(String email, String password) async {
    _user = User(id: 'desktop', email: email, nickname: 'Ninja');
    return _user!;
  }

  @override
  Future<User> register(String email, String password, String nickname) async {
    _user = User(id: 'desktop', email: email, nickname: nickname);
    return _user!;
  }

  @override
  Future<void> logout() async {
    _user = null;
  }

  @override
  Future<bool> isLoggedIn() async => _user != null;

  @override
  Future<void> forgotPassword(String email) async {}
}

/// Remote data source stub (desktop uses local-only)
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
  Future<void> deleteWord(String id) async {}

  @override
  Future<List<Word>> syncWords(List<Word> localWords) async => [];
}
