import '../entities/user.dart';

/// 认证仓库接口（依赖倒置）
abstract class AuthRepository {
  User? get currentUser;
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String nickname);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<void> forgotPassword(String email);
}
