import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _service = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _service.resetPassword(
        email: widget.email,
        token: _token.text.trim(),
        password: _password.text,
        passwordConfirmation: _confirm.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil direset, silakan masuk kembali')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                    Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text(context)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cek email ${widget.email} untuk kode reset, lalu masukkan di bawah bersama password barumu.',
                      style: TextStyle(color: AppColors.muted(context), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _token,
                      style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Kode Reset',
                        prefixIcon: Icon(Icons.vpn_key_rounded, color: AppColors.muted(context)),
                        filled: true,
                        fillColor: AppColors.cardBorder(context).withOpacity(0.15),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Kode reset wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        prefixIcon: Icon(Icons.lock_rounded, color: AppColors.muted(context)),
                        filled: true,
                        fillColor: AppColors.cardBorder(context).withOpacity(0.15),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        prefixIcon: Icon(Icons.lock_clock_rounded, color: AppColors.muted(context)),
                        filled: true,
                        fillColor: AppColors.cardBorder(context).withOpacity(0.15),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v != _password.text) ? 'Konfirmasi tidak cocok' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: AppColors.expense(context), fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                    const SizedBox(height: 24),
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
                          : const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
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
