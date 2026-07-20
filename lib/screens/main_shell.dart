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
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : IndexedStack(index: _index, children: _pages);

if (isWide) {
      return Scaffold(
        // Kita hapus backgroundColor agar Scaffold menggunakan warna default tema Anda
        body: Row(
          children: [
            _Sidebar(index: _index, onSelect: (i) => setState(() => _index = i)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header desktop (hanya tampil jika bukan Dashboard)
                  if (_index != 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                      child: Text(
                        _titles[_index],
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.w900, 
                          color: AppColors.text,
                          letterSpacing: -0.5,
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: _index != 0 ? const EdgeInsets.symmetric(horizontal: 40) : EdgeInsets.zero,
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

// TAMPILAN MOBILE (Narrow Screens)
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header Mobile (hanya tampil jika bukan Dashboard)
            if (_index != 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  _titles[_index],
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.w900, 
                    color: AppColors.text,
                    letterSpacing: -0.5,
                ),
              ),
            Expanded(
              child: Padding(
                padding: _index != 0 ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : EdgeInsets.zero,
                child: body,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
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
              backgroundColor: Colors.white,
              elevation: 0,
              height: 64, // Lebih ramping
              indicatorColor: AppColors.accent.withOpacity(0.15),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Menyembunyikan teks label seperti desain
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon, color: AppColors.muted, size: 24),
                    selectedIcon: Icon(d.icon, color: AppColors.accent, size: 24),
                    label: d.label,
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
      width: 260, // Sedikit diperlebar agar tata letak sidebar lebih lega
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(
            color: AppColors.cardBorder.withOpacity(0.4),
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
                    color: AppColors.text,
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
                color: i == index ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          _items[i].icon, 
                          size: 20, 
                          color: i == index ? AppColors.accent : AppColors.muted,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _items[i].label, 
                          style: TextStyle(
                            color: i == index ? AppColors.accent : AppColors.muted,
                            fontWeight: i == index ? FontWeight.bold : FontWeight.w600, 
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
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.mutedDim.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(
                  'Fintrack · v1.0', 
                  style: TextStyle(
                    color: AppColors.mutedDim, 
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