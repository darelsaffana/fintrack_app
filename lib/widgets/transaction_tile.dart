import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isIncome = t.type == 'income';
    final color = t.category != null ? hexToColor(t.category!.color) : (isIncome ? AppColors.income : AppColors.expense);
    final title = (t.description != null && t.description!.trim().isNotEmpty) ? t.description! : (t.category?.name ?? 'Transaksi');
    final dateStr = '${t.date.day} ${_monthName(t.date.month)} ${t.date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.13), shape: BoxShape.circle),
            child: Icon(
              isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(
                  '${t.category?.name ?? "-"} · $dateStr',
                  style: const TextStyle(color: AppColors.mutedDim, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? "+" : "-"}${formatRupiah(t.amount)}',
            style: TextStyle(color: isIncome ? AppColors.income : AppColors.expense, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.muted),
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.muted),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return names[m - 1];
  }
}
