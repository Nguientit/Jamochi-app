import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🎯 Thêm 3 dòng import Firebase này
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import '../core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/mood_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/invite_screen.dart';
import 'ui/screens/main/main_screen.dart';

// 🎯 Hàm này PHẢI nằm ngoài mọi class để nhận thông báo khi App đã vuốt tắt ngầm
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📬 Nhận được thông báo ngầm: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🎯 1. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🎯 2. Đăng ký hàm nhận thông báo ngầm
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🎯 3. Xin quyền hiện thông báo từ người dùng
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true, badge: true, sound: true,
  );

  // 🎯 4. Lấy FCM Token của thiết bị này
  try {
    final fcmToken = await messaging.getToken();
    print('====================================');
    print('🔑 FCM TOKEN CỦA MÁY NÀY LÀ: $fcmToken');
    print('====================================');
  } catch (e) {
    print('🚨 Lỗi không lấy được Token: $e');
  }

  // 🎯 5. Xử lý khi người dùng đang mở App mà có thông báo tới
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📬 Thông báo tới khi đang mở app: ${message.notification?.title}');
    // Sau này chúng ta sẽ thêm code hiện popup SnackBar ở đây
  });

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