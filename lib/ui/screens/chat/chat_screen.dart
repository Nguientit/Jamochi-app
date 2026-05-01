// ui/screens/chat/chat_screen.dart
// 📁 JAMOCHI_APP/lib/ui/screens/chat/chat_screen.dart

import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui'; // Để dùng ImageFilter tạo nền mờ
import 'package:flutter/services.dart'; // Để dùng Clipboard (Sao chép)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/mood_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../models/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String partnerName;

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
    Navigator.pop(context); // Đóng bottom sheet
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

  // 🎯 ĐÃ SỬA: Truyền thêm palette để đồng bộ màu sắc UI
  void _showImagePicker(MoodPalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImagePickerSheet(onPick: _pickImage, palette: palette),
    );
  }

  void _showMessageOptions(
    BuildContext ctx,
    ChatMessage msg,
    MoodPalette palette,
    bool isMe,
  ) {
    const reactions = ['❤️', '😂', '😮', '😢', '😡', '👍'];
    final RenderBox box = ctx.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    // Tính toán vị trí top để menu không bị tràn khỏi màn hình khi tin nhắn ở quá cao hoặc quá thấp
    final topPosition = (offset.dy - 40).clamp(
      100.0,
      MediaQuery.of(context).size.height - 350.0,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => Stack(
        children: [
          // 1. LỚP NỀN MỜ (Blur Background kiểu iOS)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withValues(alpha: 0.2)),
              ),
            ),
          ),

          // 2. NỘI DUNG MENU
          Positioned(
            left: isMe ? null : 20,
            right: isMe ? 20 : null,
            top: topPosition,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // --- Thanh thả tim (Reactions) ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525), // Màu xám đen iOS
                      borderRadius: BorderRadius.circular(32),
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
                                .reactToMessage(
                                  msg.id,
                                  isActive ? null : emoji,
                                );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              emoji,
                              style: TextStyle(fontSize: isActive ? 28 : 24),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Menu Các Lựa Chọn ---
                  Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Nút Trả lời
                        _buildMenuOption('Trả lời', Icons.reply_rounded, () {
                          Navigator.pop(context);
                          ref.read(chatProvider.notifier).setReplyTo(msg);
                        }),
                        Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),

                        // Nút Sao chép
                        _buildMenuOption('Sao chép', Icons.copy_rounded, () {
                          Navigator.pop(context);
                          Clipboard.setData(
                            ClipboardData(text: msg.content ?? ''),
                          );
                          _showSuccess('Đã sao chép tin nhắn');
                        }),

                        // Nút Xóa (Chỉ hiện nếu là tin nhắn của mình)
                        if (isMe) ...[
                          Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          _buildMenuOption('Xóa', Icons.delete_outline_rounded, () {
                            Navigator.pop(context);
                            ref.read(chatProvider.notifier).deleteMessage(msg.id);
                            _showSuccess('Đã xóa tin nhắn');
                          }, isDestructive: true),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hỗ trợ vẽ các dòng Menu Option
  Widget _buildMenuOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.redAccent : Colors.white,
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.redAccent : Colors.white,
            ),
          ],
        ),
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

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade600,
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

  bool _isFirstInGroup(List<ChatMessage> msgs, int i) {
    if (i == 0) return true;
    final curr = msgs[i];
    final prev = msgs[i - 1];
    if (curr.senderId != prev.senderId) return true;
    return prev.createdAt.difference(curr.createdAt).inMinutes > 5;
  }

  bool _isLastInGroup(List<ChatMessage> msgs, int i) {
    if (i == msgs.length - 1) return true;
    final curr = msgs[i];
    final next = msgs[i + 1];
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
      resizeToAvoidBottomInset: true,
      backgroundColor: palette.primary.withValues(alpha: 0.25),
      appBar: _buildAppBar(palette, partnerName, chatState, isBoy),
      body: Column(
        children: [
          if (chatState.replyingTo != null)
            _ReplyBar(
              message: chatState.replyingTo!,
              palette: palette,
              onCancel: () => ref.read(chatProvider.notifier).cancelReply(),
            ),

          if (chatState.isPartnerTyping)
            _TypingIndicator(name: partnerName, palette: palette),

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

                      final showDate =
                          i == chatState.messages.length - 1 ||
                          !_sameDay(
                            msg.createdAt,
                            chatState.messages[i + 1].createdAt,
                          );

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
                            isFirstInGroup: isFirst,
                            isLastInGroup: isLast,
                            // 🎯 THAY ĐỔI DÒNG NÀY:
                            onLongPress: (ctx) =>
                                _showMessageOptions(ctx, msg, palette, isMe),
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
            onImagePick: () =>
                _showImagePicker(palette), // 🎯 Truyền palette vào
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
// 🎯 MESSAGE BUBBLE
// ══════════════════════════════════════════════════════════════════════════════
class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isAI;
  final MoodPalette palette;
  final bool isFirstInGroup;
  final bool isLastInGroup;
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
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isAI)
      return _AIBubble(message: widget.message, palette: widget.palette);

    final double radiusFull = 20.0;
    final double radiusSharp = 4.0;

    final BorderRadius borderRadius = widget.isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(radiusFull),
            topRight: Radius.circular(
              widget.isLastInGroup ? radiusFull : radiusSharp,
            ),
            bottomLeft: Radius.circular(radiusFull),
            bottomRight: Radius.circular(
              widget.isFirstInGroup ? radiusSharp : radiusFull,
            ),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(
              widget.isLastInGroup ? radiusFull : radiusSharp,
            ),
            topRight: Radius.circular(radiusFull),
            bottomLeft: Radius.circular(
              widget.isFirstInGroup ? radiusSharp : radiusFull,
            ),
            bottomRight: Radius.circular(radiusFull),
          );

    return Dismissible(
      key: ValueKey('d_${widget.message.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        widget.onReply();
        return false;
      },
      background: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Icon(
              Icons.reply_rounded,
              color: widget.palette.accent.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              'Reply',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: widget.palette.accent.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.isFirstInGroup ? 8.0 : 2.0),
        child: Column(
          crossAxisAlignment: widget.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showDetails = !_showDetails;
                });
              },
              onLongPress: () => widget.onLongPress(context),
              child: Row(
                mainAxisAlignment: widget.isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!widget.isMe) const SizedBox(width: 4),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: widget.isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (widget.message.replyContent != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: widget.palette.secondary.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(
                                  color: widget.palette.accent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              widget.message.replyContent!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.72,
                              ),
                              padding: widget.message.isImage
                                  ? const EdgeInsets.all(4)
                                  : const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                              decoration: BoxDecoration(
                                color: widget.isMe
                                    ? widget.palette.accent
                                    : Colors.white,
                                borderRadius: borderRadius,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: widget.message.isImage
                                  // 🎯 NÂNG CẤP TRUYỀN PALETTE CHO ẢNH
                                  ? _ImageContent(
                                      mediaUrl: widget.message.mediaUrl ?? '',
                                      palette: widget.palette,
                                    )
                                  : Text(
                                      widget.message.content ?? '',
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: widget.isMe
                                            ? Colors.white
                                            : AppColors.textDark,
                                        height: 1.4,
                                      ),
                                    ),
                            ),
                            if (widget.message.reaction != null)
                              Positioned(
                                bottom: -10,
                                right: widget.isMe ? null : 0,
                                left: widget.isMe ? 0 : null,
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
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    widget.message.reaction!,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.isMe) const SizedBox(width: 4),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: _showDetails
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: 6,
                        bottom: 4,
                        left: widget.isMe ? 0 : 12,
                        right: widget.isMe ? 12 : 0,
                      ),
                      child: Row(
                        mainAxisAlignment: widget.isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'HH:mm',
                            ).format(widget.message.createdAt),
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                          if (widget.isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              widget.message.isRead
                                  ? Icons.done_all_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 14,
                              color: widget.message.isRead
                                  ? widget.palette.accent
                                  : AppColors.textLight,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.message.isRead ? 'Đã xem' : 'Đã gửi',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: widget.message.isRead
                                    ? widget.palette.accent
                                    : AppColors.textLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

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

// ══════════════════════════════════════════════════════════════════════════════
// 🎯 NÂNG CẤP HIỂN THỊ ẢNH (BẤM ĐỂ ĐÓNG VÀ LƯU ẢNH)
// ══════════════════════════════════════════════════════════════════════════════
class _ImageContent extends StatelessWidget {
  final String mediaUrl;
  final MoodPalette palette;
  const _ImageContent({required this.mediaUrl, required this.palette});

  // HÀM GIẢ LẬP LƯU ẢNH (Thêm package `gal` để lưu vật lý)
  Future<void> _saveImage(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⏳ Đang tải ảnh...',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: Viết logic tải và lưu ảnh bằng thư viện ở đây
    await Future.delayed(const Duration(seconds: 1));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Đã lưu ảnh vào thư viện! 🎉',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        mediaUrl.startsWith('http') || mediaUrl.startsWith('blob:');

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(
            alpha: 0.95,
          ), // Nền đen sâu hơn xíu
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. LỚP NỀN: Bấm ra ngoài ảnh để đóng
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.transparent),
                ),

                // 2. ẢNH: Hấp thụ Tap (bấm vào ảnh sẽ không bị đóng để còn zoom)
                GestureDetector(
                  onTap: () {},
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: isNetwork
                        ? Image.network(mediaUrl, fit: BoxFit.contain)
                        : Image.file(io.File(mediaUrl), fit: BoxFit.contain),
                  ),
                ),

                // 3. NÚT TẮT X (Góc trên phải)
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

                // 4. NÚT LƯU ẢNH (Góc dưới phải)
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => _saveImage(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
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

// ── CÁC PHẦN CÒN LẠI (Reply Bar, Typing Indicator, Date Label, Empty Chat) GIỮ NGUYÊN ──
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

// ══════════════════════════════════════════════════════════════════════════════
// 🎯 NÂNG CẤP UI BOTTOM SHEET "GỬI ẢNH" LÊN TẦM CAO MỚI
// ══════════════════════════════════════════════════════════════════════════════
class _ImagePickerSheet extends StatelessWidget {
  final void Function(ImageSource) onPick;
  final MoodPalette palette; // Nhận màu chủ đạo
  const _ImagePickerSheet({required this.onPick, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo nhỏ
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Gửi ảnh',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn một bức ảnh thật đẹp nhé 💕',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 32),

          // 2 Lựa chọn
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PickerOption(
                icon: Icons.camera_alt_rounded,
                color: palette.accent,
                bgColor: palette.primary,
                label: 'Máy ảnh',
                onTap: () => onPick(ImageSource.camera),
              ),
              _PickerOption(
                icon: Icons.photo_library_rounded,
                color: Colors.blue.shade500,
                bgColor: Colors.blue.shade50,
                label: 'Thư viện',
                onTap: () => onPick(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.color,
    required this.bgColor,
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
