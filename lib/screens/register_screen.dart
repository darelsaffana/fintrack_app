import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().register(_name.text.trim(), _email.text.trim(), _password.text, _confirm.text);
      if (mounted) await context.read<AppProvider>().loadAll();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _error = extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

@override
  Widget build(BuildContext context) {
    // Style dekorasi Input (Tetap sama seperti kode asli Anda)
    InputDecoration fieldDecoration({required String labelText, required IconData prefixIcon}) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
        floatingLabelStyle: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
        prefixIcon: Icon(prefixIcon, color: AppColors.muted, size: 20),
        filled: true,
        fillColor: AppColors.cardBorder.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.expense, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.expense, width: 1.5)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack( // MENGGUNAKAN STACK AGAR LAYOUT FLEKSIBEL
          children: [
            
            // 1. FORM UTAMA (SEKARANG AKAN SEMPURNA DI TENGAH LAYAR)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Mengikuti tinggi konten
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // JUDUL HALAMAN
                          Text(
                            'Daftar Akun',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Buat akun barumu untuk mulai mengatur finansial yang lebih baik',
                            style: TextStyle(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 32),

                          // INPUT FIELDS (NAMA, EMAIL, PASSWORD, CONFIRM)
                          TextFormField(
                            controller: _name,
                            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                            decoration: fieldDecoration(labelText: 'Nama Lengkap', prefixIcon: Icons.person_rounded),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                            decoration: fieldDecoration(labelText: 'Email', prefixIcon: Icons.email_rounded),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(v)) {
                                return 'Format email tidak valid (contoh: nama@email.com)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                            decoration: fieldDecoration(labelText: 'Password', prefixIcon: Icons.lock_rounded),
                            validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirm,
                            obscureText: true,
                            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                            decoration: fieldDecoration(labelText: 'Konfirmasi Password', prefixIcon: Icons.lock_clock_rounded),
                            validator: (v) => (v != _password.text) ? 'Konfirmasi tidak cocok' : null,
                          ),

                          // BOX ERROR[cite: 2]
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.expense.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.expense.withOpacity(0.2)),
                              ),
                              child: Text(_error!, style: const TextStyle(color: AppColors.expense, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // TOMBOL DAFTAR[cite: 2]
                          ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : const Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. TOMBOL BACK CUSTOM (DIPOSISIKAN MENAMBANG DI KIRI ATAS)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card,
                  padding: const EdgeInsets.all(12),
                  elevation: 2, // Opsional: Beri sedikit bayangan agar pop-out
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}