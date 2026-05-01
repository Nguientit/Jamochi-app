import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/special_dates_provider.dart';
import 'edit_special_date_bottom_sheet.dart';

class SpecialDateDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final String title;
  final String dateStr;
  final int remainDays;

  const SpecialDateDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.dateStr,
    required this.remainDays,
  });

  @override
  ConsumerState<SpecialDateDetailScreen> createState() =>
      _SpecialDateDetailScreenState();
}

class _SpecialDateDetailScreenState extends ConsumerState<SpecialDateDetailScreen> {
  late String _currentTitle;
  late String _currentDateStr;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _currentDateStr = widget.dateStr;
  }

  void _openEditSheet() {
    DateTime? parsedDate;
    try {
      final parts = _currentDateStr.split('/');
      parsedDate = DateTime(
        DateTime.now().year,
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {}

    EditSpecialDateBottomSheet.show(
      context,
      initialTitle: _currentTitle,
      initialDate: parsedDate,
      onSave: (newTitle, newDate) async {
        await ref
            .read(specialDatesProvider.notifier)
            .updateDate(widget.id, newTitle, newDate);
        setState(() {
          _currentTitle = newTitle;
          _currentDateStr =
              "${newDate.day.toString().padLeft(2, '0')}/${newDate.month.toString().padLeft(2, '0')}";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Ngày kỷ niệm',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // 🎯 Nền Gradient Pastel (Từ Hồng sang Tím mộng mơ)
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFAFD0), // Hồng nhạt pastel
              Color(0xFFE0C3FC), // Tím nhạt pastel
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🎯 Thêm vài icon mờ ảo trang trí nền cho đỡ trống
            Positioned(
              top: 150,
              right: -20,
              child: Icon(
                Icons.star_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                size: 120,
              ),
            ),
            Positioned(
              bottom: 200,
              left: -30,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withValues(alpha: 0.15),
                size: 150,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentTitle,
                  style: GoogleFonts.nunito(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Còn ',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${widget.remainDays}',
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
                const SizedBox(height: 8),
                Text(
                  _currentDateStr,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),

            // 🎯 Chỉ giữ lại nút Edit (xóa nút Tải xuống)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: _buildCircleButton(Icons.edit, _openEditSheet),
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
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
