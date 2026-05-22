enum TransactionType { income, expense }

enum TransactionCategory {
  salary,
  freelance,
  investment,
  food,
  transport,
  housing,
  health,
  education,
  entertainment,
  shopping,
  other,
}

extension TransactionTypeExtension on TransactionType {
  String get label => this == TransactionType.income ? 'Receita' : 'Despesa';

  String get value => this == TransactionType.income ? 'income' : 'expense';

  static TransactionType fromValue(String value) =>
      value == 'income' ? TransactionType.income : TransactionType.expense;
}

extension TransactionCategoryExtension on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.salary:
        return 'Salário';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investimento';
      case TransactionCategory.food:
        return 'Alimentação';
      case TransactionCategory.transport:
        return 'Transporte';
      case TransactionCategory.housing:
        return 'Moradia';
      case TransactionCategory.health:
        return 'Saúde';
      case TransactionCategory.education:
        return 'Educação';
      case TransactionCategory.entertainment:
        return 'Lazer';
      case TransactionCategory.shopping:
        return 'Compras';
      case TransactionCategory.other:
        return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case TransactionCategory.salary:
        return '💼';
      case TransactionCategory.freelance:
        return '💻';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.food:
        return '🍽️';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.housing:
        return '🏠';
      case TransactionCategory.health:
        return '🏥';
      case TransactionCategory.education:
        return '📚';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.other:
        return '💰';
    }
  }

  String get value => name;

  static TransactionCategory fromValue(String value) =>
      TransactionCategory.values.firstWhere(
        (c) => c.name == value,
        orElse: () => TransactionCategory.other,
      );
}

class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;
  final String? description;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'type': type.value,
        'category': category.value,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'userId': userId,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'type': type.value,
        'category': category.value,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel(
        id: map['id'] as String,
        userId: (map['user_id'] ?? map['userId']) as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        type: TransactionTypeExtension.fromValue(map['type'] as String),
        category: TransactionCategoryExtension.fromValue(
            map['category'] as String? ?? 'other'),
        description: map['description'] as String?,
        createdAt: DateTime.parse(
            (map['created_at'] ?? map['createdAt']) as String),
      );

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionCategory? category,
    String? description,
    DateTime? createdAt,
  }) =>
      TransactionModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        type: type ?? this.type,
        category: category ?? this.category,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );
}
