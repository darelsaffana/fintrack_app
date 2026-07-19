import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>(); // Logika asli dipertahankan[cite: 4]
    final summary = provider.summary; // Logika asli dipertahankan[cite: 4]

    return RefreshIndicator(
      onRefresh: () => provider.loadAll(), // Logika asli dipertahankan[cite: 4]
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Logika asli dipertahankan[cite: 4]
        // Menambahkan padding luar (24) agar layout halaman terasa lebih bernapas dan modern
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560; // Logika asli dipertahankan[cite: 4]
              final cards = [
                SummaryCard(label: 'PEMASUKAN', value: summary?.income ?? 0, color: AppColors.income, icon: Icons.arrow_upward_rounded), // Logika asli[cite: 4]
                SummaryCard(label: 'PENGELUARAN', value: summary?.expense ?? 0, color: AppColors.expense, icon: Icons.arrow_downward_rounded), // Logika asli[cite: 4]
                SummaryCard(label: 'SALDO', value: summary?.balance ?? 0, color: AppColors.balance, icon: Icons.account_balance_wallet_rounded), // Logika asli[cite: 4]
              ];
              
              if (isNarrow) {
                // Menambahkan jarak vertikal antarkartu yang lebih modern (16)
                return Column(
                  children: [
                    for (final c in cards) 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16), 
                        child: c,
                      )
                  ],
                );
              }
              return Row(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    // Jarak horizontal antarkartu dilebarkan sedikit agar lebih proporsional
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }),
            // Menambah white space/jarak vertikal agar tidak berdempetan
            const SizedBox(height: 32),
            
            // Mengubah style teks judul "Transaksi Terakhir" menjadi lebih bold, sedikit besar, dan modern
            Text(
              'Transaksi Terakhir', 
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6) ?? AppColors.muted, 
                fontWeight: FontWeight.w800, // Lebih tebal
                fontSize: 15, // Sedikit dinaikkan ukurannya agar tegas
                letterSpacing: 0.5, // Menambahkan jarak antarhuruf ala UI modern
              )
            ),
            const SizedBox(height: 16), // Jarak ke list di bawahnya diperluas
            
            if (summary == null || summary.recentTransactions.isEmpty)
              const EmptyState(message: 'Belum ada transaksi. Mulai catat keuanganmu!') // Logika asli dipertahankan[cite: 4]
            else
              // Mengubah kontainer pembungkus daftar transaksi menjadi lebih lembut & elegan
              Container(
                decoration: BoxDecoration(
                  // ================= INI YANG GUA UBAH BIAR DINAMIS =================
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(24), // Sudut melengkung diubah dari 16 ke 24 agar terlihat halus[cite: 4]
                  border: Border.all(
                    color: Theme.of(context).dividerColor, // Mengikuti border tema aktif
                    width: 1,
                  ),
                  // =================================================================
                  // Menambahkan bayangan (shadow) halus yang memberikan efek kedalaman (depth) modern
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final t in summary.recentTransactions) ...[
                      TransactionTile(transaction: t), // Logika asli[cite: 4]
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}