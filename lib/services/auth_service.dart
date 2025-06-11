import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _storage = GetStorage();

  Future<User?> ensureAnonymousSession() async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      try {
        final AuthResponse res = await _supabase.auth.signInAnonymously(
          data: {'is_anonymous': true},
        );
        Get.log("ensureAnonymousSession");
        return res.user;
      } on AuthException catch (e) {
        throw AuthException('Cannot create anonymous user: ${e.message}');
      }
    }
    return session.user;
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = res.user;

      if (user != null) {
        await _storage.erase();
        return user;
      }

      throw AuthException('Sign up failed: no user returned');
    } on AuthException {
      rethrow;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user != null) {
        await _storage.erase();
        return user;
      }
      throw AuthException('Invalid login credentials');
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        try {
          final UserResponse updateRes = await _supabase.auth.updateUser(
            UserAttributes(email: email, password: password),
          );
          await _storage.erase();
          return updateRes.user;
        } on AuthException catch (e2) {
          throw AuthException('Upgrade failed: ${e2.message}');
        }
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _secureStorage.deleteAll();
      await _storage.erase();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }
}

/// Lỗi xác thực tuỳ chỉnh
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}
