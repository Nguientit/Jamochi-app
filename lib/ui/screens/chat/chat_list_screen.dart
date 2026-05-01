import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/mood_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/chat_provider.dart';
import './chat_screen.dart';
import '../ai/ai_screen.dart';
import '../settings/settings_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  // 🎯 Format thời gian "... phút trước"
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);
    final user = ref.watch(authProvider).user;
    final chatState = ref.watch(chatProvider);

    final partnerId =
        ref.watch(authProvider).couple?.partnerId(user?.id ?? '') ?? '';
    final partnerName = user?.gender == 'male' ? 'Hà' : 'Nguyên';

    String lastMessageText = 'Chưa có tin nhắn';

    if (chatState.messages.isNotEmpty) {
      // 💡 QUAN TRỌNG: Dùng .first vì danh sách đã được reverse (mới nhất ở index 0)
      final lastMsg = chatState.messages.first;

      final String prefix = lastMsg.senderId == user?.id ? 'Bạn: ' : '';

      if (lastMsg.type == 'text') {
        // Hiển thị nội dung văn bản
        lastMessageText = '$prefix${lastMsg.content ?? '...'}';
      } else if (lastMsg.type == 'image') {
        // Hiển thị thông báo gửi ảnh
        lastMessageText = '${prefix}đã gửi một ảnh';
      } else if (lastMsg.type == 'locket') {
        // Hiển thị thông báo gửi locket
        lastMessageText = '${prefix}đã gửi một locket';
      } else {
        lastMessageText = '${prefix}đã gửi một tin nhắn';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tin nhắn',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
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
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
      ),
      body: Column(
        children: [
          // 🎯 Avatar row - for future locket feature
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar cô ấy
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: palette.accent.withValues(alpha: 0.2),
                      child: Text(
                        user?.gender == 'male' ? '👧' : '🧑',
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      partnerName,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 32),

                // 💜 Icon giữa
                Icon(Icons.favorite_rounded, color: palette.accent, size: 28),

                const SizedBox(width: 32),

                // Avatar tôi
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: palette.accent.withValues(alpha: 0.2),
                      child: Text(
                        user?.gender == 'male' ? '🧑' : '👧',
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bạn',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // 🎯 Chat list hiển thị 2 người (Người yêu và Mochi AI)
          Expanded(
            child: ListView(
              children: [
                // 1. Trò chuyện với người yêu
                _buildChatItem(
                  context: context,
                  name: partnerName,
                  lastMessage: lastMessageText,
                  isOnline: chatState.partnerStatus.isOnline,
                  palette: palette,
                  avatarLabel: user?.gender == 'male' ? '👧' : '🧑',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(partnerName: partnerName),
                      ),
                    );
                  },
                ),

                // 2. Trò chuyện với Mochi AI
                _buildChatItem(
                  context: context,
                  name: 'Mochi AI',
                  lastMessage: 'Trợ lý AI luôn sẵn sàng lắng nghe bạn 🤖',
                  isOnline: true, // Mochi AI luôn online
                  palette: palette,
                  avatarLabel: '🤖',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 Widget item được tối ưu để dùng chung (sử dụng named parameters)
  Widget _buildChatItem({
    required BuildContext context,
    required String name,
    required String lastMessage,
    required bool isOnline,
    required MoodPalette palette,
    required String avatarLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: palette.accent.withValues(alpha: 0.2),
                  child: Text(
                    avatarLabel,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                // Online indicator
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
