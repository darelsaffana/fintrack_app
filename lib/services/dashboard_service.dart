import '../core/api_client.dart';
import '../models/transaction.dart';

class DashboardSummary {
  final double income;
  final double expense;
  final double balance;
  final List<Transaction> recentTransactions;
  final List<double> saldoHistory;

  DashboardSummary({
    required this.income,
    required this.expense,
    required this.balance,
    required this.recentTransactions,
    required this.saldoHistory,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
        income: double.tryParse(json['income'].toString()) ?? 0,
        expense: double.tryParse(json['expense'].toString()) ?? 0,
        balance: double.tryParse(json['balance'].toString()) ?? 0,
        recentTransactions: (json['recent_transactions'] as List)
            .map((e) => Transaction.fromJson(e))
            .toList(),
        saldoHistory: (json['saldo_history'] as List)
            .map((e) => double.tryParse(e.toString()) ?? 0)
            .toList(),
      );
}

class DashboardService {
  Future<DashboardSummary> getSummary() async {
    final res = await ApiClient.instance.dio.get('/dashboard');
    return DashboardSummary.fromJson(res.data);
  }
}
