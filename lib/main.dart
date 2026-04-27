import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/mood_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/invite_screen.dart';
import 'ui/screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ép portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar trong suốt
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
  runApp(const ProviderScope(child: JamochiApp()));
}

class JamochiApp extends ConsumerWidget {
  const JamochiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState  = ref.watch(authProvider);
    final moodState  = ref.watch(moodThemeProvider);
    final theme      = AppTheme.fromPalette(moodState.palette);

    return MaterialApp(
      title: 'Jamochi 🌸',
      debugShowCheckedModeBanner: false,
      theme: theme,

      // Animated theme transitions
      themeAnimationDuration: const Duration(milliseconds: 600),
      themeAnimationCurve: Curves.easeInOut,

      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      // Đang kiểm tra token → màn splash
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const _SplashScreen();

      // Đã đăng nhập
      case AuthStatus.authenticated:
        // Chưa ghép đôi → màn invite
        if (!authState.hasCouple) return const InviteScreen();
        // Đã có couple → vào app
        return const MainScreen();

      // Chưa đăng nhập / lỗi
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}

// ── Splash Screen đơn giản ────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌸', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              'Jamochi',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}