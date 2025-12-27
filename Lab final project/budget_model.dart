class BudgetModel {
  final int? id;
  final String category;
  final double limitAmount;
  final String month; // yyyy-MM

  BudgetModel({
    this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limit_amount': limitAmount,
      'month': month,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      limitAmount: map['limit_amount'],
      month: map['month'],
    );
  }
}
