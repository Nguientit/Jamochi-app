import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vault Bí Mật')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildVaultCard('🩸', 'Chu kỳ kinh nguyệt', 'Dự đoán ngày tới, nhắc nhở quan tâm'),
          _buildVaultCard('📏', 'Sổ tay số đo', 'Chiều cao, cân nặng, size giày, dị ứng'),
          _buildVaultCard('🎉', 'Ngày kỷ niệm', 'Đếm ngược đến sinh nhật, ngày quen nhau'),
        ],
      ),
    );
  }

  Widget _buildVaultCard(String emoji, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Text(emoji, style: const TextStyle(fontSize: 32)),
        title: Text(title, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: GoogleFonts.nunito(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}