// data/providers/auth_provider.dart
// 📁 JAMOCHI_APP/lib/data/providers/auth_provider.dart
// 🛡️ FIX: Kết nối Socket.IO ngay sau khi login để nhận mood real-time

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../models/couple.dart';
import '../repositories/auth_repository.dart';
import '../network/socket_client.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final Couple? couple;
  final String? errorMessage;
  final String? inviteCode;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.couple,
    this.errorMessage,
    this.inviteCode,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasCouple => couple != null && couple!.isActive;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Couple? couple,
    String? errorMessage,
    String? inviteCode,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      couple: couple ?? this.couple,
      errorMessage: errorMessage,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final SocketClient _socket;

  AuthNotifier(this._repo, this._socket) : super(const AuthState()) {
    _checkAuth();
  }

  // Kiểm tra token khi khởi động app
  Future<void> _checkAuth() async {
    final token = await _repo.getToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final res = await _repo.getMe();
      final data = res['data'];
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(data['user']),
        couple: data['couple'] != null ? Couple.fromJson(data['couple']) : null,
      );
      // 🎯 Kết nối socket sau khi xác thực thành công
      _socket.connect(token);
    } catch (_) {
      await _repo.clearToken();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final res = await _repo.login(email, password);
      final data = res['data'];
      final token = data['token'] as String;
      await _repo.saveToken(token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(data['user']),
        couple: data['couple'] != null ? Couple.fromJson(data['couple']) : null,
      );

      // 🎯 Kết nối socket ngay sau khi login
      _socket.connect(token);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final res = await _repo.register(email, password, displayName);
      final data = res['data'];
      final token = data['token'] as String;
      await _repo.saveToken(token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(data['user']),
        couple: null,
      );
      _socket.connect(token);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> generateInvite() async {
    try {
      final res = await _repo.generateInvite();
      final code = res['data']['invite_code'] as String;
      state = state.copyWith(inviteCode: code);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> acceptInvite(String code) async {
    try {
      final res = await _repo.acceptInvite(code);
      final couple = Couple.fromJson(res['data']);
      state = state.copyWith(couple: couple);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    _socket.disconnect(); // Ngắt socket khi logout
    await _repo.clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> reloadProfile() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final res = await _repo.getMe();
      final data = res['data'];
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(data['user']),
        couple: data['couple'] != null ? Couple.fromJson(data['couple']) : null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

// ── Providers ─────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

final socketClientProvider = Provider<SocketClient>((_) => SocketClient());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(socketClientProvider),
  );
});
