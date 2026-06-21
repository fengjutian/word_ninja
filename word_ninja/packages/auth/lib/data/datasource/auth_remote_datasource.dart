import 'package:core/network/api_client.dart';

/// 认证远程数据源
class AuthRemoteDataSource {
  final ApiClient _api;

  AuthRemoteDataSource(this._api);

  Future<Map<String, dynamic>> login(String email, String password) =>
      _api.login(email, password);

  Future<Map<String, dynamic>> register(
          String email, String password, String nickname) =>
      _api.register(email, password, nickname);

  Future<void> forgotPassword(String email) =>
      _api.forgotPassword(email);
}
