import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../screens/main/main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePass = true;
  bool _rememberMe = true;
  bool _isLoggingIn = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    final rememberMe = prefs.getBool('remember_me') ?? true;

    if (rememberMe && savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
      setState(() {
        _emailCtrl.text = savedEmail;
        _passwordCtrl.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 🎯 Tự động tắt lỗi cũ (nếu có) khi bấm nút
    ref.read(authProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoggingIn = true);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }

    await ref.read(authProvider.notifier).login(email, password);

    if (mounted) {
      setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      // Bắt sự kiện khi trạng thái chuyển sang authenticated
      if (next.isAuthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            // 💡 LƯU Ý: Thay 'MainScreen' bằng đúng tên màn hình chính của bạn
            builder: (context) => const MainScreen(),
          ),
          (route) =>
              false, // Xóa sạch stack để không back lại trang login được nữa
        );
      }
    });
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD6E0),
                  Color(0xFFFFF5E4),
                  Color(0xFFC8B6E2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Bong bóng trang trí
          Positioned(
            top: -60,
            right: -60,
            child: _Bubble(
              200,
              AppColors.romanticSecondary.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: _Bubble(220, AppColors.sadPrimary.withValues(alpha: 0.3)),
          ),
          Positioned(
            top: 200,
            left: -30,
            child: _Bubble(
              120,
              AppColors.happySecondary.withValues(alpha: 0.2),
            ),
          ),

          // ── Nội dung ────────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      // Logo + tên app
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.romanticSecondary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '🌸',
                                  style: TextStyle(fontSize: 44),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Jamochi',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Chỉ dành cho Jaman 💕',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Card form
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chào mừng trở lại',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Đăng nhập để gặp Jimin from Hải Phòng nhóee!',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Email
                              _buildLabel('Email'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                ),
                                // 🎯 Tự xóa lỗi khi bắt đầu gõ lại
                                onChanged: (val) {
                                  if (authState.errorMessage != null) {
                                    ref
                                        .read(authProvider.notifier)
                                        .clearError();
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: 'email@example.com',
                                  prefixIcon: Icon(
                                    Icons.mail_outline_rounded,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Nhập email của bạn';
                                  if (!v.contains('@'))
                                    return 'Email không hợp lệ';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password
                              _buildLabel('Mật khẩu'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePass,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                ),
                                // 🎯 Tự xóa lỗi khi bắt đầu gõ lại
                                onChanged: (val) {
                                  if (authState.errorMessage != null) {
                                    ref
                                        .read(authProvider.notifier)
                                        .clearError();
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePass
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: AppColors.textLight,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscurePass = !_obscurePass,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Nhập mật khẩu';
                                  if (v.length < 5)
                                    return 'Mật khẩu tối thiểu 5 ký tự';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 🎯 KHUNG BÁO LỖI HIỂN THỊ TRỰC TIẾP (INLINE ERROR)
                              if (authState.errorMessage != null &&
                                  authState.errorMessage!.isNotEmpty)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.red.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authState.errorMessage!,
                                          style: GoogleFonts.nunito(
                                            color: Colors.red.shade700,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Checkbox Nhớ mật khẩu
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: const Color(0xFFE8547A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _rememberMe = !_rememberMe;
                                      });
                                    },
                                    child: Text(
                                      'Ghi nhớ đăng nhập',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: AppColors.textMedium,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // Nút đăng nhập
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoggingIn ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE8547A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoggingIn
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          'Đăng nhập',
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
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

                      const SizedBox(height: 24),

                      // Link sang Register
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Chưa có tài khoản? ',
                              style: GoogleFonts.nunito(
                                color: AppColors.textMedium,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                              child: Text(
                                'Đăng ký ngay',
                                style: GoogleFonts.nunito(
                                  color: const Color(0xFFE8547A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFFE8547A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMedium,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Bubble trang trí ──────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final double size;
  final Color color;
  const _Bubble(this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
