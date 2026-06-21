import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// Auth 状态
enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

/// Auth 状态模型
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.uninitialized,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

/// Auth Riverpod Provider
/// 需要外部注入 AuthRepository，参见 mobile_app/lib/app/di.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('authRepositoryProvider must be overridden in app DI');
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  late final LoginUseCase _login;
  late final RegisterUseCase _register;

  AuthNotifier(this._repo)
      : super(const AuthState()) {
    _login = LoginUseCase(_repo);
    _register = RegisterUseCase(_repo);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await _repo.isLoggedIn();
    if (loggedIn) {
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: '登录失败：${e.toString()}',
      );
    }
  }

  Future<void> register(
      String email, String password, String nickname) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _register(email, password, nickname);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: '注册失败：${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> forgotPassword(String email) async {
    await _repo.forgotPassword(email);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
