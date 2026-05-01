import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/memories_provider.dart';
// 🎯 IMPORT THÊM PROVIDER NGÀY KỶ NIỆM
import '../../../data/providers/special_dates_provider.dart';
import '../../../models/user.dart';
import '../profile/partner_profile_screen.dart';
import '../chat/chat_screen.dart';

class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  @override
  void initState() {
    super.initState();
    // 🎯 GỌI CẢ 2 API KHI MỞ MÀN HÌNH ĐỂ TRỘN DỮ LIỆU
    Future.microtask(() {
      ref.read(memoriesProvider.notifier).fetchMemories();
      ref.read(specialDatesProvider.notifier).fetchDates();
    });
  }

  // Lọc dữ liệu & đảo ngược tháng (Mới nhất nằm dưới cùng)
  List<DateTime> _generateDisplayMonths(Map<String, dynamic> data) {
    final now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month);

    if (data.isNotEmpty) {
      DateTime? earliestPhotoDate;
      data.forEach((monthKey, daysMap) {
        bool hasPhoto = (daysMap as Map).values.any(
          (day) => day.photoUrl != null && day.photoUrl.toString().isNotEmpty,
        );
        if (hasPhoto) {
          try {
            final parts = monthKey.split('-');
            final currentMonthDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
            if (earliestPhotoDate == null ||
                currentMonthDate.isBefore(earliestPhotoDate!)) {
              earliestPhotoDate = currentMonthDate;
            }
          } catch (_) {}
        }
      });
      if (earliestPhotoDate != null) startDate = earliestPhotoDate!;
    }

    List<DateTime> months = [];
    DateTime temp = DateTime(now.year, now.month);
    while (temp.isAfter(startDate) ||
        (temp.year == startDate.year && temp.month == startDate.month)) {
      months.add(DateTime(temp.year, temp.month));
      temp = DateTime(temp.year, temp.month - 1);
    }
    return months;
  }

  Widget _buildBaseAvatar(User? targetUser, double radius) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.pink.shade100,
        backgroundImage:
            (targetUser?.avatarUrl != null && targetUser!.avatarUrl!.isNotEmpty)
            ? NetworkImage(targetUser!.avatarUrl!)
            : null,
        child: (targetUser?.avatarUrl == null || targetUser!.avatarUrl!.isEmpty)
            ? Text(
                (targetUser?.displayLabel != null &&
                        targetUser!.displayLabel.isNotEmpty)
                    ? targetUser!.displayLabel[0].toUpperCase()
                    : 'J',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.pink.shade600,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSmartAvatar(
    BuildContext context, {
    required User? myUser,
    required User? partnerUser,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PartnerProfileScreen()),
        );
      },
      child: SizedBox(
        width: 68,
        child: Stack(
          alignment: Alignment.centerRight,
          clipBehavior: Clip.none,
          children: [
            Positioned(right: 26, child: _buildBaseAvatar(partnerUser, 18)),
            Positioned(right: 0, child: _buildBaseAvatar(myUser, 18)),
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
    final partner = (authState.couple?.user1Id == user?.id)
        ? authState.couple?.user2
        : authState.couple?.user1;

    DateTime? anniversaryDate;
    if (couple?.anniversaryDate != null) {
      anniversaryDate = DateTime.tryParse(couple!.anniversaryDate!);
    } else {
      anniversaryDate = DateTime(2022, 9, 3);
    }

    final memoriesState = ref.watch(memoriesProvider);
    final displayMonths = _generateDisplayMonths(memoriesState.data);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Kỷ niệm',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildSmartAvatar(
              context,
              myUser: user,
              partnerUser: partner,
            ),
          ),
        ],
      ),
      body: memoriesState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8547A)),
            )
          : memoriesState.error != null
          ? Center(child: Text('Lỗi tải dữ liệu: ${memoriesState.error}'))
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              reverse: true, // Cuộn từ dưới lên
              itemCount: displayMonths.length,
              itemBuilder: (context, index) {
                final monthDate = displayMonths[index];
                final monthKey = DateFormat('yyyy-MM').format(monthDate);
                final Map<int, MemoryDay> monthData =
                    memoriesState.data[monthKey] ?? <int, MemoryDay>{};

                return Column(
                  children: [
                    // 🎯 TRUYỀN THÊM anniversaryDate VÀO ĐÂY
                    _MonthCalendarCard(
                      date: monthDate,
                      data: monthData,
                      anniversaryDate: anniversaryDate,
                    ),
                    if (index > 0) const _GradientConnector(),
                  ],
                );
              },
            ),
    );
  }
}

// ── WIDGET VẼ LỊCH TỪNG THÁNG ──────────────────────────────────────────────────
class _MonthCalendarCard extends ConsumerWidget {
  final DateTime date;
  final Map<int, MemoryDay> data;
  final DateTime? anniversaryDate;

  const _MonthCalendarCard({
    required this.date,
    required this.data,
    this.anniversaryDate,
  });

  String _getAnniversaryCountdown() {
    if (anniversaryDate == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime nextAnni = DateTime(
      today.year,
      anniversaryDate!.month,
      anniversaryDate!.day,
    );
    if (nextAnni.isBefore(today)) {
      nextAnni = DateTime(
        today.year + 1,
        anniversaryDate!.month,
        anniversaryDate!.day,
      );
    }

    int months = nextAnni.month - today.month;
    int days = nextAnni.day - today.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(nextAnni.year, nextAnni.month - 1, 1);
      final daysInPrevMonth = DateUtils.getDaysInMonth(
        prevMonth.year,
        prevMonth.month,
      );
      days += daysInPrevMonth;
    }
    if (months < 0) {
      months += 12;
    }

    if (months == 0 && days == 0) return 'Kỷ niệm hôm nay! 🎉';
    if (months == 0) return 'Còn $days ngày';
    if (days == 0) return 'Còn $months tháng';
    return 'Còn $months tháng $days ngày';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekdayOffset = firstDayOfMonth.weekday - 1;

    // Lấy thêm danh sách ngày đặc biệt (Birthdays, etc.)
    final specialDates = ref.watch(specialDatesProvider).dates;

    final isCurrentMonth =
        date.year == DateTime.now().year && date.month == DateTime.now().month;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tháng ${date.month} ${date.year}',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),

              if (isCurrentMonth && anniversaryDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getAnniversaryCountdown(),
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade400,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
            ),
            itemCount: daysInMonth + firstWeekdayOffset,
            itemBuilder: (ctx, index) {
              if (index < firstWeekdayOffset)
                return const SizedBox(); // Ô trống đầu tháng

              final day =
                  index - firstWeekdayOffset + 1; // 🎯 TÍNH NGÀY CHUẨN XÁC 100%
              final memory = data[day];

              // 🎯 KIỂM TRA XEM NGÀY NÀY CÓ TRÙNG VỚI NGÀY ĐẶC BIỆT KHÔNG
              final matchingSpecialDates = specialDates
                  .where(
                    (sd) => sd.date.month == date.month && sd.date.day == day,
                  )
                  .toList();

              String? displayEmoji = memory?.specialEmoji;
              // Nếu không có emoji từ memory nhưng có sự kiện sinh nhật -> tự động thêm emoji!
              if (displayEmoji == null && matchingSpecialDates.isNotEmpty) {
                final title = matchingSpecialDates.first.title.toLowerCase();
                displayEmoji = title.contains('sinh nhật') ? '🎂' : '🎉';
              }

              final isToday =
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  day == DateTime.now().day;

              // 1. NGÀY CÓ ẢNH
              if (memory?.photoUrl != null) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(memory!.photoUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (displayEmoji != null)
                      Positioned(
                        right: -6,
                        bottom: -6,
                        child: Text(
                          displayEmoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                );
              }

              // 2. NGÀY KỶ NIỆM HOẶC SINH NHẬT (KHÔNG CÓ ẢNH)
              if (displayEmoji != null) {
                return Center(
                  child: Text(
                    displayEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              }

              // 3. NÚT (+) CHO NGÀY HÔM NAY
              if (isToday) {
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                    ref.invalidate(memoriesProvider);
                  },
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE8547A,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE8547A),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFFE8547A),
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              // 4. CÁC NGÀY TRỐNG BÌNH THƯỜNG
              return Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── WIDGET ĐƯỜNG NỐI LIỀN MẠCH CÁC THÁNG ─────────────────────────────────────
class _GradientConnector extends StatelessWidget {
  const _GradientConnector();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.pink.shade100,
            const Color(0xFFE8547A).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
