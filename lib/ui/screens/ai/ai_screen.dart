import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/providers/mood_provider.dart';

class AiScreen extends ConsumerWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mochi AI 🤖')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text('Đang nạp dữ liệu Mochi AI...',
              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Người anh em thiện lành sắp có mặt để gỡ rối cho bạn!',
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: palette.accent,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}