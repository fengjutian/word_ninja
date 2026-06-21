import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/network/dio_client.dart';
import 'package:core/network/api_client.dart';
import 'package:core/constants/app_constants.dart';
import 'package:auth/data/datasource/auth_remote_datasource.dart';
import 'package:auth/data/repository/auth_repository_impl.dart';
import 'package:auth/domain/repository/auth_repository.dart';
import 'package:auth/presentation/providers/auth_provider.dart';
import 'package:vocabulary/data/datasource/in_memory_local_datasource.dart';
import 'package:vocabulary/data/datasource/api_vocabulary_remote_datasource.dart';
import 'package:vocabulary/data/datasource/vocabulary_local_datasource.dart';
import 'package:vocabulary/data/datasource/vocabulary_remote_datasource.dart';
import 'package:vocabulary/data/repository/vocabulary_repository_impl.dart';
import 'package:vocabulary/domain/repository/vocabulary_repository.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
import 'package:sync/sync_service.dart';
import 'package:ai/services/ai_chat_service.dart';

/// ═══════════════════════════════════════
///  Word Ninja 依赖注入（DI）模块
///  所有 Provider 在此统一绑定并作为 overrides 导出
/// ═══════════════════════════════════════

// ─── 网络层 ───

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(baseUrl: AppConstants.apiBaseUrl);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioClientProvider));
});

// ─── Auth ───

final _authRemoteDSProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(apiClientProvider));
});

/// override authRepositoryProvider from auth package
final authRepositoryOverride = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(_authRemoteDSProvider));
});

// ─── Vocabulary ───

final _vocabLocalDSProvider = Provider<VocabularyLocalDataSource>((ref) {
  // 开发阶段使用内存数据源，后续可替换为 Isar 实现
  return InMemoryVocabularyLocalDataSource();
});

final _vocabRemoteDSProvider = Provider<VocabularyRemoteDataSource>((ref) {
  return ApiVocabularyRemoteDataSource(ref.read(apiClientProvider));
});

/// override vocabularyRepositoryProvider from vocabulary package
final vocabularyRepositoryOverride = Provider<VocabularyRepository>((ref) {
  return VocabularyRepositoryImpl(
    ref.read(_vocabLocalDSProvider),
    ref.read(_vocabRemoteDSProvider),
  );
});

// ─── Sync ───

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

// ─── AI ───

final aiChatServiceOverride = Provider<AiChatService>((ref) {
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  return AiChatService(apiKey);
});

/// 所有需要覆盖的 Provider 列表，在 main.dart 的 ProviderScope 中传入
final diOverrides = <Override>[
  authRepositoryProvider.overrideWith(
    (ref) => ref.read(authRepositoryOverride),
  ),
  vocabularyRepositoryProvider.overrideWith(
    (ref) => ref.read(vocabularyRepositoryOverride),
  ),
  // aiChatServiceProvider 已在 ai 包中定义，这里覆盖为我们自己的实现
];
