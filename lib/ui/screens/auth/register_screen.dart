import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _obscurePass   = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _nameCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!, style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB5EAD7), Color(0xFFFFF5E4), Color(0xFFFFD6E0)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          Positioned(top: -50, left: -50, child: _bubble(180, AppColors.tiredPrimary.withOpacity(0.35))),
          Positioned(bottom: -60, right: -30, child: _bubble(200, AppColors.romanticPrimary.withOpacity(0.4))),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Column(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 52)),
                          const SizedBox(height: 12),
                          Text('Tạo tài khoản',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Bắt đầu hành trình của hai người',
                            style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 10))],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Tên của bạn'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameCtrl,
                              style: GoogleFonts.nunito(fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'Nguyên / Hà...',
                                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Nhập tên của bạn' : null,
                            ),
                            const SizedBox(height: 20),

                            _label('Email'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.nunito(fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'email@example.com',
                                prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Nhập email';
                                if (!v.contains('@')) return 'Email không hợp lệ';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _label('Mật khẩu'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePass,
                              style: GoogleFonts.nunito(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Tối thiểu 6 ký tự',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textLight),
                                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Nhập mật khẩu';
                                if (v.length < 5) return 'Mật khẩu tối thiểu 5 ký tự';
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tiredSecondary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : Text('Tạo tài khoản', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Đã có tài khoản? ', style: GoogleFonts.nunito(color: AppColors.textMedium, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('Đăng nhập',
                            style: GoogleFonts.nunito(
                              color: AppColors.tiredAccent, fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.tiredAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMedium, letterSpacing: 0.5));

  Widget _bubble(double size, Color color) =>
    Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}