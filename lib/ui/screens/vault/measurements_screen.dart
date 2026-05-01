// 📁 JAMOCHI_APP/lib/presentation/screens/vault/measurements_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  // TODO: Tích hợp Riverpod để check xem data đã có trên Backend chưa.
  // Hiện tại đang mock mặc định là false (Chưa điền)
  bool _hasData = false; 
  bool _isEditing = false;

  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _shoeSizeCtrl = TextEditingController();
  final TextEditingController _shirtSizeCtrl = TextEditingController();
  final TextEditingController _ringSizeCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Sổ tay số đo',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_hasData || _isEditing)
            TextButton(
              onPressed: () {
                if (_isEditing) {
                  // TODO: Gọi API lưu dữ liệu ở đây
                  setState(() {
                    _isEditing = false;
                    _hasData = true;
                  });
                } else {
                  setState(() => _isEditing = true);
                }
              },
              child: Text(
                _isEditing ? 'Lưu' : 'Sửa',
                style: GoogleFonts.nunito(
                  color: Colors.pink.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
        ],
      ),
      body: !_hasData && !_isEditing 
          ? _buildEmptyCuteState() 
          : _buildMeasurementForm(),
    );
  }

  // 🎀 Giao diện khi Nàng chưa điền số đo
  Widget _buildEmptyCuteState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(
                '👗',
                style: TextStyle(fontSize: 60),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Trống trơn rồi!',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Công chúa chưa điền số đo nè!\nĐiền ngay để người ấy dễ dàng chuẩn bị những món quà bất ngờ nha~ 💕',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              onPressed: () {
                setState(() => _isEditing = true);
              },
              child: Text(
                'Điền số đo ngay',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📝 Form điền thông tin (dùng chung cho View và Edit)
  Widget _buildMeasurementForm() {
    return ListView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionTitle('📏 Kích thước cơ thể'),
        Row(
          children: [
            Expanded(child: _buildTextField('Chiều cao (cm)', _heightCtrl, icon: Icons.height)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Cân nặng (kg)', _weightCtrl, icon: Icons.scale)),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildSectionTitle('👗 Size Quần Áo & Giày'),
        Row(
          children: [
            Expanded(child: _buildTextField('Size Áo', _shirtSizeCtrl, icon: Icons.checkroom)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Size Giày', _shoeSizeCtrl, icon: Icons.snowshoeing)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Size Nhẫn / Vòng tay', _ringSizeCtrl, icon: Icons.radio_button_unchecked),
        
        const SizedBox(height: 24),
        _buildSectionTitle('⚠️ Lưu ý đặc biệt'),
        _buildTextField(
          'Dị ứng thực phẩm, mỹ phẩm, v.v.',
          _notesCtrl,
          icon: Icons.warning_amber_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {required IconData icon, int maxLines = 1}) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.pink.shade300, size: 20),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}