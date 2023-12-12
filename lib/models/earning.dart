class Earning {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final double? latitude;
  final double? longitude;

  Earning({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.latitude,
    this.longitude,
  });
}
