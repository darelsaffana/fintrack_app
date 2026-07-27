import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'main_shell.dart';
import 'register_screen.dart';

// Halaman awal aplikasi kalau user belum login. Kalau berhasil, lempar ke MainShell.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true; // toggle show/hide untuk field password

  // Dipanggil saat tombol "Masuk" ditekan.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      // Login lewat AuthProvider (yang manggil POST /login ke backend & simpan token).
      await context.read<AuthProvider>().login(_email.text.trim(), _password.text);
      // Setelah login sukses, langsung tarik semua data awal (transaksi, kategori, dll).
      if (mounted) await context.read<AppProvider>().loadAll();

      if (mounted) {
        // pushAndRemoveUntil(..., (route) => false) -> hapus semua history halaman
        // sebelumnya, jadi user gak bisa "back" ke halaman login lagi setelah masuk.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      // Gagal login (email/password salah, dll) -> tampilkan pesan error dari server.
      setState(() => _error = extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper biar semua TextFormField di halaman ini (email & password) punya
    // gaya/warna/border yang sama persis, tanpa nulis ulang tiap kali.
    InputDecoration fieldDecoration({required String labelText, required IconData prefixIcon, Widget? suffixIcon}) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: AppColors.accent(context), fontWeight: FontWeight.bold),
        prefixIcon: Icon(prefixIcon, color: AppColors.muted(context), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.cardBorder(context).withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accent(context), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.expense(context), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.expense(context), width: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgApp(context), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.cardBorder(context).withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO DAN IDENTITAS
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/LogoFintrack.png', // Menggunakan LogoFintrack.png
                          width: 80, 
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12), 
                        Text(
                          'Fintrack',
                          style: TextStyle(
                            fontSize: 30, 
                            fontWeight: FontWeight.w900,
                            color: AppColors.text(context),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Masuk untuk mulai catat keuanganmu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // FORM INPUTS
                    // Field email, divalidasi wajib diisi + format harus mengandung "@" dan domain.
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                      decoration: fieldDecoration(
                        labelText: 'Email', 
                        prefixIcon: Icons.email_rounded,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                        if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v)) {
                          return 'Format email tidak valid (contoh: nama@email.com)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Field password, wajib diisi + minimal 6 karakter (sinkron dengan aturan backend).
                    // suffixIcon-nya tombol mata buat show/hide teks password.
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                      decoration: fieldDecoration(
                        labelText: 'Password', 
                        prefixIcon: Icons.lock_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.muted(context), size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password wajib diisi';
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    // Link "Lupa Password?" -> buka alur ForgotPasswordScreen -> ResetPasswordScreen.
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        ),
                        style: TextButton.styleFrom(foregroundColor: AppColors.muted(context)),
                        child: const Text('Lupa Password?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),

                    // Kotak pesan error (email/password salah, dll), cuma tampil kalau ada error.
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.expense(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.expense(context).withOpacity(0.2)),
                        ),
                        child: Text(
                          _error!, 
                          style: TextStyle(
                            color: AppColors.expense(context), 
                            fontSize: 13, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // BUTTONS
                    // Tombol utama "Masuk" -> nonaktif & tampilkan spinner selagi _loading true.
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent(context),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              'Masuk', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Link ke halaman Register buat yang belum punya akun.
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent(context),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Belum punya akun? Daftar di sini', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}