import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart'; // Membaca file theme Anda untuk mengambil AppColors
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  // 1. Tahan Native Splash Screen saat mesin awal memuat
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const FintrackApp());
}

class FintrackApp extends StatelessWidget {
  const FintrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Fintrack',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            home: const _RootGate(),
          );
        },
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    // 2. Langsung matikan Native Splash agar beralih ke halaman Flutter dengan background tema
    FlutterNativeSplash.remove();

    switch (auth.status) {
      case AuthStatus.checking:
        // Menampilkan halaman loading animasi dengan warna navy gelap (AppColors.card)
        return const _AnimatedSplashScreen();
      case AuthStatus.loggedOut:
        return const LoginScreen();
      case AuthStatus.loggedIn:
        return const MainShell();
    }
  }
}

/// Halaman Splash Screen animasi dengan background yang sama persis dengan tema Anda
class _AnimatedSplashScreen extends StatelessWidget {
  const _AnimatedSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengambil langsung warna navy gelap 0xFF131A2E dari file theme Anda
      backgroundColor: AppColors.card, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Membuat konten tegak lurus di tengah layar
          mainAxisSize: MainAxisSize.min, // Menghemat ruang agar column pas membungkus isinya
          children: [
            // Logo Fintrack - Tetap mempertahankan ukuran persis sesuai kodingan aslimu
            Image.asset(
              'assets/images/LogoFintrack.png',
              width: 100, 
              height: 100,
              fit: BoxFit.contain, // Ditambahkan agar gambar pas di dalam kotak 60x50
            ),
            
            // Jarak vertikal presisi antara bagian bawah logo dan lingkaran loading
            const SizedBox(height: 20), // Silakan ganti angka ini untuk menjauhkan/mendekatkan
            
            // Animasi Loading yang sekarang berada tepat di bawah logo kamu
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}