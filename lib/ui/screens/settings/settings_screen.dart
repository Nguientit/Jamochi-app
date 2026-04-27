import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài Đặt')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.5),
            child: const Text('🌸', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 16),
          Text(user?.displayName ?? 'Khách',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          Text(user?.email ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text('Cài đặt thông báo', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              onTap: () {
                // Gọi hàm Đăng xuất từ provider
                ref.read(authProvider.notifier).logout();
              },
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: Text('Đăng xuất', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.redAccent)),
            ),
          ),
        ],
      ),
    );
  }
}