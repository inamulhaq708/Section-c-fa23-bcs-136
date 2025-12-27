class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // income | expense
  final String category;
  final String date;
  final String note;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
  });

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'note': note,
    };
  }

  // ================= FROM MAP =================
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] ?? 'expense',
      category: map['category'] ?? 'Other',
      date: map['date'] ?? '',
      note: map['note'] ?? '',
    );
  }
}
