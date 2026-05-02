import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class EditNicknameSheet extends StatefulWidget {
  final String currentName;
  final String target; // 'Bạn' hoặc 'Người ấy'
  final Function(String) onSave;

  const EditNicknameSheet({
    super.key,
    required this.currentName,
    required this.target,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required String currentName,
    required String target,
    required Function(String) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditNicknameSheet(
        currentName: currentName,
        target: target,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditNicknameSheet> createState() => _EditNicknameSheetState();
}

class _EditNicknameSheetState extends State<EditNicknameSheet> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy padding bottom của bàn phím để đẩy BottomSheet lên khi gõ
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo ngang nhỏ ở trên cùng
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Đổi biệt danh',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đặt một cái tên thật kêu cho ${widget.target} nhé 💕',
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 32),

          // Ô nhập liệu
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập biệt danh...',
              filled: true,
              fillColor: Colors.pink.shade50.withValues(alpha: 0.5),
              prefixIcon: Icon(Icons.edit_rounded, color: Colors.pink.shade300),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const SizedBox(height: 32),

          // Nút Lưu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final newName = _nameCtrl.text.trim();
                if (newName.isNotEmpty) {
                  widget.onSave(newName);
                  Navigator.pop(context); // Đóng sheet
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8547A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                'Lưu thay đổi',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}