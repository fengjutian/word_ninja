import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// 登录用例
class LoginUseCase {
  final AuthRepository _repo;

  LoginUseCase(this._repo);

  Future<User> call(String email, String password) =>
      _repo.login(email, password);
}
