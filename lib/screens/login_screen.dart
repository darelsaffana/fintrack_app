import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import 'main_shell.dart';
import 'register_screen.dart';

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().login(_email.text.trim(), _password.text);
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
    InputDecoration fieldDecoration({required String labelText, required IconData prefixIcon}) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: AppColors.accent(context), fontWeight: FontWeight.bold),
        prefixIcon: Icon(prefixIcon, color: AppColors.muted(context), size: 20),
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
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                      decoration: fieldDecoration(
                        labelText: 'Password', 
                        prefixIcon: Icons.lock_rounded,
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                    ),

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