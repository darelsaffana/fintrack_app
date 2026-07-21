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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    // Style dekorasi Input
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.accent(context), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.expense(context), width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.expense(context), width: 1.5)),
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
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.cardBorder(context).withOpacity(0.6)),
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
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.text(context), letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Buat akun barumu untuk mulai mengatur finansial yang lebih baik',
                            style: TextStyle(color: AppColors.muted(context), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 32),

                          // INPUT FIELDS (NAMA, EMAIL, PASSWORD, CONFIRM)
                          TextFormField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                            decoration: fieldDecoration(labelText: 'Nama Lengkap', prefixIcon: Icons.person_rounded),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
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
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                            decoration: fieldDecoration(
                              labelText: 'Password', 
                              prefixIcon: Icons.lock_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.muted(context), size: 20),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirm,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                            decoration: fieldDecoration(
                              labelText: 'Konfirmasi Password', 
                              prefixIcon: Icons.lock_clock_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.muted(context), size: 20),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) => (v != _password.text) ? 'Konfirmasi tidak cocok' : null,
                          ),

                          // BOX ERROR ANIMATED
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: _error == null
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.expense(context).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.expense(context).withOpacity(0.2)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline_rounded, color: AppColors.expense(context), size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(child: Text(_error!, style: TextStyle(color: AppColors.expense(context), fontSize: 13, fontWeight: FontWeight.bold))),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 28),

                          // TOMBOL DAFTAR[cite: 2]
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
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. TEKS SYARAT & KETENTUAN
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Text.rich(
                TextSpan(
                  text: 'Dengan mendaftar, Anda menyetujui\n',
                  children: [
                    TextSpan(text: 'Syarat & Ketentuan', style: TextStyle(color: AppColors.accent(context), fontWeight: FontWeight.bold)),
                    TextSpan(text: ' serta '),
                    TextSpan(text: 'Kebijakan Privasi', style: TextStyle(color: AppColors.accent(context), fontWeight: FontWeight.bold)),
                    TextSpan(text: ' kami.'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted(context), fontSize: 12, height: 1.5),
              ),
            ),

            // 3. TOMBOL BACK CUSTOM
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context)),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card(context),
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