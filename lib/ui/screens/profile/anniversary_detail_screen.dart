import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/providers/auth_provider.dart';
import 'anniversary_list_screen.dart';
import 'edit_special_date_bottom_sheet.dart';
import 'special_date_detail_screen.dart';

class AnniversaryDetailScreen extends ConsumerWidget {
  const AnniversaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(authProvider).couple;

    // Tự tính số ngày
    int daysTogether = 0;
    if (couple?.anniversaryDate != null) {
      final start = DateTime.tryParse(couple!.anniversaryDate!);
      if (start != null) {
        daysTogether = DateTime.now().difference(start).inDays;
      }
    }

    // Format ngày bắt đầu
    String startDateStr = 'Chưa cập nhật';
    if (couple?.anniversaryDate != null) {
      try {
        final date = DateTime.parse(couple!.anniversaryDate!);
        startDateStr = DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {}
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Ngày kỷ niệm',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // 🎯 Gradient tĩnh: Từ hồng nhạt xuống hồng đậm hơn
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFAFD0), // Hồng nhạt
              Color(0xFFFF85B3), // Hồng đậm
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 200,
              left: 50,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withValues(alpha: 0.2),
                size: 40,
              ),
            ),
            Positioned(
              top: 350,
              right: 60,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withValues(alpha: 0.3),
                size: 80,
              ),
            ),
            Positioned(
              bottom: 250,
              left: 100,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withValues(alpha: 0.2),
                size: 120,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Đã bên nhau',
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Đã ',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '$daysTogether',
                      style: GoogleFonts.nunito(
                        fontSize: 80,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      ' ngày',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Bắt đầu vào $startDateStr',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 80,
              child: Row(
                children: [
                  _buildCircleButton(Icons.edit, () {
                    EditSpecialDateBottomSheet.show(
                      context,
                      initialTitle: 'Đã bên nhau',
                      isMainAnniversary: true, // Khoá sửa tên
                      initialDate: DateTime.tryParse(
                        couple?.anniversaryDate ?? '',
                      ),
                      onSave: (title, date) async {
                        final success = await ref
                            .read(authProvider.notifier)
                            .updateAnniversaryDate(date);

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật ngày bên nhau 💕'),
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Cập nhật thất bại, vui lòng thử lại!',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
