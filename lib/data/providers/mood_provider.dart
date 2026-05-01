// 📁 JAMOCHI_APP/lib/data/providers/mood_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../repositories/mood_repository.dart';
import 'app_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class MoodThemeState {
  final String currentMood;
  final MoodPalette palette;
  final bool isPartnerMood;
  final bool isLoading;
  final String? errorMessage;

  const MoodThemeState({
    required this.currentMood,
    required this.palette,
    this.isPartnerMood = false,
    this.isLoading = false,
    this.errorMessage,
  });

  static MoodThemeState get defaultState => MoodThemeState(
        currentMood: 'normal',
        palette: AppColors.getPalette('normal'),
      );

  MoodThemeState copyWith({
    String? currentMood,
    MoodPalette? palette,
    bool? isPartnerMood,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MoodThemeState(
      currentMood: currentMood ?? this.currentMood,
      palette: palette ?? this.palette,
      isPartnerMood: isPartnerMood ?? this.isPartnerMood,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class MoodThemeNotifier extends StateNotifier<MoodThemeState> {
  final MoodRepository _repo;
  final Ref _ref;

  MoodThemeNotifier(this._repo, this._ref) : super(MoodThemeState.defaultState) {
    _listenToPartnerMood();
  }

  void _listenToPartnerMood() {
    // ✅ Lấy socket từ provider toàn cục — cùng instance với AuthNotifier
    _ref.read(socketClientProvider).onPartnerMoodChanged((data) {
      final mood = data['mood'] as String? ?? 'normal';
      state = MoodThemeState(
        currentMood: mood,
        palette: AppColors.getPalette(mood),
        isPartnerMood: true,
      );
    });
  }

  Future<void> fetchLatestMood() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repo.getLatestMood();
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        final mood = data['mood'] as String? ?? 'normal';
        state = MoodThemeState(
          currentMood: mood,
          palette: AppColors.getPalette(mood),
          isPartnerMood: data['has_forecast'] == true,
        );
      } else {
        state = MoodThemeState.defaultState;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateAndSetMood(String moodId) async {
    state = MoodThemeState(
      currentMood: moodId,
      palette: AppColors.getPalette(moodId),
      isPartnerMood: false,
      isLoading: true,
    );
    try {
      await _repo.updateMood(moodId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setMood(String mood, {bool isPartner = false}) {
    state = MoodThemeState(
      currentMood: mood,
      palette: AppColors.getPalette(mood),
      isPartnerMood: isPartner,
    );
  }

  void clearError() => state = state.copyWith(errorMessage: null);
  void reset() => state = MoodThemeState.defaultState;

  @override
  void dispose() {
    _ref.read(socketClientProvider).off('partner-mood-changed');
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final moodRepositoryProvider = Provider<MoodRepository>((_) => MoodRepository());

final moodThemeProvider = StateNotifierProvider<MoodThemeNotifier, MoodThemeState>((ref) {
  return MoodThemeNotifier(ref.read(moodRepositoryProvider), ref);
});

final currentPaletteProvider = Provider<MoodPalette>((ref) {
  return ref.watch(moodThemeProvider).palette;
});