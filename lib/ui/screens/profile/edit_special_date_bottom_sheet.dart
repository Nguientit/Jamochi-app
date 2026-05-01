import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditSpecialDateBottomSheet extends StatefulWidget {
  final String? initialTitle;
  final DateTime? initialDate;
  final bool isMainAnniversary; // Đánh dấu nếu đây là sửa ngày "Đã bên nhau"
  final Function(String title, DateTime date) onSave;

  const EditSpecialDateBottomSheet({
    super.key,
    this.initialTitle,
    this.initialDate,
    this.isMainAnniversary = false,
    required this.onSave,
  });

  // Hàm tiện ích để gọi Bottom Sheet từ bất kỳ đâu
  static void show(
    BuildContext context, {
    String? initialTitle,
    DateTime? initialDate,
    bool isMainAnniversary = false,
    required Function(String, DateTime) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditSpecialDateBottomSheet(
        initialTitle: initialTitle,
        initialDate: initialDate,
        isMainAnniversary: isMainAnniversary,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditSpecialDateBottomSheet> createState() => _EditSpecialDateBottomSheetState();
}

class _EditSpecialDateBottomSheetState extends State<EditSpecialDateBottomSheet> {
  late TextEditingController _titleController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.pinkAccent,
              surface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Xử lý để bottom sheet trượt lên khi có bàn phím
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: AppBar().preferredSize.height), // Cách status bar
      padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: bottomPadding + 24),
      decoration: const BoxDecoration(
        color: Colors.black, // Nền đen theo design
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh gạt nhỏ ở giữa
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            
            Text(
              widget.initialTitle == null ? 'Thêm ngày kỷ niệm' : 'Sửa ngày kỷ niệm',
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Tên ngày kỷ niệm
            Text('Tên ngày kỷ niệm', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: !widget.isMainAnniversary, // Nếu là "Đã bên nhau" thì không cho sửa tên
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Vui lòng nhập tên',
                hintStyle: GoogleFonts.nunito(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF1E1E1E), // Xám đen
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Ngày kỷ niệm
            Text('Ngày kỷ niệm', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'Chọn ngày',
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 40),

            // Nút Lưu
            GestureDetector(
              onTap: () {
                final title = widget.isMainAnniversary ? 'Đã bên nhau' : _titleController.text.trim();
                if (title.isNotEmpty && _selectedDate != null) {
                  widget.onSave(title, _selectedDate!);
                  Navigator.pop(context); // Đóng bottom sheet
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB588FF), Color(0xFF7FFFFF)], // Dải màu từ tím sang cyan
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Lưu',
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}