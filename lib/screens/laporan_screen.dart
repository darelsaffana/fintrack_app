import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../services/report_service.dart';
import '../widgets/empty_state.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.transactions.isEmpty) {
      return const EmptyState(message: 'Belum ada data untuk ditampilkan. Tambahkan transaksi terlebih dahulu.');
    }

    return SingleChildScrollView(
      child: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final categoryCard = _CategoryReportCard(items: provider.categoryReport);
        final monthCard = _MonthReportCard(items: provider.monthReport);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: categoryCard),
              const SizedBox(width: 16),
              Expanded(child: monthCard),
            ],
          );
        }
        return Column(children: [categoryCard, const SizedBox(height: 16), monthCard]);
      }),
    );
  }
}

class _CategoryReportCard extends StatelessWidget {
  final List<CategoryReportItem> items;
  const _CategoryReportCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (s, e) => s + e.total);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengeluaran per Kategori', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: Text('Belum ada pengeluaran.', style: TextStyle(color: AppColors.mutedDim, fontSize: 13))),
            )
          else ...[
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 46,
                sections: [
                  for (final e in items)
                    PieChartSectionData(
                      value: e.total,
                      color: hexToColor(e.color),
                      showTitle: false,
                      radius: 40,
                    ),
                ],
              )),
            ),
            const SizedBox(height: 14),
            for (final e in (items..sort((a, b) => b.total.compareTo(a.total))))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: hexToColor(e.color), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(e.name, style: const TextStyle(color: AppColors.text, fontSize: 12.5)),
                    ]),
                    Text(
                      '${formatRupiah(e.total)} · ${total > 0 ? ((e.total / total) * 100).round() : 0}%',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MonthReportCard extends StatelessWidget {
  final List<MonthReportItem> items;
  const _MonthReportCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final maxVal = items.fold<double>(1, (m, e) => [m, e.income, e.expense].reduce((a, b) => a > b ? a : b));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pemasukan vs Pengeluaran (6 Bulan Terakhir)', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: Text('Belum ada data bulanan.', style: TextStyle(color: AppColors.mutedDim, fontSize: 13))),
            )
          else
            SizedBox(
              height: 240,
              child: BarChart(BarChartData(
                maxY: maxVal * 1.15,
                gridData: const FlGridData(drawVerticalLine: false, horizontalInterval: null),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= items.length) return const SizedBox.shrink();
                        final month = items[i].month; // "YYYY-MM"
                        final parts = month.split('-');
                        const names = ['', 'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
                        final label = '${names[int.parse(parts[1])]} ${parts[0].substring(2)}';
                        return Padding(padding: const EdgeInsets.only(top: 6), child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)));
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < items.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: items[i].income, color: AppColors.income, width: 8, borderRadius: BorderRadius.circular(3)),
                      BarChartRodData(toY: items[i].expense, color: AppColors.expense, width: 8, borderRadius: BorderRadius.circular(3)),
                    ], barsSpace: 4),
                ],
              )),
            ),
          const SizedBox(height: 10),
          Row(children: const [
            _LegendDot(color: AppColors.income, label: 'Pemasukan'),
            SizedBox(width: 16),
            _LegendDot(color: AppColors.expense, label: 'Pengeluaran'),
          ]),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
    ]);
  }
}
