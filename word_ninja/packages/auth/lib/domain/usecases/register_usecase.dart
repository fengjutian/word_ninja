import '../entities/user.dart';
import '../repository/auth_repository.dart';

/// 注册用例
class RegisterUseCase {
  final AuthRepository _repo;

  RegisterUseCase(this._repo);

  Future<User> call(String email, String password, String nickname) =>
      _repo.register(email, password, nickname);
}
