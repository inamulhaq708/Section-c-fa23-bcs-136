class GoalModel {
  final int? id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String targetDate;

  GoalModel({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'target_date': targetDate,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      title: map['title'],
      targetAmount: map['target_amount'],
      savedAmount: map['saved_amount'],
      targetDate: map['target_date'],
    );
  }
}
