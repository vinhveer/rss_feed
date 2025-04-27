// auth_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';  // for debugPrint
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Current authenticated user
  final Rx<User?> currentUser = Rx<User?>(null);
  /// Loading indicator
  final RxBool isLoading = false.obs;
  /// Whether current user is anonymous
  final RxBool isAnonymous = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔔 AuthController.onInit called');
    // Listen to Supabase auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      debugPrint('🔔 AuthStateChange event: ${data.event}');
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn) {
        currentUser.value = session?.user;
        isAnonymous.value = session?.user?.userMetadata?['is_anonymous'] == true;
        debugPrint('✅ User signed in: ${session?.user?.id}, anonymous: ${isAnonymous.value}');
      } else if (event == AuthChangeEvent.signedOut) {
        currentUser.value = null;
        isAnonymous.value = false;
        debugPrint('ℹ️ User signed out');
      }
    });
    // Initialize auth on controller init
    initializeAuth();
  }

  /// Initial auth setup: ensure anonymous or existing session
  Future<void> initializeAuth() async {
    debugPrint('🔔 initializeAuth started');
    isLoading.value = true;
    try {
      final user = await _authService.ensureAnonymousSession();
      debugPrint('✅ ensureAnonymousSession returned: ${user?.id}');
      currentUser.value = user;
      isAnonymous.value = user?.userMetadata?['is_anonymous'] == true;
    } catch (e) {
      debugPrint('❌ initializeAuth error: $e');
      // fallback: try anonymous again
      try {
        final anon = await _authService.ensureAnonymousSession();
        debugPrint('✅ fallback ensureAnonymousSession: ${anon?.id}');
        currentUser.value = anon;
        isAnonymous.value = true;
      } catch (e2) {
        debugPrint('❌ fallback error: $e2');
        currentUser.value = null;
        isAnonymous.value = false;
      }
    } finally {
      isLoading.value = false;
      debugPrint('🔔 initializeAuth ended, isLoading: ${isLoading.value}');
    }
  }

  /// Sign up from anonymous to email/password
  Future<User?> signUpWithEmail(String email, String password) async {
    debugPrint('🔔 signUpWithEmail called');
    isLoading.value = true;
    try {
      final user = await _authService.signUpWithEmail(email, password);
      debugPrint('✅ signUpWithEmail succeeded: ${user?.id}');
      currentUser.value = user;
      isAnonymous.value = false;
      return user;
    } catch (e) {
      debugPrint('❌ signUpWithEmail error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      debugPrint('🔔 signUpWithEmail ended');
    }
  }

  /// Sign in existing email/password user
  Future<User?> signInWithEmail(String email, String password) async {
    debugPrint('🔔 signInWithEmail called');
    isLoading.value = true;
    try {
      final user = await _authService.signInWithEmail(email, password);
      debugPrint('✅ signInWithEmail succeeded: ${user?.id}');
      currentUser.value = user;
      isAnonymous.value = false;
      return user;
    } catch (e) {
      debugPrint('❌ signInWithEmail error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      debugPrint('🔔 signInWithEmail ended');
    }
  }

  /// Sign in with Google (OAuth)
  Future<void> signInWithGoogle() async {
    debugPrint('🔔 signInWithGoogle called');
    isLoading.value = true;
    try {
      await _authService.signInWithGoogle();
      debugPrint('➡️ signInWithGoogle initiated');
      // onAuthStateChange listener will update currentUser
    } catch (e) {
      debugPrint('❌ signInWithGoogle error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      debugPrint('🔔 signInWithGoogle ended');
    }
  }

  /// Sign out and re-create anonymous session
  Future<void> signOut() async {
    debugPrint('🔔 signOut called');
    isLoading.value = true;
    try {
      await _authService.signOut();
      debugPrint('✅ signOut succeeded');
      final anon = await _authService.ensureAnonymousSession();
      debugPrint('✅ new anonymous user: ${anon?.id}');
      currentUser.value = anon;
      isAnonymous.value = true;
    } catch (e) {
      debugPrint('❌ signOut error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      debugPrint('🔔 signOut ended');
    }
  }
}
