import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user.dart';

class AuthService {
  Future<AppUser> register(String name, String email, String password, String passwordConfirmation) async {
    final res = await ApiClient.instance.dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    await _saveToken(res.data['token']);
    return AppUser.fromJson(res.data['user']);
  }

  Future<AppUser> login(String email, String password) async {
    final res = await ApiClient.instance.dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    await _saveToken(res.data['token']);
    return AppUser.fromJson(res.data['user']);
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.dio.post('/logout');
    } catch (_) {
      // ignore network errors on logout, still clear local token
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<AppUser?> me() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) return null;
    final res = await ApiClient.instance.dio.get('/me');
    return AppUser.fromJson(res.data);
  }

  Future<AppUser> updateProfile(String name, String email) async {
    final res = await ApiClient.instance.dio.put('/profile', data: {'name': name, 'email': email});
    return AppUser.fromJson(res.data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await ApiClient.instance.dio.put('/password', data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation,
    });
  }

  /// Uploads raw image bytes to the backend and returns the updated user
  /// (with a fresh `avatarUrl` pointing at the stored file). Using bytes
  /// instead of a file path keeps this working on Flutter Web too.
  Future<AppUser> uploadAvatar(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await ApiClient.instance.dio.post('/profile/avatar', data: formData);
    return AppUser.fromJson(res.data);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}
