import '../core/api_client.dart';
import '../models/transaction.dart';

class TransactionService {
  Future<List<Transaction>> getTransactions({String? type}) async {
    final res = await ApiClient.instance.dio.get('/transactions', queryParameters: {
      if (type != null && type != 'all') 'type': type,
    });
    return (res.data as List).map((e) => Transaction.fromJson(e)).toList();
  }

  Future<Transaction> create({
    required int? categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final res = await ApiClient.instance.dio.post('/transactions', data: {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
      'description': description,
    });
    return Transaction.fromJson(res.data);
  }

  Future<Transaction> update(
    int id, {
    required int? categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final res = await ApiClient.instance.dio.put('/transactions/$id', data: {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
      'description': description,
    });
    return Transaction.fromJson(res.data);
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.dio.delete('/transactions/$id');
  }
}
