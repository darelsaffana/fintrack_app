import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/category_service.dart';
import '../services/dashboard_service.dart';
import '../services/report_service.dart';
import '../services/transaction_service.dart';

/// Holds all app data (categories, transactions, dashboard summary, reports)
/// and talks to the Laravel API through the *_service classes.
class AppProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final TransactionService _transactionService = TransactionService();
  final DashboardService _dashboardService = DashboardService();
  final ReportService _reportService = ReportService();

  bool loading = false;

  List<Category> categories = [];
  List<Transaction> transactions = [];
  DashboardSummary? summary;
  List<CategoryReportItem> categoryReport = [];
  List<MonthReportItem> monthReport = [];

  List<Category> get incomeCategories => categories.where((c) => c.type == 'income').toList();
  List<Category> get expenseCategories => categories.where((c) => c.type == 'expense').toList();

  void reset() {
    categories = [];
    transactions = [];
    summary = null;
    categoryReport = [];
    monthReport = [];
    notifyListeners();
  }

  Future<void> loadAll() async {
    loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _categoryService.getCategories(),
        _transactionService.getTransactions(),
        _dashboardService.getSummary(),
        _reportService.byCategory(),
        _reportService.byMonth(),
      ]);
      categories = results[0] as List<Category>;
      transactions = results[1] as List<Transaction>;
      summary = results[2] as DashboardSummary;
      categoryReport = results[3] as List<CategoryReportItem>;
      monthReport = results[4] as List<MonthReportItem>;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboardAndReports() async {
    summary = await _dashboardService.getSummary();
    categoryReport = await _reportService.byCategory();
    monthReport = await _reportService.byMonth();
    notifyListeners();
  }

  // ---- Transactions ----
  Future<void> loadTransactions({String? type}) async {
    transactions = await _transactionService.getTransactions(type: type);
    notifyListeners();
  }

  Future<void> addTransaction({
    required int? categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    await _transactionService.create(
      categoryId: categoryId, type: type, amount: amount, date: date, description: description,
    );
    await loadTransactions();
    await refreshDashboardAndReports();
  }

  Future<void> editTransaction(
    int id, {
    required int? categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    await _transactionService.update(
      id, categoryId: categoryId, type: type, amount: amount, date: date, description: description,
    );
    await loadTransactions();
    await refreshDashboardAndReports();
  }

  Future<void> deleteTransaction(int id) async {
    await _transactionService.delete(id);
    await loadTransactions();
    await refreshDashboardAndReports();
  }

  // ---- Categories ----
  Future<void> loadCategories() async {
    categories = await _categoryService.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(String name, String type, String color) async {
    await _categoryService.create(name, type, color);
    await loadCategories();
  }

  Future<void> editCategory(int id, String name, String type, String color) async {
    await _categoryService.update(id, name, type, color);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _categoryService.delete(id);
    await loadCategories();
  }
}
