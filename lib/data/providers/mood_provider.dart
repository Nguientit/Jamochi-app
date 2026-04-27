// data/providers/mood_provider.dart
// 📁 JAMOCHI_APP/lib/data/providers/mood_provider.dart
// 🛡️ FIX: Lắng nghe Socket.IO để theme đổi real-time khi partner cập nhật mood

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../repositories/mood_repository.dart';
import '../network/socket_client.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class MoodThemeState {
  final String      currentMood;
  final MoodPalette palette;
  final bool        isPartnerMood; // true = đang hiển thị màu của partner
  final bool        isLoading;
  final String?     errorMessage;

  const MoodThemeState({
    required this.currentMood,
    required this.palette,
    this.isPartnerMood = false,
    this.isLoading     = false,
    this.errorMessage,
  });

  static MoodThemeState get defaultState => MoodThemeState(
    currentMood: 'normal',
    palette:     AppColors.getPalette('normal'),
  );

  MoodThemeState copyWith({
    String? currentMood,
    MoodPalette? palette,
    bool? isPartnerMood,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MoodThemeState(
      currentMood:   currentMood   ?? this.currentMood,
      palette:       palette       ?? this.palette,
      isPartnerMood: isPartnerMood ?? this.isPartnerMood,
      isLoading:     isLoading     ?? this.isLoading,
      errorMessage:  errorMessage,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class MoodThemeNotifier extends StateNotifier<MoodThemeState> {
  final MoodRepository _repo;
  final SocketClient   _socket;

  MoodThemeNotifier(this._repo, this._socket) : super(MoodThemeState.defaultState) {
    _listenToPartnerMood(); // Bắt đầu lắng nghe real-time ngay khi khởi tạo
  }

  // 🎯 QUAN TRỌNG: Lắng nghe khi partner đổi mood → tự động đổi màu app
  void _listenToPartnerMood() {
    _socket.onPartnerMoodChanged((data) {
      final mood = data['mood'] as String? ?? 'normal';
      print('[MoodProvider] Partner mood changed to: $mood — đổi theme!');
      state = MoodThemeState(
        currentMood:   mood,
        palette:       AppColors.getPalette(mood),
        isPartnerMood: true,  // Đánh dấu đây là mood của partner
      );
    });
  }

  // Gọi API lấy mood hiện tại (khi mở app / pull-to-refresh)
  Future<void> fetchLatestMood() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repo.getLatestMood();

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        // 🛡️ FIX: Backend trả về mood của PARTNER để chàng trai thấy màu đúng
        final mood = data['mood'] as String? ?? 'normal';

        state = MoodThemeState(
          currentMood:   mood,
          palette:       AppColors.getPalette(mood),
          // has_forecast = false nghĩa là chưa có dự báo, dùng màu mặc định
          isPartnerMood: data['has_forecast'] == true,
        );
      } else {
        // Không có dữ liệu → màu mặc định, không crash
        state = MoodThemeState.defaultState;
      }
    } catch (e) {
      print('[MoodProvider] fetchLatestMood error: $e');
      // Không crash app, chỉ log lỗi và giữ state cũ
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Cô ấy chọn mood → gọi API + đổi màu local ngay lập tức (không chờ response)
  Future<void> updateAndSetMood(String moodId) async {
    // Đổi màu local ngay để UX mượt
    state = MoodThemeState(
      currentMood:   moodId,
      palette:       AppColors.getPalette(moodId),
      isPartnerMood: false,
      isLoading:     true,
    );

    try {
      await _repo.updateMood(moodId);
      // Thành công → tắt loading
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[MoodProvider] updateAndSetMood error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Đổi local (không gọi API) — dùng khi nhận từ socket
  void setMood(String mood, {bool isPartner = false}) {
    state = MoodThemeState(
      currentMood:   mood,
      palette:       AppColors.getPalette(mood),
      isPartnerMood: isPartner,
    );
  }

  void clearError() => state = state.copyWith(errorMessage: null);
  void reset()       => state = MoodThemeState.defaultState;

  @override
  void dispose() {
    _socket.off('partner-mood-changed');
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final moodRepositoryProvider = Provider<MoodRepository>((_) => MoodRepository());

// 🛡️ FIX: SocketClient là singleton, dùng chung toàn app
final socketClientProvider = Provider<SocketClient>((_) => SocketClient());

final moodThemeProvider = StateNotifierProvider<MoodThemeNotifier, MoodThemeState>((ref) {
  final repo   = ref.read(moodRepositoryProvider);
  final socket = ref.read(socketClientProvider);
  return MoodThemeNotifier(repo, socket);
});

// Shortcut lấy palette hiện tại
final currentPaletteProvider = Provider<MoodPalette>((ref) {
  return ref.watch(moodThemeProvider).palette;
});