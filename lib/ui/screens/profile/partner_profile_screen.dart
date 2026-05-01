import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../models/user.dart';

class PartnerProfileScreen extends ConsumerWidget {
  const PartnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 Lấy dữ liệu từ Provider
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final couple = authState.couple;

    User? partner;
    if (couple != null && user != null) {
      if (couple.user1Id == user.id) {
        partner = couple.user2; // Mình là user1 thì partner là user2
      } else if (couple.user2Id == user.id) {
        partner = couple.user1; // Mình là user2 thì partner là user1
      }
    }

    int daysTogether = 0;
    if (couple?.anniversaryDate != null) {
      final start = DateTime.tryParse(couple!.anniversaryDate!);
      if (start != null) {
        daysTogether = DateTime.now().difference(start).inDays;
      }
    }

    // Nếu lỡ không tìm thấy partner, hiện thông báo mượt mà
    if (partner == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: AppColors.textDark),
        ),
        body: Center(
          child: Text(
            'Chưa có thông tin người ấy',
            style: GoogleFonts.nunito(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Màu nền xám nhạt làm nổi bật các thẻ trắng
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          'Hồ sơ của ${partner.displayLabel}',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── 1. AVATAR LỚN VÀ TÊN ───────────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.pink.shade100,
                    backgroundImage:
                        (partner.avatarUrl != null &&
                            partner.avatarUrl!.isNotEmpty)
                        ? NetworkImage(partner.avatarUrl!)
                        : null,
                    child:
                        (partner.avatarUrl == null ||
                            partner.avatarUrl!.isEmpty)
                        ? Text(
                            (partner.displayLabel.isNotEmpty)
                                ? partner.displayLabel[0].toUpperCase()
                                : 'P',
                            style: GoogleFonts.nunito(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.pink.shade600,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                partner.displayLabel,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 32),

              // ── 2. THÔNG TIN CÁ NHÂN (UI giống Settings) ───────────────────
              _buildInfoGroup(
                title: 'THÔNG TIN CÁ NHÂN',
                children: [
                  _buildInfoRow(
                    icon: Icons.badge_rounded,
                    iconColor: Colors.blue.shade400,
                    label: 'Biệt danh',
                    value: partner.displayLabel,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                  ),
                  _buildInfoRow(
                    icon: Icons.transgender_rounded,
                    iconColor: Colors.purple.shade400,
                    label: 'Giới tính',
                    value: _getGenderString(
                      partner,
                    ), // Cần đảm bảo Model User có thuộc tính gender
                  ),
                  // Mở rộng thêm nếu User của bạn có ngày sinh (dateOfBirth)
                  // const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                  // _buildInfoRow(
                  //   icon: Icons.cake_rounded,
                  //   iconColor: Colors.orange.shade400,
                  //   label: 'Ngày sinh',
                  //   value: partner.dateOfBirth ?? 'Chưa cập nhật',
                  // ),
                ],
              ),
              const SizedBox(height: 24),

              // ── 3. THÔNG TIN KỶ NIỆM VỚI BẠN ───────────────────────────────
              _buildInfoGroup(
                title: 'TÌNH TRẠNG',
                children: [
                  _buildInfoRow(
                    icon: Icons.favorite_rounded,
                    iconColor: Colors.red.shade400,
                    label: 'Đang hẹn hò với',
                    value: user?.displayLabel ?? 'Bạn',
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                  ),
                  _buildInfoRow(
                    icon: Icons.calendar_month_rounded,
                    iconColor: Colors.green.shade400,
                    label: 'Ngày bắt đầu',
                    value: _formatDateStr(couple?.anniversaryDate),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                  ),
                  _buildInfoRow(
                    icon: Icons.timelapse_rounded,
                    iconColor: Colors.pink.shade400,
                    label: 'Bên nhau',
                    value: '$daysTogether ngày',
                    valueColor: Colors.pink.shade600,
                    isBoldValue: true,
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Các hàm Helper để vẽ Giao diện ──

  // Hàm vẽ khung chứa các mục thông tin (Bo góc tròn trắng)
  Widget _buildInfoGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Hàm vẽ từng dòng thông tin
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Chuyển đổi định dạng ngày
  String _formatDateStr(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Chưa cập nhật';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Lấy giới tính (Giả sử model User của bạn có field "gender")
  String _getGenderString(User user) {
    // Tùy theo cách bạn lưu data (ví dụ: 'male', 'female') trong User model
    // Dưới đây là code dự phòng, nếu model của bạn chưa có gender, hãy sửa lại.
    try {
      final dynamic u = user; // Hack nhỏ nếu model chưa định nghĩa getter
      if (u.gender == 'male') return 'Nam';
      if (u.gender == 'female') return 'Nữ';
      return 'Khác';
    } catch (e) {
      return 'Chưa cập nhật';
    }
  }
}
