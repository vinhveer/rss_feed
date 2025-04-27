import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Đảm bảo luôn có anonymous session, nếu chưa thì tạo mới
  Future<User?> ensureAnonymousSession() async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      try {
        final AuthResponse res = await _supabase.auth.signInAnonymously(
          data: {'is_anonymous': true},
        );
        print('✅ Anonymous user created: ${res.user?.id}');
        return res.user;
      } on AuthException catch (e) {
        print('❌ Error creating anonymous user: ${e.message}');
        throw AuthException('Cannot create anonymous user: ${e.message}');
      }
    }
    print('ℹ️ Existing session found: ${session.user?.id}');
    return session.user;
  }

  /// Đăng ký bằng email/password, merge dữ liệu anonymous nếu cần
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
        print('✅ User signed up with email: ${user.email}');
        // Nếu có anonymous session, gọi merge dữ liệu
        await _mergeAnonymousData(anonToken, res.session?.accessToken);
        return user;
      }

      // Trường hợp không trả về user (hiếm gặp)
      throw AuthException('Sign up failed: no user returned');
    } on AuthException catch (e) {
      print('⚠️ Sign up error: ${e.message}');
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
        print('✅ User signed in with email: ${user.email}');
        await _mergeAnonymousData(anonToken, res.session?.accessToken);
        return user;
      }
      throw AuthException('Invalid login credentials');
    } on AuthException catch (e) {
      print('⚠️ Login error: ${e.message}');
      // Nếu credentials không hợp lệ, nâng cấp anonymous thành tài khoản thực
      if (e.message.contains('Invalid login credentials')) {
        try {
          final UserResponse updateRes = await _supabase.auth.updateUser(
            UserAttributes(email: email, password: password),
          );
          print('✅ Anonymous user upgraded to real user: ${updateRes.user?.email}');
          return updateRes.user;
        } on AuthException catch (e2) {
          print('❌ Upgrade failed: ${e2.message}');
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
      print('➡️ Redirected to Google OAuth');
      _supabase.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn) {
          print('✅ Signed in with Google: ${data.session?.user?.email}');
          await _mergeAnonymousData(anonToken, data.session?.accessToken);
        }
      });
    } catch (e) {
      print('❌ Google sign-in error: $e');
      rethrow;
    }
  }

  /// Gọi Edge Function để merge dữ liệu anonymous → real user và xóa anonymous user
  Future<void> _mergeAnonymousData(String? anonToken, String? userToken) async {
    if (anonToken == null || userToken == null) {
      print('ℹ️ Skipped merging because anonToken or userToken is null');
      return;
    }
    try {
      final res = await _supabase.functions.invoke(
        'merge-anon',
        body: {'anonToken': anonToken, 'userToken': userToken},
      );
      print('✅ Merged anonymous data: $res');
    } on FunctionException catch (e) {
      print('❌ Merge failed: ${e.reasonPhrase}');
      throw AuthException('Merge failed: ${e.reasonPhrase}');
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _secureStorage.deleteAll();
      print('✅ User signed out and secure storage cleared');
    } catch (e) {
      print('❌ Sign out error: $e');
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
