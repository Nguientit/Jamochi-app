import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/mood_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _handleSend() async {
    final text = _msgController.text;

    if (text.trim().isNotEmpty) {
      _msgController.clear();
      try {
        await ref.read(chatProvider.notifier).sendMessage(text);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $e'),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final user = ref.watch(authProvider).user;
    final partnerName = user?.gender == 'male' ? 'Hà' : 'Nguyên';

    final chatState = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: palette.primary.withOpacity(0.3),
      appBar: _buildAppBar(palette, partnerName),
      body: Column(
        children: [
          // ── Danh sách tin nhắn ──
          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: palette.accent),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    reverse: true, // Cuộn từ dưới lên (Tin mới nhất nằm dưới)
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatState.messages[index];
                      final isMe =
                          msg.senderId == user?.id; // Kiểm tra ai là người gửi

                      return _buildMessageBubble(
                        text: msg.content ?? '',
                        isMe: isMe,
                        palette: palette,
                      );
                    },
                  ),
          ),

          // ── Khu vực nhập tin nhắn ──
          _buildInputArea(palette),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(MoodPalette palette, String partnerName) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: palette.secondary,
            child: Text(
              partnerName[0],
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                partnerName,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đang online',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required MoodPalette palette,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? palette.accent : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isMe ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputArea(MoodPalette palette) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_photo_alternate_rounded,
                color: palette.secondary,
                size: 28,
              ),
              onPressed: () {}, // Nút Locket sau này
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _msgController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Nhắn gửi yêu thương...',
                    hintStyle: GoogleFonts.nunito(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _handleSend, // 🎯 Gọi hàm gửi tin khi ấn
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
