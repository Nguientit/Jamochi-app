// ui/screens/mood/mood_screen.dart
// 📁 JAMOCHI_APP/lib/ui/screens/mood/mood_screen.dart
// 🛡️ FIX: Gọi fetchLatestMood khi màn hình mở, pull-to-refresh hoạt động đúng

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/mood_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../settings/settings_screen.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moodThemeProvider.notifier).fetchLatestMood();
    });
  }

  Map<String, dynamic> _getWeatherInfo(String moodId) {
    switch (moodId) {
      case 'angry':
        return {
          'icon': '⛈️',
          'title': 'BÃO SẮP ĐẾN',
          'temp': '5°C tình cảm',
          'desc': 'Áp thấp nhiệt đới. Cẩn thận lời ăn tiếng nói!',
          'progress': 0.9,
          'warningLabel': '95%',
          'warningText': 'Nguy hiểm cao',
          'colors': [Colors.orange, Colors.red],
        };
      case 'sad':
        return {
          'icon': '🌧️',
          'title': 'MƯA RÀO RẢI RÁC',
          'temp': '15°C sướt mướt',
          'desc': 'Độ ẩm cao, dễ rơi nước mắt. Cần người che ô!',
          'progress': 0.7,
          'warningLabel': '70%',
          'warningText': 'Cần dỗ dành',
          'colors': [Colors.blue.shade300, Colors.blue.shade700],
        };
      case 'anxious':
        return {
          'icon': '🌪️',
          'title': 'GIÔNG TỐ KÉO VỀ',
          'temp': '18°C bất an',
          'desc': 'Mây mù giăng lối, tâm trạng đang rất bồn chồn.',
          'progress': 0.6,
          'warningLabel': '60%',
          'warningText': 'Cần trấn an',
          'colors': [Colors.teal.shade300, Colors.teal.shade700],
        };
      case 'tired':
        return {
          'icon': '🌫️',
          'title': 'SƯƠNG MÙ DÀY ĐẶC',
          'temp': '20°C uể oải',
          'desc': 'Tầm nhìn xa giảm, cạn kiệt năng lượng hoạt động.',
          'progress': 0.5,
          'warningLabel': '50%',
          'warningText': 'Cần nghỉ ngơi',
          'colors': [Colors.grey.shade400, Colors.grey.shade600],
        };
      case 'romantic':
        return {
          'icon': '🌸',
          'title': 'MÙA XUÂN HOA NỞ',
          'temp': '25°C lãng mạn',
          'desc': 'Không khí trong lành, ngập tràn mùi hương tình yêu.',
          'progress': 0.2,
          'warningLabel': '20%',
          'warningText': 'Say đắm',
          'colors': [Colors.pinkAccent.shade100, Colors.pink],
        };
      case 'happy':
        return {
          'icon': '☀️',
          'title': 'NẮNG VÀNG RỰC RỠ',
          'temp': '32°C cực vui',
          'desc': 'Tỏa nắng ấm áp, tâm trạng cực kỳ yêu đời!',
          'progress': 0.05,
          'warningLabel': '5%',
          'warningText': 'Tuyệt vời',
          'colors': [Colors.greenAccent, Colors.green],
        };
      default:
        return {
          'icon': '🌤️',
          'title': 'TRỜI QUANG MÂY TẠNH',
          'temp': '26°C bình yên',
          'desc': 'Gió nhẹ hiu hiu, mọi thứ đang ở mức ổn định.',
          'progress': 0.1,
          'warningLabel': '10%',
          'warningText': 'An toàn',
          'colors': [Colors.lightBlueAccent, Colors.blue],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodThemeProvider);
    final palette = moodState.palette;
    final user = ref.watch(authProvider).user;
    final isBoy = user?.gender == 'male';
    final weather = _getWeatherInfo(moodState.currentMood);

    return Scaffold(
      appBar: AppBar(
        title: Text(isBoy ? 'Trạm Quan Sát Tâm Trạng' : 'Dự Báo Tâm Trạng'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              child: Hero(
                tag: 'user_avatar_setting',
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.pink.shade100,
                    // 1. Nếu có link thật thì hiện ảnh
                    backgroundImage:
                        (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    // 2. Nếu KHÔNG có ảnh thì lấy chữ cái đầu
                    child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                        ? Text(
                            (user?.displayLabel.isNotEmpty == true)
                                ? user!.displayLabel[0].toUpperCase()
                                : 'J',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.pink.shade600,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        // 🛡️ FIX: Pull-to-refresh thật sự gọi API
        onRefresh: () => ref.read(moodThemeProvider.notifier).fetchLatestMood(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hiển thị lỗi nếu có ──────────────────────────────────────
              if (moodState.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          moodState.errorMessage!,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () =>
                            ref.read(moodThemeProvider.notifier).clearError(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // ── Thẻ thời tiết tâm trạng ──────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather['icon'],
                          style: const TextStyle(fontSize: 70),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Hôm nay',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 🎯 Loading indicator thay cho "Trực tiếp"
                            moodState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Trực tiếp',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      weather['title'],
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1A24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather['temp'],
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather['desc'],
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.textMedium,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Progress bar
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (weather['progress'] as double).clamp(
                          0.0,
                          1.0,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: weather['colors'] as List<Color>,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mức cảnh báo: ${weather['warningLabel']}',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          weather['warningText'] as String,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: (weather['colors'] as List<Color>).last,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Center(
                child: Text(
                  isBoy
                      ? 'Trạng thái của chị nhà'
                      : 'Cậu đang cảm thấy thế nào?',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (!isBoy)
                _buildMoodGrid(ref, palette)
              else
                _buildBoyStatusNote(palette),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodGrid(WidgetRef ref, MoodPalette palette) {
    final moods = [
      {'id': 'happy', 'emoji': '😊', 'label': 'Vui vẻ'},
      {'id': 'romantic', 'emoji': '🥰', 'label': 'Yêu thí'},
      {'id': 'tired', 'emoji': '😴', 'label': 'Mệt nha'},
      {'id': 'anxious', 'emoji': '😰', 'label': 'Lo lắng'},
      {'id': 'sad', 'emoji': '😢', 'label': 'Buồn 1 xí'},
      {'id': 'angry', 'emoji': '😠', 'label': 'Đang giận'},
      {'id': 'normal', 'emoji': '😐', 'label': 'Phình phường'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: moods.length,
      itemBuilder: (context, i) {
        final mood = moods[i];
        final isSelected =
            ref.watch(moodThemeProvider).currentMood == mood['id'];

        return GestureDetector(
          onTap: () => ref
              .read(moodThemeProvider.notifier)
              .updateAndSetMood(mood['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? palette.accent.withOpacity(0.15)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: palette.accent, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mood['emoji'] as String,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  mood['label'] as String,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? palette.accent : AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoyStatusNote(MoodPalette palette) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.radar_rounded, color: palette.accent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Radar đang theo dõi cảm xúc của chị nhà!',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
