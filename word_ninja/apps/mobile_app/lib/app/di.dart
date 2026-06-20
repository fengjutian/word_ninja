import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:core/lib/network/dio_client.dart';
import 'package:core/lib/network/api_client.dart';
import 'package:core/lib/constants/app_constants.dart';
import 'package:auth/lib/data/datasource/auth_remote_datasource.dart';
import 'package:auth/lib/data/repository/auth_repository_impl.dart';
import 'package:auth/lib/domain/repository/auth_repository.dart';
import 'package:vocabulary/lib/data/datasource/vocabulary_local_datasource.dart';
import 'package:vocabulary/lib/data/repository/vocabulary_repository_impl.dart';
import 'package:vocabulary/lib/domain/repository/vocabulary_repository.dart';
import 'package:sync/lib/sync_service.dart';
import 'package:ai/lib/services/ai_chat_service.dart';

/// ═══════════════════════════════════════
///  Word Ninja 依赖注入（DI）模块
///  所有 Provider 在此统一绑定
/// ═══════════════════════════════════════

// ─── 网络层 ───

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(baseUrl: AppConstants.apiBaseUrl);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioClientProvider));
});

// ─── Auth ───

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});

// ─── Sync ───

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

// ─── AI ───

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  // 生产环境从 SecureStorage 读取
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  return AiChatService(apiKey);
});
