import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/auth_provider.dart';

class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen>
    with SingleTickerProviderStateMixin {
  final _codeCtrl = TextEditingController();
  bool _isEnterMode = false; // false = hiển thị mã, true = nhập mã

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    await ref.read(authProvider.notifier).generateInvite();
  }

  Future<void> _acceptCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length < 8) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_snack('Mã mời phải đủ 8 ký tự', AppColors.error));
      return;
    }
    final ok = await ref.read(authProvider.notifier).acceptInvite(code);
    if (ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_snack('Ghép đôi thành công 💑', AppColors.success));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final inviteCode = authState.inviteCode;
    final user = authState.user;

    ref.listen(authProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(_snack(next.errorMessage!, AppColors.error));
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD6E0),
                  Color(0xFFFFF5E4),
                  Color(0xFFAED9E0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -40,
            child: _bubble(160, AppColors.romanticSecondary.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: _bubble(200, AppColors.anxiousPrimary.withOpacity(0.3)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Avatar + chào
                    const Text('💑', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      'Xin chào, ${user?.displayName ?? ''}!',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy ghép đôi với người ấy\nđể bắt đầu hành trình 🌸',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: AppColors.textMedium,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Toggle 2 mode
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _tab(
                            'Tạo mã mời',
                            !_isEnterMode,
                            () => setState(() => _isEnterMode = false),
                          ),
                          _tab(
                            'Nhập mã mời',
                            _isEnterMode,
                            () => setState(() => _isEnterMode = true),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Nội dung theo mode
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isEnterMode
                          ? _enterCodeSection(authState)
                          : _showCodeSection(inviteCode, authState),
                    ),

                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text(
                        'Đăng xuất',
                        style: GoogleFonts.nunito(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showCodeSection(String? code, AuthState authState) {
    return Container(
      key: const ValueKey('show'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Mã ghép đôi của bạn',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          if (code != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD6E0), Color(0xFFFFB3C6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snack('Đã sao chép mã! 📋', AppColors.success),
                      );
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gửi mã này cho người ấy và bảo họ nhập vào',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
          ] else ...[
            const Text('🔗', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Tạo mã để gửi cho người ấy',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _generateCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8547A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      code != null ? 'Tạo mã mới' : 'Tạo mã mời',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: authState.isLoading
                ? null
                : () => ref.read(authProvider.notifier).reloadProfile(),
            icon: const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: AppColors.textMedium,
            ),
            label: Text(
              'Jaman đã nhập mã? Bấm để vào',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _enterCodeSection(AuthState authState) {
    return Container(
      key: const ValueKey('enter'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('💌', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Nhập mã mời từ người ấy',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _codeCtrl,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
            maxLength: 8,
            decoration: InputDecoration(
              hintText: 'XXXXXXXX',
              hintStyle: GoogleFonts.nunito(
                fontSize: 22,
                color: AppColors.textLight,
                letterSpacing: 4,
              ),
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _acceptCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tiredSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Ghép đôi ngay 💕',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColors.textDark : AppColors.textMedium,
            ),
          ),
        ),
      ),
    );
  }

  SnackBar _snack(String msg, Color color) => SnackBar(
    content: Text(msg, style: GoogleFonts.nunito(color: Colors.white)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
  );

  Widget _bubble(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
