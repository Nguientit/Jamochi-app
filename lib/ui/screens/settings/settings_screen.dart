import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../profile/anniversary_list_screen.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Xác nhận đăng xuất',
            style: GoogleFonts.nunito(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi Jamochi không?',
            style: GoogleFonts.nunito(
              color: AppColors.textMedium,
              fontSize: 15,
            ),
          ),
          actions: [
            // Nút Hủy
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Hủy',
                style: GoogleFonts.nunito(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Nút Đăng xuất
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                // 1. Đóng modal xác nhận
                Navigator.of(dialogContext).pop();

                // 2. Gọi hàm logout từ authProvider
                await ref.read(authProvider.notifier).logout();

                // 3. Chuyển hướng về trang Login và xóa sạch stack màn hình cũ
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) =>
                        false, // false = xóa toàn bộ lịch sử
                  );
                }
              },
              child: Text(
                'Đăng xuất',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy thông tin user hiện tại
    final user = ref.watch(authProvider).user;
    final couple = ref.watch(authProvider).couple;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Màu nền xám/trắng siêu nhạt (Light Mode)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tùy chỉnh',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Center(
              child: Hero(
                tag: 'user_avatar_setting',
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.pink.shade100,
                    // Nếu có link thật thì dùng ảnh
                    backgroundImage:
                        (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    // Nếu KHÔNG có ảnh thì lấy chữ cái đầu của Tên
                    child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                        ? Text(
                            (user?.displayLabel.isNotEmpty == true)
                                ? user!.displayLabel[0].toUpperCase()
                                : 'J',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.pink.shade400,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayLabel ?? 'Jaman',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              user?.email ?? 'email@jamochi.app',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 32),

            // 🎯 NHÓM 1: TÀI KHOẢN & NGƯỜI ẤY
            _buildSection(
              title: 'Cặp đôi của tôi',
              children: [
                _buildTile(
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFE8547A),
                  title: 'Người ấy',
                  subtitle: couple != null ? 'Đã kết nối' : 'Chưa kết nối',
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.edit_rounded,
                  iconColor: Colors.orange.shade400,
                  title: 'Đổi Biệt danh',
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.calendar_month_rounded,
                  iconColor: Colors.pink.shade400,
                  title: 'Ngày kỷ niệm',
                  onTap: () {
                    // 🎯 Nhấn vào sẽ bay sang màn hình Ngày Kỷ Niệm
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnniversaryListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🎯 NHÓM 2: GIAO DIỆN & TRẢI NGHIỆM (Tính năng App)
            _buildSection(
              title: 'Trải nghiệm Jamochi',
              children: [
                _buildTile(
                  icon: Icons.music_note_rounded,
                  iconColor: Colors.purple.shade400,
                  title: 'Nhạc nền khi mở app',
                  trailing: _buildSwitch(true),
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.notifications_active_rounded,
                  iconColor: Colors.green.shade400,
                  title: 'Thông báo Ting Ting',
                  trailing: _buildSwitch(true),
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.smart_toy_rounded,
                  iconColor: Colors.teal.shade400,
                  title: 'Cài đặt Mochi AI',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🎯 NHÓM 3: KHÁC
            _buildSection(
              title: 'Hệ thống',
              children: [
                _buildTile(
                  icon: Icons.security_rounded,
                  iconColor: Colors.grey.shade600,
                  title: 'Bảo mật & Mật khẩu',
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.logout_rounded,
                  iconColor: Colors.red.shade400,
                  title: 'Đăng xuất',
                  textColor: Colors.red.shade600,
                  hideArrow: true,
                  onTap: () {
                    _showLogoutDialog(context, ref);
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Version App
            Center(
              child: Text(
                'Jamochi v1.0.0\nMade with ❤️ for Jaman',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Khung tiêu đề
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // Khung chứa các lựa chọn (Card trắng đổ bóng mờ)
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        _buildSectionTitle(title),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Từng lựa chọn (Tile)
  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? textColor,
    Widget? trailing,
    bool hideArrow = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textColor ?? AppColors.textDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            )
          : null,
      trailing:
          trailing ??
          (hideArrow
              ? null
              : const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 14,
                )),
      onTap: onTap ?? () {},
    );
  }

  // Dòng gạch mờ phân cách
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 20),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  // Nút Switch Bật/Tắt dễ thương
  Widget _buildSwitch(bool value) {
    return Switch(
      value: value,
      onChanged: (v) {},
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFFE8547A), // Màu hồng chủ đạo
      inactiveTrackColor: Colors.grey.shade200,
    );
  }
}
