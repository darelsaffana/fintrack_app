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
    final provider = context.watch<AppProvider>(); // Logika asli dipertahankan

    if (provider.transactions.isEmpty) {
      return const EmptyState(message: 'Belum ada data untuk ditampilkan. Tambahkan transaksi terlebih dahulu.'); // Logika asli dipertahankan
    }

    return SingleChildScrollView(
      // Memberikan padding halaman agar senada dengan halaman Dashboard & Kategori yang luas
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul Halaman yang Modern
          Text(
            'Analisis Laporan',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720; // Logika asli dipertahankan
            final categoryCard = _CategoryReportCard(items: provider.categoryReport); // Logika asli dipertahankan
            final monthCard = _MonthReportCard(items: provider.monthReport); // Logika asli dipertahankan

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: categoryCard),
                  const SizedBox(width: 20), // Jarak horizontal diperlebar sedikit agar tidak rapat
                  Expanded(child: monthCard),
                ],
              );
            }
            return Column(children: [
              categoryCard, 
              const SizedBox(height: 20), // Jarak vertikal disesuaikan
              monthCard
            ]);
          }),
        ],
      ),
    );
  }
}

class _CategoryReportCard extends StatelessWidget {
  final List<CategoryReportItem> items;
  const _CategoryReportCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (s, e) => s + e.total); // Logika asli dipertahankan

    return Container(
      padding: const EdgeInsets.all(22), // Padding di dalam kartu diperlebar agar lapang
      decoration: BoxDecoration(
        color: AppColors.card, 
        borderRadius: BorderRadius.circular(24), // Sudut melengkung 24 yang modern
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)), // Border diperhalus
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gaya teks judul chart diperjelas dan lebih bold
          Text(
            'Pengeluaran per Kategori', 
            style: TextStyle(
              color: AppColors.muted, 
              fontWeight: FontWeight.w800, 
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Belum ada pengeluaran.', style: TextStyle(color: AppColors.mutedDim, fontSize: 13))),
            )
          else ...[
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(
                sectionsSpace: 4, // Jarak antar potongan pie chart direnggangkan sedikit agar lebih estetik
                centerSpaceRadius: 52, // Area tengah dibuat sedikit lebih besar untuk tampilan donut chart yang minimalis
                sections: [
                  for (final e in items)
                    PieChartSectionData(
                      value: e.total, // Logika asli dipertahankan
                      color: hexToColor(e.color), // Logika asli dipertahankan[cite: 3]
                      showTitle: false,
                      radius: 32, // Ukuran ketebalan donat dikurangi sedikit agar terkesan modern dan tipis
                    ),
                ],
              )),
            ),
            const SizedBox(height: 20),
            
            // List Kategori di bawah chart
            for (final e in (items..sort((a, b) => b.total.compareTo(a.total)))) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6), // Spasi vertikal diperbesar sedikit
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Lingkaran warna dengan efek pendar halus (glow)
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: hexToColor(e.color).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: hexToColor(e.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          e.name, // Logika asli dipertahankan[cite: 3]
                          style: TextStyle(
                            color: AppColors.text, 
                            fontSize: 13, 
                            fontWeight: FontWeight.w600, // Diubah ke semi-bold
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${formatRupiah(e.total)} · ${total > 0 ? ((e.total / total) * 100).round() : 0}%', // Logika asli dipertahankan[cite: 3]
                      style: TextStyle(
                        color: AppColors.muted, 
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold, // Ditebalkan agar angka persentase mudah dibaca
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    final maxVal = items.fold<double>(1, (m, e) => [m, e.income, e.expense].reduce((a, b) => a > b ? a : b)); // Logika asli dipertahankan[cite: 3]

    return Container(
      padding: const EdgeInsets.all(22), // Padding di dalam kartu disamakan (22)
      decoration: BoxDecoration(
        color: AppColors.card, 
        borderRadius: BorderRadius.circular(24), // Sudut melengkung 24
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pemasukan vs Pengeluaran', 
            style: TextStyle(
              color: AppColors.muted, 
              fontWeight: FontWeight.w800, // Diubah menjadi lebih tebal
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Laporan perbandingan dalam 6 bulan terakhir',
            style: TextStyle(
              color: AppColors.mutedDim,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Belum ada data bulanan.', style: TextStyle(color: AppColors.mutedDim, fontSize: 13))),
            )
          else
            SizedBox(
              height: 220, // Ketinggian disesuaikan agar seimbang dengan donat chart di sebelahnya
              child: BarChart(BarChartData(
                maxY: maxVal * 1.15, // Logika asli dipertahankan[cite: 3]
                gridData: const FlGridData(drawVerticalLine: false, horizontalInterval: null), // Logika asli dipertahankan[cite: 3]
                borderData: FlBorderData(show: false), // Logika asli dipertahankan[cite: 3]
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Logika asli dipertahankan[cite: 3]
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Logika asli dipertahankan[cite: 3]
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Logika asli dipertahankan[cite: 3]
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt(); // Logika asli dipertahankan[cite: 3]
                        if (i < 0 || i >= items.length) return const SizedBox.shrink(); // Logika asli dipertahankan[cite: 3]
                        final month = items[i].month; // Logika asli dipertahankan[cite: 3]
                        final parts = month.split('-'); // Logika asli dipertahankan[cite: 3]
                        const names = ['', 'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
                        final label = '${names[int.parse(parts[1])]} ${parts[0].substring(2)}'; // Logika asli dipertahankan[cite: 3]
                        return Padding(
                          padding: const EdgeInsets.only(top: 8), 
                          child: Text(
                            label, 
                            style: TextStyle(
                              color: AppColors.muted, 
                              fontSize: 10,
                              fontWeight: FontWeight.bold, // Teks bulan sedikit ditebalkan agar lebih bersih terbaca
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < items.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      // Mengubah bentuk batang (BarRod) menjadi bulat melengkung penuh (BorderRadius 8)
                      BarChartRodData(
                        toY: items[i].income, 
                        color: AppColors.income, 
                        width: 10, // Dilebarkan dari 8 ke 10 agar terlihat kokoh dan estetik
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      BarChartRodData(
                        toY: items[i].expense, 
                        color: AppColors.expense, 
                        width: 10, // Dilebarkan dari 8 ke 10
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                    ], barsSpace: 6), // Spasi antar batang dilebarkan dari 4 ke 6
                ],
              )),
            ),
          const SizedBox(height: 24),
          
          // Bagian legenda diubah menjadi container baris yang sangat cantik
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(color: AppColors.income, label: 'Pemasukan'),
              SizedBox(width: 24), // Jarak antar legenda diperlebar agar seimbang
              _LegendDot(color: AppColors.expense, label: 'Pengeluaran'),
            ],
          ),
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
    return Row(
      mainAxisSize: MainAxisSize.min, 
      children: [
        // Indikator bulat dengan lingkaran dalam & luar agar senada
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label, 
          style: TextStyle(
            color: AppColors.text, // Menggunakan warna teks utama agar lebih terbaca
            fontSize: 12, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}