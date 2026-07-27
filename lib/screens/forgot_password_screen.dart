import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'reset_password_screen.dart';

// Halaman langkah 1 dari alur "Lupa Password": user cuma input email di sini.
// Setelah backend kirim kode reset ke email, user diarahkan ke ResetPasswordScreen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>(); // buat validasi form (cek email diisi apa nggak)
  final _email = TextEditingController();
  final _service = AuthService();
  bool _loading = false; // dipakai buat nonaktifin tombol & nampilin spinner saat request jalan
  String? _error; // pesan error dari backend (kalau ada), ditampilkan di bawah form

  // Dipanggil saat tombol "Kirim Kode Reset" ditekan.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // stop kalau email kosong

    setState(() { _loading = true; _error = null; });
    try {
      // Panggil endpoint POST /forgot-password di backend Laravel.
      // Backend akan generate kode reset & kirim ke email (lihat AuthController::forgotPassword).
      await _service.forgotPassword(_email.text.trim());

      if (mounted) {
        // Sukses -> pindah ke halaman input kode + password baru,
        // sambil bawa email-nya biar user gak perlu ngetik ulang.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: _email.text.trim())),
        );
      }
    } catch (e) {
      // Gagal (misal format email salah) -> tampilkan pesan error dari server.
      setState(() => _error = extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(context)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ConstrainedBox(
            // Batasi lebar maksimal card biar rapi di layar lebar (web/desktop).
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.cardBorder(context).withOpacity(0.6)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Judul halaman
                    Text(
                      'Lupa Password',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text(context)),
                    ),
                    const SizedBox(height: 8),
                    // Deskripsi singkat instruksi ke user
                    Text(
                      'Masukkan email akunmu, kami akan kirim kode reset password.',
                      style: TextStyle(color: AppColors.muted(context), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 28),

                    // Input email
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_rounded, color: AppColors.muted(context)),
                        filled: true,
                        fillColor: AppColors.cardBorder(context).withOpacity(0.15),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
                    ),

                    // Kotak pesan error, cuma muncul kalau _error tidak null
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: AppColors.expense(context), fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                    const SizedBox(height: 24),

                    // Tombol submit -> nonaktif & tampilkan spinner selagi _loading true

                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('Kirim Kode Reset', style: TextStyle(fontWeight: FontWeight.bold)),
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
