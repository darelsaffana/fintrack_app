import 'dart:typed_data'; // WAJIB TAMBAH UNTUK UINT8LIST
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _formKey = GlobalKey<FormState>(); // Logika asli dipertahankan[cite: 5]

  late final TextEditingController _name;
  late final TextEditingController _email;
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _saving = false; // Logika asli dipertahankan[cite: 5]
  bool _saved = false;  // Logika asli dipertahankan[cite: 5]
  String? _error;       // Logika asli dipertahankan[cite: 5]
  
  // Variabel baru untuk menampung gambar sementara secara lokal
  Uint8List? _localAvatarBytes;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user; // Logika asli dipertahankan[cite: 5]
    _name = TextEditingController(text: user?.name ?? ''); // Logika asli dipertahankan[cite: 5]
    _email = TextEditingController(text: user?.email ?? ''); // Logika asli dipertahankan[cite: 5]
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async { // Logika asli dipertahankan[cite: 5]
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    // LANGSUNG PASANG DI STATE LOKAL AGAR UI BERUBAH DETIK ITU JUGA
    setState(() {
      _localAvatarBytes = bytes;
    });

    try {
      await context.read<AuthProvider>().uploadAvatar(bytes, picked.name); // Logika asli dipertahankan[cite: 5]
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto ke server: ${extractErrorMessage(e)}')),
        );
      }
    }
  }

  Future<void> _submit() async { // Logika asli dipertahankan[cite: 5]
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
      _saved = false;
    });

    try {
      final auth = context.read<AuthProvider>();

      await auth.updateProfile(_name.text.trim(), _email.text.trim()); // Logika asli dipertahankan[cite: 5]

      if (_newPassword.text.isNotEmpty) {
        await auth.changePassword( // Logika asli dipertahankan[cite: 5]
          currentPassword: _currentPassword.text,
          newPassword: _newPassword.text,
          newPasswordConfirmation: _confirmPassword.text,
        );
        _currentPassword.clear();
        _newPassword.clear();
        _confirmPassword.clear();
      }

      setState(() => _saved = true);
    } catch (e) {
      setState(() => _error = extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async { // Logika asli dipertahankan[cite: 5]
    await context.read<AuthProvider>().logout();
    context.read<AppProvider>().reset();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 700; // Logika asli dipertahankan[cite: 5]

      final summaryCard = _ProfileSummaryCard(
        onPickPhoto: _pickPhoto, 
        onLogout: _logout,
        localBytes: _localAvatarBytes, // Kirim bytes lokal ke UI Card
      ); 
      final formCard = _ProfileFormCard(
        formKey: _formKey,
        name: _name,
        email: _email,
        currentPassword: _currentPassword,
        newPassword: _newPassword,
        confirmPassword: _confirmPassword,
        saving: _saving,
        saved: _saved,
        error: _error,
        onSubmit: _submit,
      );

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 280, child: summaryCard),
                  const SizedBox(width: 20),
                  Expanded(child: formCard),
                ],
              )
            else
              Column(
                children: [
                  summaryCard,
                  const SizedBox(height: 20),
                  formCard,
                ],
              ),
          ],
        ),
      );
    });
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final VoidCallback onPickPhoto;
  final VoidCallback onLogout;
  final Uint8List? localBytes; // Variabel baru ditambahkan
  
  const _ProfileSummaryCard({
    required this.onPickPhoto, 
    required this.onLogout,
    this.localBytes,
  });

  ImageProvider? _avatarImage(AuthProvider auth) { // Logika asli dipertahankan[cite: 5]
    if (localBytes != null) return MemoryImage(localBytes!); // Prioritaskan cache lokal yang baru dipilih
    if (auth.avatarPreview != null) return MemoryImage(auth.avatarPreview!); // Fallback 1[cite: 5]
    if (auth.user?.avatarUrl != null) return NetworkImage(auth.user!.avatarUrl!); // Fallback 2[cite: 5]
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>(); // Logika asli dipertahankan[cite: 5]
    final user = auth.user;
    final initials = (user?.name.isNotEmpty == true)
        ? user!.name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join()
        : 'P';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 3),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.accent.withOpacity(0.12),
                  backgroundImage: _avatarImage(auth),
                  child: _avatarImage(auth) == null
                      ? Text(initials, style: const TextStyle(color: AppColors.accent, fontSize: 32, fontWeight: FontWeight.w800))
                      : null,
                ),
              ),
              if (auth.uploadingAvatar)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    ),
                  ),
                ),
              Positioned(
                right: 2,
                bottom: 2,
                child: InkWell(
                  onTap: onPickPhoto,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            user?.name.isNotEmpty == true ? user!.name : 'Pengguna',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '-',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onPickPhoto,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ubah Foto Profil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 32, color: AppColors.cardBorder),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.expense),
            label: const Text('Keluar Akun', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: BorderSide(color: AppColors.expense.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController currentPassword;
  final TextEditingController newPassword;
  final TextEditingController confirmPassword;
  final bool saving;
  final bool saved;
  final String? error;
  final VoidCallback onSubmit;

  const _ProfileFormCard({
    required this.formKey,
    required this.name,
    required this.email,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.saving,
    required this.saved,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700; // Logika asli dipertahankan[cite: 5]

    InputDecoration fieldDecoration({required String labelText, String? hintText}) {
      return InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
        floatingLabelStyle: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: AppColors.cardBorder.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.expense, width: 1),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionLabel('INFORMASI AKUN'),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, c) {
              final sideBySide = c.maxWidth >= 480;
              final nameField = TextFormField(
                controller: name,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                decoration: fieldDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              );
              final emailField = TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                decoration: fieldDecoration(labelText: 'Email Aktif'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
              );
              if (sideBySide) {
                return Row(children: [
                  Expanded(child: nameField),
                  const SizedBox(width: 14),
                  Expanded(child: emailField),
                ]);
              }
              return Column(children: [nameField, const SizedBox(height: 14), emailField]);
            }),

            const SizedBox(height: 32),
            const _SectionLabel('GANTI PASSWORD (OPSIONAL)'),
            const SizedBox(height: 6),
            const Text(
              'Kosongkan kolom di bawah ini jika kamu tidak ingin melakukan perubahan password.',
              style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: currentPassword,
              obscureText: true,
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
              decoration: fieldDecoration(labelText: 'Password Saat Ini'),
              validator: (v) {
                if (newPassword.text.isEmpty) return null;
                return (v == null || v.isEmpty) ? 'Masukkan password saat ini' : null;
              },
            ),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, c) {
              final sideBySide = c.maxWidth >= 480;
              final newPassField = TextFormField(
                controller: newPassword,
                obscureText: true,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                decoration: fieldDecoration(labelText: 'Password Baru'),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  return v.length < 6 ? 'Minimal 6 karakter' : null;
                },
              );
              final confirmField = TextFormField(
                controller: confirmPassword,
                obscureText: true,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                decoration: fieldDecoration(labelText: 'Konfirmasi Password Baru'),
                validator: (v) {
                  if (newPassword.text.isEmpty) return null;
                  return (v != newPassword.text) ? 'Konfirmasi tidak cocok' : null;
                },
              );
              if (sideBySide) {
                return Row(children: [
                  Expanded(child: newPassField),
                  const SizedBox(width: 14),
                  Expanded(child: confirmField),
                ]);
              }
              return Column(children: [newPassField, const SizedBox(height: 14), confirmField]);
            }),

            if (error != null) ...[
              const SizedBox(height: 16),
              Text(error!, style: const TextStyle(color: AppColors.expense, fontSize: 13, fontWeight: FontWeight.bold)),
            ],

            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isWide ? 180 : double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: saved ? const Color(0xFF2EC4B6) : AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          saved ? 'Tersimpan ✓' : 'Simpan Perubahan',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.accent, 
        fontSize: 11, 
        fontWeight: FontWeight.w900, 
        letterSpacing: 1.0,
      ),
    );
  }
}