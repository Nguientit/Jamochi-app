// 📁 JAMOCHI_APP/lib/presentation/screens/vault/vault_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../profile/anniversary_list_screen.dart';
import 'measurements_screen.dart'; 
import '../../../data/providers/auth_provider.dart';
import '../settings/settings_screen.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Két sắt Bí Mật',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              child: Hero(
                tag: 'user_avatar_setting',
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.pink.shade100,
                    backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                        ? Text(
                            (user?.displayLabel.isNotEmpty == true) ? user!.displayLabel[0].toUpperCase() : 'J',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.pink.shade600,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Chu kỳ kinh nguyệt
          _buildVaultCard(
            context,
            title: 'Chu kỳ kinh nguyệt',
            subtitle: 'Dự đoán ngày tới, nhắc nhở quan tâm',
            icon: Icons.water_drop_rounded,
            iconBgColor: Colors.red.shade100,
            iconColor: Colors.red.shade600,
            onTap: () {
              // TODO: Điều hướng đến trang Chu kỳ kinh nguyệt
            },
          ),
          
          const SizedBox(height: 16),

          // 2. Sổ tay số đo
          _buildVaultCard(
            context,
            title: 'Sổ tay số đo',
            subtitle: 'Chiều cao, cân nặng, size giày, dị ứng',
            icon: Icons.straighten_rounded,
            iconBgColor: Colors.blue.shade100,
            iconColor: Colors.blue.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeasurementsScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // 3. Ngày kỷ niệm
          _buildVaultCard(
            context,
            title: 'Ngày kỷ niệm',
            subtitle: 'Đếm ngược đến sinh nhật, ngày quen nhau',
            icon: Icons.celebration_rounded,
            iconBgColor: Colors.orange.shade100,
            iconColor: Colors.orange.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnniversaryListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVaultCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon hình tròn
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Mũi tên
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 16),
          ],
        ),
      ),
    );
  }
}