import 'dio_client.dart';

/// API 客户端 — 封装业务接口调用
class ApiClient {
  final DioClient _client;

  ApiClient(this._client);

  // ─── Auth ───
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.post('/api/v1/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String nickname) async {
    final res = await _client.post('/api/v1/auth/register', data: {
      'email': email,
      'nickname': nickname,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<void> forgotPassword(String email) async {
    await _client.post('/api/v1/auth/forgot-password', data: {
      'email': email,
    });
  }

  // ─── Words ───
  Future<List<dynamic>> getWords({int page = 1, int size = 20}) async {
    final res = await _client.get('/api/v1/words',
        queryParameters: {'page': page, 'size': size});
    return res.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createWord(Map<String, dynamic> word) async {
    final res = await _client.post('/api/v1/words', data: word);
    return res.data as Map<String, dynamic>;
  }

  // ─── AI ───
  Future<Map<String, dynamic>> aiChat(String message) async {
    final res = await _client.post('/api/v1/ai/chat', data: {
      'message': message,
    });
    return res.data as Map<String, dynamic>;
  }

  // ─── Sync ───
  Future<Map<String, dynamic>> sync(Map<String, dynamic> payload) async {
    final res = await _client.post('/api/v1/sync', data: payload);
    return res.data as Map<String, dynamic>;
  }

  // ─── Leaderboard ───
  Future<List<dynamic>> getLeaderboard(String range) async {
    final res = await _client.get('/api/v1/leaderboard', queryParameters: {'range': range});
    return res.data['data'] as List<dynamic>;
  }
}
