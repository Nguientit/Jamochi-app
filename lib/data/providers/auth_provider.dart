// 📁 JAMOCHI_APP/lib/data/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../models/couple.dart';
import '../repositories/auth_repository.dart';
import 'app_providers.dart';

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
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(const AuthState()) {
    _ref.read(dioClientProvider).onUnauthorized = logout;
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _repo.getToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final res = await _repo.getMe();
      final data = res['data'];
      final userJson = data['user'] ?? data;
      final coupleJson = data['couple'];

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(userJson),
        couple: coupleJson != null ? Couple.fromJson(coupleJson) : null,
      );

      _connectSocket(token, userJson['id']?.toString());
    } catch (e) {
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

      _connectSocket(token, data['user']?['id']?.toString());
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

      _connectSocket(token, data['user']?['id']?.toString());
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    final socket = _ref.read(socketClientProvider);
    if (state.user?.id != null) socket.emitUserOffline(state.user!.id);
    socket.disconnect();
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
        user: User.fromJson(data['user'] ?? data),
        couple: data['couple'] != null ? Couple.fromJson(data['couple']) : null,
      );
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
      state = state.copyWith(inviteCode: res['data']['invite_code'] as String);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> acceptInvite(String code) async {
    try {
      final res = await _repo.acceptInvite(code);
      state = state.copyWith(couple: Couple.fromJson(res['data']));
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateAnniversaryDate(DateTime newDate) async {
    try {
      final res = await _repo.updateAnniversary(
        newDate.toIso8601String().split('T')[0],
      );
      if (res['success'] == true && state.couple != null) {
        state = state.copyWith(
          couple: state.couple!.copyWith(
            anniversaryDate: newDate.toIso8601String().split('T')[0],
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi update anniversary: $e');
      return false;
    }
  }

  // ── Cập nhật Biệt danh ──────────────────────────────────────────────────────
  Future<void> updateNickname(String newNickname) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    try {
      final res = await _repo.updateNickname(newNickname);
      
      if (res['success'] == true) {
        final updatedUser = currentUser.copyWith(nickname: newNickname);
        
        state = state.copyWith(user: updatedUser);
      } else {
        throw Exception(res['message'] ?? 'Lỗi không xác định từ server');
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật biệt danh: $e');
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  // ── Private helpers ───────────────────────────────────────────────────────
  void _connectSocket(String token, String? userId) {
    final socket = _ref.read(socketClientProvider);
    socket.connect(token);
    if (userId != null && userId.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        socket.emitUserOnline(userId);
      });
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

/// ✅ authProvider nhận Ref để gắn onUnauthorized vào DioClient
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider), ref);
});
