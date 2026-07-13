import '../core/api_client.dart';

class CategoryReportItem {
  final String name;
  final String color;
  final double total;
  CategoryReportItem({required this.name, required this.color, required this.total});

  factory CategoryReportItem.fromJson(Map<String, dynamic> json) => CategoryReportItem(
        name: json['name'] ?? 'Lainnya',
        color: json['color'] ?? '#7D8AA8',
        total: double.tryParse(json['total'].toString()) ?? 0,
      );
}

class MonthReportItem {
  final String month;
  final double income;
  final double expense;
  MonthReportItem({required this.month, required this.income, required this.expense});

  factory MonthReportItem.fromJson(Map<String, dynamic> json) => MonthReportItem(
        month: json['month'],
        income: double.tryParse(json['income'].toString()) ?? 0,
        expense: double.tryParse(json['expense'].toString()) ?? 0,
      );
}

class ReportService {
  Future<List<CategoryReportItem>> byCategory() async {
    final res = await ApiClient.instance.dio.get('/reports/by-category');
    return (res.data as List).map((e) => CategoryReportItem.fromJson(e)).toList();
  }

  Future<List<MonthReportItem>> byMonth({int months = 6}) async {
    final res = await ApiClient.instance.dio.get('/reports/by-month', queryParameters: {'months': months});
    return (res.data as List).map((e) => MonthReportItem.fromJson(e)).toList();
  }
}
