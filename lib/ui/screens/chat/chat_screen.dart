// ui/screens/chat/chat_screen.dart
// 📁 JAMOCHI_APP/lib/ui/screens/chat/chat_screen.dart

import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/mood_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../models/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String partnerName; // 🎯 Thêm parameter để biết đang chat với ai

  const ChatScreen({super.key, this.partnerName = 'jaman'});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _imagePicker = ImagePicker();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).clearUnread();
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _isComposing = false);
    try {
      await ref.read(chatProvider.notifier).sendMessage(text);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final xfile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (xfile == null) return;

      await ref.read(chatProvider.notifier).sendImage(xfile);
    } catch (e) {
      _showError('Không thể gửi ảnh: $e');
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImagePickerSheet(onPick: _pickImage),
    );
  }

  void _showReactionPicker(
    BuildContext ctx,
    ChatMessage msg,
    MoodPalette palette,
  ) {
    const reactions = ['❤️', '😂', '😮', '😢', '😡', '👍'];
    final RenderBox box = ctx.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            left: offset.dx.clamp(0, screenWidth - 260),
            top: (offset.dy - 70).clamp(0, double.infinity),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: reactions.map((emoji) {
                    final isActive = msg.reaction == emoji;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ref
                            .read(chatProvider.notifier)
                            .reactToMessage(msg.id, isActive ? null : emoji);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? palette.accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: isActive ? 26 : 22),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.nunito(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showGeminiDialog(BuildContext context, MoodPalette palette) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Hỏi Mochi AI',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Hỏi gì cũng được nhé...',
                  hintStyle: GoogleFonts.nunito(color: AppColors.textLight),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (ctrl.text.trim().isEmpty) return;
                    Navigator.pop(context);
                    ref.read(chatProvider.notifier).askGemini(ctrl.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Gửi câu hỏi',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Logic gom nhóm tin nhắn ──────────────────────────────────────────────
  // (list đã reverse: index 0 = mới nhất)
  // isFirstInGroup: tin đầu tiên của nhóm sender = hiện avatar + tên
  // isLastInGroup:  tin cuối của nhóm           = hiện timestamp
  bool _isFirstInGroup(List<ChatMessage> msgs, int i) {
    if (i == 0) return true; // mới nhất
    final curr = msgs[i];
    final prev = msgs[i - 1]; // tin mới hơn (index nhỏ hơn)
    if (curr.senderId != prev.senderId) return true;
    // Nếu cách nhau > 5 phút → coi là nhóm mới
    return prev.createdAt.difference(curr.createdAt).inMinutes > 5;
  }

  bool _isLastInGroup(List<ChatMessage> msgs, int i) {
    if (i == msgs.length - 1) return true; // cũ nhất
    final curr = msgs[i];
    final next = msgs[i + 1]; // tin cũ hơn
    if (curr.senderId != next.senderId) return true;
    return curr.createdAt.difference(next.createdAt).inMinutes > 5;
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final user = ref.watch(authProvider).user;
    final chatState = ref.watch(chatProvider);
    final partnerName = user?.gender == 'male' ? 'Hà' : 'Nguyên';
    final isBoy = user?.gender == 'male';

    ref.listen(chatProvider, (prev, next) {
      if (next.errorMessage != null) {
        _showError(next.errorMessage!);
        ref.read(chatProvider.notifier).clearError();
      }
    });

    return Scaffold(
      // 🛡️ FIX KEY: true → input tự đẩy lên trên keyboard
      resizeToAvoidBottomInset: true,
      backgroundColor: palette.primary.withValues(alpha: 0.25),
      appBar: _buildAppBar(palette, partnerName, chatState, isBoy),
      body: Column(
        children: [
          // Reply bar
          if (chatState.replyingTo != null)
            _ReplyBar(
              message: chatState.replyingTo!,
              palette: palette,
              onCancel: () => ref.read(chatProvider.notifier).cancelReply(),
            ),

          // Typing indicator
          if (chatState.isPartnerTyping)
            _TypingIndicator(name: partnerName, palette: palette),

          // Danh sách tin nhắn
          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: palette.accent),
                  )
                : chatState.messages.isEmpty
                ? _EmptyChat(palette: palette, partnerName: partnerName)
                : ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: chatState.messages.length,
                    itemBuilder: (ctx, i) {
                      final msg = chatState.messages[i];
                      final isMe = msg.senderId == user?.id;
                      final isAI = msg.senderId == 'mochi_ai';

                      // Hiện label ngày khi đổi ngày
                      final showDate =
                          i == chatState.messages.length - 1 ||
                          !_sameDay(
                            msg.createdAt,
                            chatState.messages[i + 1].createdAt,
                          );

                      // 🎯 Gom nhóm: tính vị trí trong nhóm
                      final isFirst = _isFirstInGroup(chatState.messages, i);
                      final isLast = _isLastInGroup(chatState.messages, i);

                      return Column(
                        children: [
                          if (showDate) _DateLabel(date: msg.createdAt),
                          _MessageBubble(
                            key: ValueKey(msg.id),
                            message: msg,
                            isMe: isMe,
                            isAI: isAI,
                            palette: palette,
                            // isFirst: tin đầu nhóm → bo góc nhọn phía trên
                            // isLast:  tin cuối nhóm → hiện timestamp + bo góc nhọn phía dưới
                            isFirstInGroup: isFirst,
                            isLastInGroup: isLast,
                            onLongPress: (ctx) =>
                                _showReactionPicker(ctx, msg, palette),
                            onReply: () =>
                                ref.read(chatProvider.notifier).setReplyTo(msg),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          _InputArea(
            controller: _msgCtrl,
            palette: palette,
            isComposing: _isComposing,
            isSending: chatState.isSending,
            onChanged: (v) =>
                setState(() => _isComposing = v.trim().isNotEmpty),
            onSend: _handleSend,
            onImagePick: _showImagePicker,
            onAskGemini: () => _showGeminiDialog(context, palette),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    MoodPalette palette,
    String partnerName,
    ChatState state,
    bool isBoy,
  ) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      // 🛡️ FIX: automaticallyImplyLeading: true → Flutter tự thêm back button vì là pushed route
      automaticallyImplyLeading: true,
      iconTheme: IconThemeData(color: palette.accent),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: palette.secondary,
                child: Text(
                  partnerName[0],
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: state.partnerStatus.isOnline
                        ? Colors.green
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  key: ValueKey(state.partnerStatus.label),
                  state.isPartnerTyping
                      ? '✍️ Đang nhập...'
                      : state.partnerStatus.label,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: state.partnerStatus.isOnline
                        ? Colors.green
                        : AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_rounded, color: palette.accent),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MESSAGE BUBBLE — Có gom nhóm
// ══════════════════════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isAI;
  final MoodPalette palette;
  final bool isFirstInGroup; // tin mới nhất của nhóm (list đang reverse)
  final bool isLastInGroup; // tin cũ nhất của nhóm → hiện timestamp
  final void Function(BuildContext) onLongPress;
  final VoidCallback onReply;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isAI,
    required this.palette,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.onLongPress,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    if (isAI) return _AIBubble(message: message, palette: palette);

    // 🎯 Bo góc theo vị trí trong nhóm
    // ListView reverse=true: index 0 = mới nhất = hiển thị DƯỚI cùng
    // isFirstInGroup (tin mới nhất) = phía DƯỚI màn hình → bo góc dưới nhọn
    // isLastInGroup (tin cũ nhất)   = phía TRÊN màn hình → bo góc trên nhọn
    final double radiusFull = 20.0;
    final double radiusSharp = 4.0;

    final BorderRadius borderRadius = isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(radiusFull),
            topRight: Radius.circular(isLastInGroup ? radiusFull : radiusSharp),
            bottomLeft: Radius.circular(radiusFull),
            bottomRight: Radius.circular(
              isFirstInGroup ? radiusSharp : radiusFull,
            ),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(isLastInGroup ? radiusFull : radiusSharp),
            topRight: Radius.circular(radiusFull),
            bottomLeft: Radius.circular(
              isFirstInGroup ? radiusSharp : radiusFull,
            ),
            bottomRight: Radius.circular(radiusFull),
          );

    // Padding giữa các bubble: nhỏ hơn nếu cùng nhóm
    final double bottomPad = isFirstInGroup ? 8.0 : 2.0;

    return GestureDetector(
      onLongPress: () => onLongPress(context),
      child: Dismissible(
        key: ValueKey('d_${message.id}'),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (_) async {
          onReply();
          return false;
        },
        background: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Icon(
                Icons.reply_rounded,
                color: palette.accent.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                'Reply',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: palette.accent.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPad),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) const SizedBox(width: 4),
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Reply preview
                    if (message.replyContent != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: palette.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(color: palette.accent, width: 3),
                          ),
                        ),
                        child: Text(
                          message.replyContent!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),

                    // Bubble
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.72,
                          ),
                          padding: message.isImage
                              ? const EdgeInsets.all(4)
                              : const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                          decoration: BoxDecoration(
                            color: isMe ? palette.accent : Colors.white,
                            borderRadius: borderRadius,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: message.isImage
                              ? _ImageContent(mediaUrl: message.mediaUrl ?? '')
                              : Text(
                                  message.content ?? '',
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isMe
                                        ? Colors.white
                                        : AppColors.textDark,
                                    height: 1.4,
                                  ),
                                ),
                        ),

                        // Reaction badge
                        if (message.reaction != null)
                          Positioned(
                            bottom: -10,
                            right: isMe ? null : 0,
                            left: isMe ? 0 : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                message.reaction!,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // 🎯 Timestamp CHỈ hiện ở tin CUỐI NHÓM (cũ nhất của nhóm)
                    if (isLastInGroup) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          message.timeLabel,
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isMe) const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AI Bubble ─────────────────────────────────────────────────────────────────
class _AIBubble extends StatelessWidget {
  final ChatMessage message;
  final MoodPalette palette;
  const _AIBubble({required this.message, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.secondary.withValues(alpha: 0.3), palette.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.secondary.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mochi AI',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message.content ?? '',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textDark,
                      height: 1.4,
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

// ── Image Content ─────────────────────────────────────────────────────────────
class _ImageContent extends StatelessWidget {
  final String mediaUrl;
  const _ImageContent({required this.mediaUrl});

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        mediaUrl.startsWith('http') || mediaUrl.startsWith('blob:');

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.9), // Nền đen mờ
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Widget hỗ trợ Zoom ảnh (pinch to zoom)
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: isNetwork
                      ? Image.network(mediaUrl, fit: BoxFit.contain)
                      // 🎯 FIX: Đã thêm io. vào trước File
                      : Image.file(io.File(mediaUrl), fit: BoxFit.contain),
                ),
                // Nút x (Close) ở góc phải
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: isNetwork
            ? Image.network(
                mediaUrl,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, p) => p == null
                    ? child
                    : const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 220,
                  height: 80,
                  child: Center(
                    child: Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                ),
              )
            // 🎯 FIX: Đã thêm io. vào trước File
            : Image.file(
                io.File(mediaUrl),
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

// ── Reply Bar ─────────────────────────────────────────────────────────────────
class _ReplyBar extends StatelessWidget {
  final ChatMessage message;
  final MoodPalette palette;
  final VoidCallback onCancel;
  const _ReplyBar({
    required this.message,
    required this.palette,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: palette.primary.withValues(alpha: 0.6),
      child: Row(
        children: [
          Container(width: 3, height: 32, color: palette.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang trả lời',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: palette.accent,
                  ),
                ),
                Text(
                  message.isImage ? '📷 Ảnh' : (message.content ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: onCancel,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  final String name;
  final MoodPalette palette;
  const _TypingIndicator({required this.name, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
      child: Row(
        children: [
          Text(
            '$name đang nhập ',
            style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight),
          ),
          Text(
            '•••',
            style: TextStyle(
              color: palette.accent,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date Label ────────────────────────────────────────────────────────────────
class _DateLabel extends StatelessWidget {
  final DateTime date;
  const _DateLabel({required this.date});

  String get _label {
    final now = DateTime.now();
    final diff = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty Chat ────────────────────────────────────────────────────────────────
class _EmptyChat extends StatelessWidget {
  final MoodPalette palette;
  final String partnerName;
  const _EmptyChat({required this.palette, required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💌', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Chưa có tin nhắn nào',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Hãy gửi lời yêu thương đầu tiên cho $partnerName nhé 🌸',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input Area ────────────────────────────────────────────────────────────────
class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final MoodPalette palette;
  final bool isComposing;
  final bool isSending;
  final void Function(String) onChanged;
  final VoidCallback onSend;
  final VoidCallback onImagePick;
  final VoidCallback onAskGemini;

  const _InputArea({
    required this.controller,
    required this.palette,
    required this.isComposing,
    required this.isSending,
    required this.onChanged,
    required this.onSend,
    required this.onImagePick,
    required this.onAskGemini,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _IconBtn(
              icon: Icons.add_photo_alternate_rounded,
              color: palette.secondary,
              onTap: onImagePick,
            ),
            const SizedBox(width: 4),
            _IconBtn(
              icon: Icons.auto_awesome_rounded,
              color: palette.accent,
              onTap: onAskGemini,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: AppColors.textLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhắn gửi yêu thương...',
                      hintStyle: GoogleFonts.nunito(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSending
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: palette.accent,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: isComposing ? onSend : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: isComposing
                              ? palette.accent
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ── Image Picker Sheet ────────────────────────────────────────────────────────
class _ImagePickerSheet extends StatelessWidget {
  final void Function(ImageSource) onPick;
  const _ImagePickerSheet({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Gửi ảnh',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PickerOption(
                emoji: '📷',
                label: 'Chụp ảnh',
                onTap: () => onPick(ImageSource.camera),
              ),
              _PickerOption(
                emoji: '🖼️',
                label: 'Thư viện',
                onTap: () => onPick(ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _PickerOption({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
