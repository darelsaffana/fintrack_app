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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _email;
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _saving = false;
  bool _saved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
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

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    try {
      // Shows the picked photo instantly, then uploads it to the backend
      // so it's saved permanently against the user's account.
      await context.read<AuthProvider>().uploadAvatar(bytes, picked.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto: ${extractErrorMessage(e)}')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
      _saved = false;
    });

    try {
      final auth = context.read<AuthProvider>();

      await auth.updateProfile(_name.text.trim(), _email.text.trim());

      if (_newPassword.text.isNotEmpty) {
        await auth.changePassword(
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

  Future<void> _logout() async {
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
      final isWide = constraints.maxWidth >= 700;

      final summaryCard = _ProfileSummaryCard(onPickPhoto: _pickPhoto, onLogout: _logout);
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

      if (isWide) {
        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 300, child: summaryCard),
              const SizedBox(width: 20),
              Expanded(child: formCard),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            summaryCard,
            const SizedBox(height: 16),
            formCard,
          ],
        ),
      );
    });
  }
}

/// Left-hand card on wide screens (or top card on mobile): avatar,
/// name/email at a glance, and the logout action. Keeps the settings
/// form on the right focused purely on editable fields.
class _ProfileSummaryCard extends StatelessWidget {
  final VoidCallback onPickPhoto;
  final VoidCallback onLogout;
  const _ProfileSummaryCard({required this.onPickPhoto, required this.onLogout});


  /// Picks the right avatar image source: a freshly-picked local preview
  /// takes priority (instant feedback while/just after uploading), then
  /// falls back to the persisted `avatar_url` from the backend, then null
  /// (renders initials instead).
  ImageProvider? _avatarImage(AuthProvider auth) {
    if (auth.avatarPreview != null) return MemoryImage(auth.avatarPreview!);
    if (auth.user?.avatarUrl != null) return NetworkImage(auth.user!.avatarUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final initials = (user?.name.isNotEmpty == true)
        ? user!.name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join()
        : 'P';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.accent.withOpacity(0.18),
                backgroundImage: _avatarImage(auth),
                child: _avatarImage(auth) == null
                    ? Text(initials, style: const TextStyle(color: AppColors.accent, fontSize: 26, fontWeight: FontWeight.bold))
                    : null,
              ),
              if (auth.uploadingAvatar)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.black.withOpacity(0.35),
                    child: const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: onPickPhoto,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user?.name.isNotEmpty == true ? user!.name : 'Pengguna',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '-',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedDim, fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onPickPhoto,
            child: const Text('Ubah Foto Profil', style: TextStyle(fontSize: 12.5)),
          ),
          const Divider(height: 28, color: AppColors.border),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, size: 18, color: AppColors.expense),
            label: const Text('Keluar', style: TextStyle(color: AppColors.expense)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              side: const BorderSide(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}

/// Right-hand card: the actual editable settings, split into clearly
/// labeled sections ("Informasi Akun" / "Ganti Password") so the wide
/// layout doesn't feel like one long empty form.
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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionLabel('Informasi Akun'),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, c) {
              final sideBySide = c.maxWidth >= 420;
              final nameField = TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              );
              final emailField = TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
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

            const SizedBox(height: 28),
            const _SectionLabel('Ganti Password (opsional)'),
            const SizedBox(height: 4),
            const Text(
              'Kosongkan bagian ini jika kamu tidak ingin mengganti password.',
              style: TextStyle(color: AppColors.mutedDim, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: currentPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama'),
              validator: (v) {
                if (newPassword.text.isEmpty) return null;
                return (v == null || v.isEmpty) ? 'Masukkan password lama' : null;
              },
            ),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, c) {
              final sideBySide = c.maxWidth >= 420;
              final newPassField = TextFormField(
                controller: newPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  return v.length < 6 ? 'Minimal 6 karakter' : null;
                },
              );
              final confirmField = TextFormField(
                controller: confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
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
              const SizedBox(height: 14),
              Text(error!, style: const TextStyle(color: AppColors.expense, fontSize: 13)),
            ],

            const SizedBox(height: 26),
            Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 180),
                child: ElevatedButton(
                  onPressed: saving ? null : onSubmit,
                  child: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(saved ? 'Tersimpan ✓' : 'Simpan Perubahan'),
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
      style: const TextStyle(color: AppColors.muted, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.3),
    );
  }
}
