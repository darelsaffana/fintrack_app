import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/theme_toggle_button.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Uint8List? _localAvatarBytes;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      _localAvatarBytes = bytes;
    });

    try {
      await context.read<AuthProvider>().uploadAvatar(bytes, picked.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto: ${extractErrorMessage(e)}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.read<AppProvider>().reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileModal(),
    );
  }

  void _showChangePasswordModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChangePasswordModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Profil',
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _ProfileHeaderCard(
                onPickPhoto: _pickPhoto,
                localBytes: _localAvatarBytes,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder(context).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.person_rounded,
                      title: 'Edit Profil',
                      onTap: _showEditProfileModal,
                    ),
                    const _Divider(),
                    _MenuTile(
                      icon: Icons.lock_rounded,
                      title: 'Keamanan & Password',
                      onTap: _showChangePasswordModal,
                    ),
                    const _Divider(),
                    _MenuTile(
                      icon: Icons.palette_rounded,
                      title: 'Tema Tampilan',
                      trailing: const ThemeToggleButton(),
                    ),
                    const _Divider(),
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      title: 'Keluar Akun',
                      isDestructive: true,
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final VoidCallback onPickPhoto;
  final Uint8List? localBytes;

  const _ProfileHeaderCard({required this.onPickPhoto, this.localBytes});

  ImageProvider? _avatarImage(AuthProvider auth) {
    if (localBytes != null) return MemoryImage(localBytes!);
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
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent(context).withOpacity(0.3), width: 3),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.accent(context).withOpacity(0.12),
                  backgroundImage: _avatarImage(auth),
                  child: _avatarImage(auth) == null
                      ? Text(initials,
                          style: TextStyle(
                              color: AppColors.accent(context),
                              fontSize: 32,
                              fontWeight: FontWeight.w800))
                      : null,
                ),
              ),
              if (auth.uploadingAvatar)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: onPickPhoto,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card(context), width: 2.5),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.name.isNotEmpty == true ? user!.name : 'Pengguna',
            style: TextStyle(
              color: AppColors.text(context),
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '-',
            style: TextStyle(
              color: AppColors.muted(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.expense(context) : AppColors.text(context);
    final iconColor = isDestructive ? AppColors.expense(context) : AppColors.muted(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: AppColors.mutedDim(context), size: 24),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 20,
      color: AppColors.cardBorder(context).withOpacity(0.5),
    );
  }
}

// ==========================================
// MODAL: EDIT PROFIL
// ==========================================
class _EditProfileModal extends StatefulWidget {
  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  bool _saving = false;
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
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      await context.read<AuthProvider>().updateProfile(_name.text.trim(), _email.text.trim());
      if (mounted) Navigator.pop(context); // Tutup modal jika sukses
    } catch (e) {
      setState(() => _error = extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.cardBorder(context), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Edit Profil', style: TextStyle(color: AppColors.text(context), fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.expense(context).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!, style: TextStyle(color: AppColors.expense(context), fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _name,
                  style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(context, 'Nama Lengkap'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(context, 'Email'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent(context),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MODAL: GANTI PASSWORD
// ==========================================
class _ChangePasswordModal extends StatefulWidget {
  @override
  State<_ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<_ChangePasswordModal> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      await context.read<AuthProvider>().changePassword(
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
        newPasswordConfirmation: _confirmPassword.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah!')));
      }
    } catch (e) {
      setState(() => _error = extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.cardBorder(context), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Ganti Password', style: TextStyle(color: AppColors.text(context), fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.expense(context).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!, style: TextStyle(color: AppColors.expense(context), fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _currentPassword,
                  obscureText: true,
                  style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(context, 'Password Saat Ini'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPassword,
                  obscureText: true,
                  style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(context, 'Password Baru'),
                  validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: true,
                  style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(context, 'Konfirmasi Password Baru'),
                  validator: (v) => v != _newPassword.text ? 'Password tidak sama' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent(context),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Password', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Utility style for modal text fields
InputDecoration _inputDecoration(BuildContext context, String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppColors.muted(context), fontWeight: FontWeight.w500),
    filled: true,
    fillColor: AppColors.cardBorder(context).withOpacity(0.15),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.accent(context), width: 1.5)),
  );
}
