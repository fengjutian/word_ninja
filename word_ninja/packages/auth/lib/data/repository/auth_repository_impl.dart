import 'package:core/logger/logger.dart';
import 'package:core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

/// 认证仓库实现
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  User? _currentUser;

  AuthRepositoryImpl(this._remote);

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User> login(String email, String password) async {
    final data = await _remote.login(email, password);
    _currentUser = User(
      id: data['user']['id'],
      email: data['user']['email'],
      nickname: data['user']['nickname'],
      avatar: data['user']['avatar'],
      level: data['user']['level'] ?? 1,
      exp: data['user']['exp'] ?? 0,
    );
    await SecureStorage.write('access_token', data['access_token']);
    await SecureStorage.write('refresh_token', data['refresh_token']);
    await SecureStorage.write('user_id', data['user']['id']);
    log.i('User logged in: ${_currentUser!.email}');
    return _currentUser!;
  }

  @override
  Future<User> register(
      String email, String password, String nickname) async {
    final data = await _remote.register(email, password, nickname);
    _currentUser = User(
      id: data['user']['id'],
      email: data['user']['email'],
      nickname: data['user']['nickname'],
      avatar: data['user']['avatar'],
      level: 1,
      exp: 0,
    );
    await SecureStorage.write('access_token', data['access_token']);
    await SecureStorage.write('user_id', data['user']['id']);
    log.i('User registered: ${_currentUser!.email}');
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await SecureStorage.delete('access_token');
    await SecureStorage.delete('refresh_token');
    await SecureStorage.delete('user_id');
    log.i('User logged out');
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.read('access_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remote.forgotPassword(email);
    log.i('Password reset requested for: $email');
  }
}
