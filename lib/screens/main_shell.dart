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

  static const _titles = ['Dashboard', 'Transaksi', 'Kategori', 'Laporan', 'Profil'];
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final provider = context.watch<AppProvider>();

    final body = !_loaded && provider.loading
        ? const Center(child: CircularProgressIndicator())
        : IndexedStack(index: _index, children: _pages);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(index: _index, onSelect: (i) => setState(() => _index = i)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: Text(_titles[_index], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.sidebar,
        indicatorColor: AppColors.accent.withOpacity(0.18),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const _Sidebar({required this.index, required this.onSelect});

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
      width: 224,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Text('Fintrack', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
              ],
            ),
          ),
          for (int i = 0; i < _items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: Material(
                color: i == index ? AppColors.accent.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Icon(_items[i].icon, size: 19, color: i == index ? AppColors.accent : AppColors.muted),
                        const SizedBox(width: 12),
                        Text(_items[i].label, style: TextStyle(color: i == index ? AppColors.accent : AppColors.muted, fontWeight: FontWeight.w600, fontSize: 13.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Fintrack · v1.0', style: TextStyle(color: AppColors.mutedDim, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
