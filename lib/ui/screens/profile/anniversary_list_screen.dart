// 📁 JAMOCHI_APP/lib/ui/screens/anniversary_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/special_dates_provider.dart';
import '../../../models/user.dart';
import 'anniversary_detail_screen.dart';
import 'edit_special_date_bottom_sheet.dart';
import 'special_date_detail_screen.dart';

class AnniversaryListScreen extends ConsumerStatefulWidget {
  const AnniversaryListScreen({super.key});

  @override
  ConsumerState<AnniversaryListScreen> createState() =>
      _AnniversaryListScreenState();
}

class _AnniversaryListScreenState extends ConsumerState<AnniversaryListScreen> {
  Widget _buildDigitBox(String digit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 32,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildAvatar(User? user, String fallbackName) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                ? Image.network(
                    user.avatarUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: Colors.pink.shade100,
                    alignment: Alignment.center,
                    child: Text(
                      user?.displayLabel.isNotEmpty == true
                          ? user!.displayLabel[0].toUpperCase()
                          : fallbackName[0],
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade600,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user?.displayLabel ?? fallbackName,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // 🎯 Đã cập nhật tham số onTap và bọc bằng GestureDetector
  Widget _buildEventCard({
    required String title,
    required String dateStr,
    required String remainText,
    required Color remainColor,
    bool isPast = false,
    VoidCallback? onTap, // Thêm dòng này
  }) {
    return GestureDetector(
      onTap: onTap, // Thêm sự kiện click
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  isPast ? 'Đã ' : 'Còn ',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: remainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  remainText,
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: remainColor,
                    height: 1.0,
                  ),
                ),
                Text(
                  ' ngày',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: remainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final couple = authState.couple;
    final partner = (couple?.user1Id == user?.id)
        ? couple?.user2
        : couple?.user1;
    final specialDatesState = ref.watch(specialDatesProvider);
    int daysTogether = 0;
    if (couple?.anniversaryDate != null) {
      final start = DateTime.tryParse(couple!.anniversaryDate!);
      if (start != null) {
        daysTogether = DateTime.now().difference(start).inDays;
      }
    }
    final daysString = daysTogether.toString();

    String startDateStr = 'Chưa cập nhật';
    if (couple?.anniversaryDate != null) {
      try {
        final date = DateTime.parse(couple!.anniversaryDate!);
        startDateStr = DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {}
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true, // Giúp body chui tọt xuống dưới AppBar
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
        // 🎯 3. THÊM 2 DÒNG NÀY ĐỂ ĐẢM BẢO BACKGROUND LUÔN PHỦ KÍN 100% MÀN HÌNH
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFAFD0), Color(0xFFFFF0F5)],
            stops: [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnniversaryDetailScreen(),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã bên nhau ',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        ...daysString
                            .split('')
                            .map((digit) => _buildDigitBox(digit)),
                        Text(
                          ' ngày >',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bắt đầu vào $startDateStr',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(user, 'Bạn'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.pink.shade300,
                      size: 40,
                    ),
                  ),
                  _buildAvatar(partner, 'Người ấy'),
                ],
              ),
              const SizedBox(height: 32),

              Expanded(
                child: specialDatesState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : specialDatesState.dates.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có ngày kỷ niệm nào\nHãy thêm ngày mới nhé 💕',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: specialDatesState.dates.length + 1,
                        itemBuilder: (context, index) {
                          if (index == specialDatesState.dates.length) {
                            return const SizedBox(height: 80);
                          }

                          final item = specialDatesState.dates[index];
                          final isEven = index % 2 == 0;
                          final color = isEven
                              ? const Color(0xFF45B0A6)
                              : const Color(0xFFC75D9C);

                          return _buildEventCard(
                            title: item.title,
                            dateStr: item.formattedDate,
                            remainText: item.remainDays.toString(),
                            remainColor: color,
                            isPast: item.isPast,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SpecialDateDetailScreen(
                                    id: item.id,
                                    title: item.title,
                                    dateStr: item.formattedDate,
                                    remainDays: item.remainDays,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          EditSpecialDateBottomSheet.show(
            context,
            onSave: (title, date) async {
              final success = await ref
                  .read(specialDatesProvider.notifier)
                  .addDate(title, date);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm kỷ niệm mới 💕')),
                );
              }
            },
          );
        },
        backgroundColor: const Color(0xFFFFB3C6),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
