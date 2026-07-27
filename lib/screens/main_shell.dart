import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import 'dashboard_screen.dart';
import 'transaksi_screen.dart';
import 'kategori_screen.dart';
import 'laporan_screen.dart';
import 'profil_screen.dart';

/// Responsive shell:
/// - Wide screens (desktop/laptop, width >= 800): left sidebar (NavigationRail)
/// - Narrow screens (mobile, width < 800): bottom navigation bar
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _loaded = false;

  static const _pages = [
    DashboardScreen(),
    TransaksiScreen(),
    KategoriScreen(),
    LaporanScreen(),
    ProfilScreen(),
  ];
  static const _destinations = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.receipt_long_rounded, label: 'Transaksi'),
    (icon: Icons.sell_rounded, label: 'Kategori'),
    (icon: Icons.bar_chart_rounded, label: 'Laporan'),
    (icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AppProvider>().loadAll();
      if (mounted) setState(() => _loaded = true);
    });
  }

  Widget _navIcon(
    BuildContext context,
    ({IconData icon, String label}) d, {
    required Color color,
    required int count,
  }) {
    final icon = Icon(d.icon, color: color, size: 24);
    // Hanya tab Transaksi yang relevan dengan transaksi tanpa kategori.
    if (d.label != 'Transaksi' || count == 0) return icon;
    return Badge(
      label: Text('$count'),
      backgroundColor: AppColors.expense(context),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final provider = context.watch<AppProvider>();
    final uncategorizedCount =
        provider.transactions.where((t) => t.categoryId == null).length;

    final body = !_loaded && provider.loading
        ? Center(
            child: CircularProgressIndicator(color: AppColors.accent(context)))
        : IndexedStack(index: _index, children: _pages);

    if (isWide) {
      return Scaffold(
        // Kita hapus backgroundColor agar Scaffold menggunakan warna default tema Anda
        body: Row(
          children: [
            _Sidebar(
              index: _index,
              onSelect: (i) => setState(() => _index = i),
              uncategorizedCount: uncategorizedCount,
            ),
            Expanded(
              child: body,
            ),
          ],
        ),
      );
    }

// TAMPILAN MOBILE (Narrow Screens)
    return Scaffold(
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              backgroundColor: AppColors.card(context),
              elevation: 0,
              height: 64, // Lebih ramping
              indicatorColor: AppColors.accent(context).withOpacity(0.15),
              labelBehavior: NavigationDestinationLabelBehavior
                  .alwaysHide, // Menyembunyikan teks label seperti desain
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: _navIcon(context, d,
                        color: AppColors.muted(context), count: uncategorizedCount),
                    selectedIcon: _navIcon(context, d,
                        color: AppColors.accent(context), count: uncategorizedCount),
                    label: d.label,
                    tooltip: d.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final int uncategorizedCount;
  const _Sidebar({
    required this.index,
    required this.onSelect,
    required this.uncategorizedCount,
  });

  static const _items = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.receipt_long_rounded, label: 'Transaksi'),
    (icon: Icons.sell_rounded, label: 'Kategori'),
    (icon: Icons.bar_chart_rounded, label: 'Laporan'),
    (icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260, // Sedikit diperlebar agar tata letak sidebar lebih lega
      decoration: BoxDecoration(
        color: AppColors.sidebar(context),
        border: Border(
          right: BorderSide(
            color: AppColors.cardBorder(context).withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LOGO BRANDING DI SIDEBAR
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/LogoFintrack.png',
                  width: 38,
                  height: 38,
                ),
                const SizedBox(width: 12),
                Text(
                  'Fintrack',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text(context),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // ITEM NAVIGATION SIDEBAR
          for (int i = 0; i < _items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Material(
                color: i == index
                    ? AppColors.accent(context).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Badge(
                          isLabelVisible: _items[i].label == 'Transaksi' && uncategorizedCount > 0,
                          label: Text('$uncategorizedCount'),
                          backgroundColor: AppColors.expense(context),
                          child: Icon(
                            _items[i].icon,
                            size: 20,
                            color: i == index
                                ? AppColors.accent(context)
                                : AppColors.muted(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _items[i].label,
                          style: TextStyle(
                            color: i == index
                                ? AppColors.accent(context)
                                : AppColors.muted(context),
                            fontWeight:
                                i == index ? FontWeight.bold : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),

          // FOOTER SIDEBAR
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.mutedDim(context).withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(
                  'Fintrack • v1.0',
                  style: TextStyle(
                    color: AppColors.mutedDim(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
