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
    final provider = context.watch<AppProvider>();
    final summary = provider.summary;

    return RefreshIndicator(
      onRefresh: () => provider.loadAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560;
              final cards = [
                SummaryCard(label: 'PEMASUKAN', value: summary?.income ?? 0, color: AppColors.income, icon: Icons.arrow_upward_rounded),
                SummaryCard(label: 'PENGELUARAN', value: summary?.expense ?? 0, color: AppColors.expense, icon: Icons.arrow_downward_rounded),
                SummaryCard(label: 'SALDO', value: summary?.balance ?? 0, color: AppColors.balance, icon: Icons.account_balance_wallet_rounded),
              ];
              if (isNarrow) {
                return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 12), child: c)]);
              }
              return Row(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }),
            const SizedBox(height: 24),
            const Text('Transaksi Terakhir', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            if (summary == null || summary.recentTransactions.isEmpty)
              const EmptyState(message: 'Belum ada transaksi. Mulai catat keuanganmu!')
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final t in summary.recentTransactions) TransactionTile(transaction: t),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
