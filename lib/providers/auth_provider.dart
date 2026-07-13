import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, loggedOut, loggedIn }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus status = AuthStatus.checking;
  AppUser? user;

  /// Local preview of a freshly-picked photo, shown instantly while the
  /// upload request to the backend is still in flight. Cleared again if
  /// the upload fails, so the UI never shows a "success" state for a
  /// photo that wasn't actually saved on the server.
  Uint8List? avatarPreview;

  bool uploadingAvatar = false;

  Future<void> checkSession() async {
    try {
      final u = await _service.me();
      user = u;
      status = u != null ? AuthStatus.loggedIn : AuthStatus.loggedOut;
    } catch (_) {
      status = AuthStatus.loggedOut;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    user = await _service.login(email, password);
    status = AuthStatus.loggedIn;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, String confirm) async {
    user = await _service.register(name, email, password, confirm);
    status = AuthStatus.loggedIn;
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    user = null;
    avatarPreview = null;
    status = AuthStatus.loggedOut;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email) async {
    user = await _service.updateProfile(name, email);
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _service.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  Future<void> uploadAvatar(Uint8List bytes, String filename) async {
    avatarPreview = bytes; // instant feedback while uploading
    uploadingAvatar = true;
    notifyListeners();
    try {
      user = await _service.uploadAvatar(bytes, filename);
      // Upload confirmed successful — from now on, prefer the persisted
      // user.avatarUrl over the local preview (they should match anyway).
      avatarPreview = null;
    } catch (e) {
      // Upload failed — throw away the local preview so the UI doesn't
      // lie about the photo being saved, then rethrow so the screen can
      // show an error message to the user.
      avatarPreview = null;
      rethrow;
    } finally {
      uploadingAvatar = false;
      notifyListeners();
    }
  }
}
