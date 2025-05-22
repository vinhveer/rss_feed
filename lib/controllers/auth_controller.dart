import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAnonymous = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to Supabase auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn) {
        currentUser.value = session?.user;
        isAnonymous.value = session?.user?.userMetadata?['is_anonymous'] == true;
      } else if (event == AuthChangeEvent.signedOut) {
        currentUser.value = null;
        isAnonymous.value = false;
      }
    });
    // Initialize auth on controller init
    initializeAuth();
  }

  /// Initial auth setup: ensure anonymous or existing session
  Future<void> initializeAuth() async {
    isLoading.value = true;
    try {
      final user = await _authService.ensureAnonymousSession();
      currentUser.value = user;
      isAnonymous.value = user?.userMetadata?['is_anonymous'] == true;
    } catch (e) {
      // fallback: try anonymous again
      try {
        final anon = await _authService.ensureAnonymousSession();
        currentUser.value = anon;
        isAnonymous.value = true;
      } catch (e2) {
        currentUser.value = null;
        isAnonymous.value = false;
      }
    } finally {
      isLoading.value = false;
    }

    final session = Supabase.instance.client.auth.currentSession;
    final accessToken = session?.accessToken;

    Get.log(accessToken.toString());
  }

  /// Sign up from anonymous to email/password
  Future<User?> signUpWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final user = await _authService.signUpWithEmail(email, password);
      currentUser.value = user;
      isAnonymous.value = false;
      return user;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in existing email/password user
  Future<User?> signInWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final user = await _authService.signInWithEmail(email, password);
      currentUser.value = user;
      isAnonymous.value = false;
      return user;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out and re-create anonymous session
  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
      final anon = await _authService.ensureAnonymousSession();
      currentUser.value = anon;
      isAnonymous.value = true;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
