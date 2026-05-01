// 📁 JAMOCHI_APP/lib/models/special_date.dart

class SpecialDate {
  final String id;
  final String title;
  final DateTime date;

  SpecialDate({required this.id, required this.title, required this.date});

  factory SpecialDate.fromJson(Map<String, dynamic> json) {
    final dateString = json['target_date']?.toString() ?? json['date']?.toString();
    
    return SpecialDate(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Sự kiện',
      date: DateTime.tryParse(dateString ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  int get remainDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime thisYearDate = DateTime(now.year, date.month, date.day);

    if (thisYearDate.isBefore(today)) {
      DateTime nextYearDate = DateTime(now.year + 1, date.month, date.day);
      return nextYearDate.difference(today).inDays;
    }

    return thisYearDate.difference(today).inDays;
  }

  bool get isPast =>
      false;

  String get formattedDate =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}
