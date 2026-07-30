class BudgetModel {
  final double monthlyLimit;
  final Map<String, double> categoryLimits;

  BudgetModel({
    required this.monthlyLimit,
    required this.categoryLimits,
  });

  Map<String, dynamic> toJson() {
    return {
      'monthlyLimit': monthlyLimit,
      'categoryLimits': categoryLimits,
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 25000.0,
      categoryLimits: (json['categoryLimits'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {
            'food': 8000.0,
            'groceries': 6000.0,
            'shopping': 5000.0,
            'transport': 3000.0,
            'bills': 4000.0,
          },
    );
  }

  static BudgetModel defaultBudget() {
    return BudgetModel(
      monthlyLimit: 25000.0,
      categoryLimits: {
        'food': 8000.0,
        'groceries': 6000.0,
        'shopping': 5000.0,
        'transport': 3000.0,
        'bills': 4000.0,
      },
    );
  }
}
