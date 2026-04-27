import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hành Trình')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text('Chưa có huy hiệu nào',
              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Hãy đánh giá ngày hôm nay để nhận huy hiệu đầu tiên!',
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}