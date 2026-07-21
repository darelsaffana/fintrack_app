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
    final color = t.category != null ? hexToColor(t.category!.color) : (isIncome ? AppColors.income(context) : AppColors.expense(context));
    final title = (t.description != null && t.description!.trim().isNotEmpty) ? t.description! : (t.category?.name ?? 'Transaksi');
    final dateStr = '${t.date.day} ${_monthName(t.date.month)} ${t.date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Ratakan atas agar sejajar ikon
        children: [
          // 1. IKON INDIKATOR (Pemasukan / Pengeluaran)
          Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(top: 2), // Biar pas di tengah baris pertama
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), 
              shape: BoxShape.circle
            ),
            child: Icon(
              isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          
          // 2. AREA KONTEN UTAMA (Dibuat bertingkat agar hemat ruang horizontal)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BARIS ATAS: Judul Transaksi & Nominal Uang
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis, 
                        style: TextStyle(
                          color: AppColors.text(context), 
                          fontWeight: FontWeight.w600, 
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${isIncome ? "+" : "-"}${formatRupiah(t.amount)}',
                      style: TextStyle(
                        color: isIncome ? AppColors.income(context) : AppColors.expense(context), 
                        fontWeight: FontWeight.w700, 
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // BARIS BAWAH: Detail Kategori/Tanggal & Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${t.category?.name ?? "-"} • $dateStr',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.mutedDim(context), 
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Kumpulan tombol aksi digeser ke kanan bawah agar tidak menjebol text
                    if (onEdit != null || onDelete != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            InkWell(
                              onTap: onEdit,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(Icons.edit_outlined, size: 16, color: AppColors.muted(context)),
                              ),
                            ),
                          if (onDelete != null)
                            InkWell(
                              onTap: onDelete,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(Icons.delete_outline, size: 16, color: AppColors.muted(context)),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
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