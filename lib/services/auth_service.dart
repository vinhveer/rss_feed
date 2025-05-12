import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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
    // Lưu lại token của anonymous session (nếu có) để merge sau
    final anonToken = _supabase.auth.currentSession?.accessToken;

    try {
      // Gọi API signUp của Supabase
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = res.user;

      if (user != null) {
        // Nếu có anonymous session, gọi merge dữ liệu
        await _mergeAnonymousData(anonToken, res.session?.accessToken);
        return user;
      }

      // Trường hợp không trả về user
      throw AuthException('Sign up failed: no user returned');
    } on AuthException {
      rethrow;
    }
  }


  /// Đăng nhập/đăng ký bằng email/password, merge dữ liệu anonymous nếu cần
  Future<User?> signInWithEmail(String email, String password) async {
    final anonToken = _supabase.auth.currentSession?.accessToken;
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user != null) {
        await _mergeAnonymousData(anonToken, res.session?.accessToken);
        return user;
      }
      throw AuthException('Invalid login credentials');
    } on AuthException catch (e) {
      // Nếu credentials không hợp lệ, nâng cấp anonymous thành tài khoản thực
      if (e.message.contains('Invalid login credentials')) {
        try {
          final UserResponse updateRes = await _supabase.auth.updateUser(
            UserAttributes(email: email, password: password),
          );
          return updateRes.user;
        } on AuthException catch (e2) {
          throw AuthException('Upgrade failed: ${e2.message}');
        }
      }
      rethrow;
    }
  }

  /// Đăng nhập với Google OAuth và merge dữ liệu sau khi hoàn tất
  Future<void> signInWithGoogle() async {
    final anonToken = _supabase.auth.currentSession?.accessToken;
    try {
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      _supabase.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn) {
          await _mergeAnonymousData(anonToken, data.session?.accessToken);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _mergeAnonymousData(String? anonToken, String? userToken) async {
    if (anonToken == null || userToken == null) {
      return;
    }
    try {
      final res = await _supabase.functions.invoke(
        'merge-anon',
        body: {'anonToken': anonToken, 'userToken': userToken},
      );
    } on FunctionException catch (e) {
      throw AuthException('Merge failed: ${e.reasonPhrase}');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _secureStorage.deleteAll();
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
