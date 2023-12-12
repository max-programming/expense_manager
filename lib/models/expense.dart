class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final DateTime? dueDate;
  final String category;
  final double? latitude;
  final double? longitude;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.latitude,
    this.longitude,
    this.dueDate,
  });
}
