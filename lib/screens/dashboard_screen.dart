import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart'; // Tambahkan import auth
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>(); 
    final summary = provider.summary; 
    
    // Ambil data user
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final initials = (user?.name.isNotEmpty == true)
        ? user!.name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join()
        : 'P';

    // Helper untuk image
    ImageProvider? getAvatarImage() {
      if (auth.avatarPreview != null) return MemoryImage(auth.avatarPreview!);
      if (user?.avatarUrl != null) return NetworkImage(user!.avatarUrl!);
      return null;
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAll(), 
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        // Tidak perlu padding horizontal di root karena kita atur di dalam
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER SALDO (UNGU) DAN KARTU OVERLAP
            Stack(
              clipBehavior: Clip.none,
              children: [
                // BLOK UNGU
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 50), // Ruang untuk kartu overlap
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 120), // Padding bawah diperbesar agar teks tidak tertutup
                  decoration: BoxDecoration(
                    color: AppColors.accent, // Warna deep purple
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40), // Hanya radius bawah agar rata atas
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // FOTO PROFIL DI TENGAH (Sesuai Desain: Lingkaran polos tanpa ring/efek bertumpuk)
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white, // Background putih utuh agar icon transparan terlihat jelas
                        backgroundImage: getAvatarImage(),
                        child: getAvatarImage() == null
                            ? Text(initials, style: const TextStyle(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Saldo',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatRupiah(summary?.balance ?? 0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40, // Sedikit dibesarkan
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Agar tidak error jika angkanya sangat panjang
                      ),
                    ],
                  ),
                ),
                
                // KARTU OVERLAP (PEMASUKAN & PENGELUARAN)
                Positioned(
                  bottom: 0,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            title: 'Pemasukan',
                            amount: summary?.income ?? 0,
                            icon: Icons.arrow_downward_rounded,
                            color: AppColors.income,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: _buildQuickAction(
                            title: 'Pengeluaran',
                            amount: summary?.expense ?? 0,
                            icon: Icons.arrow_upward_rounded,
                            color: AppColors.expense,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: _buildQuickAction(
                            title: 'Saldo',
                            amount: summary?.balance ?? 0,
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppColors.balance, // Menggunakan warna biru
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // TRANSAKSI TERAKHIR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Transaksi Terakhir', 
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.3,
                )
              ),
            ),
            const SizedBox(height: 12),
            
            if (summary == null || summary.recentTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: EmptyState(message: 'Belum ada transaksi. Mulai catat keuanganmu!'),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, 
                    borderRadius: BorderRadius.circular(24), 
                    border: Border.all(
                      color: Theme.of(context).dividerColor, 
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final t in summary.recentTransactions) ...[
                        TransactionTile(transaction: t),
                      ],
                    ],
                  ),
                ),
              ),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({required String title, required num amount, required IconData icon, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24), // Ukuran icon sedikit dikecilkan
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12, // Font size dikecilkan agar muat 3 item
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          formatRupiah(amount),
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 13, // Font size nominal dikecilkan agar tidak terpotong
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}