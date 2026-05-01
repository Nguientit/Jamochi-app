// 📁 JAMOCHI_APP/lib/data/providers/app_providers.dart
//
// ✅ NGUỒN SỰ THẬT DUY NHẤT cho DioClient và SocketClient.
// Không import auth_provider ở đây để tránh circular dependency.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../network/socket_client.dart';

final socketClientProvider = Provider<SocketClient>((ref) {
  final socket = SocketClient();
  ref.onDispose(socket.disconnect);
  return socket;
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});