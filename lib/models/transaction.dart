import 'category.dart';

class Transaction {
  final int id;
  final int? categoryId;
  final Category? category;
  final String type; // 'income' | 'expense'
  final double amount;
  final DateTime date;
  final String? description;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.category,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        categoryId: json['category_id'],
        category: json['category'] != null ? Category.fromJson(json['category']) : null,
        type: json['type'] ?? 'expense',
        amount: double.tryParse(json['amount'].toString()) ?? 0,
        date: DateTime.parse(json['date']),
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'type': type,
        'amount': amount,
        'date': date.toIso8601String().split('T').first,
        'description': description,
      };
}
