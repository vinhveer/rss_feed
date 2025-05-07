import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final SupabaseClient _supabase = SupabaseService.instance.client;

  Future<Map<String, dynamic>?> getMyProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw UserException('User is not authenticated');
    }

    final res = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return res;
  }

  Future<void> updateMyProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw UserException('User is not authenticated');
    }

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    final res = await _supabase
        .from('users')
        .update(updates)
        .eq('id', userId);

    if (res.error != null) {
      throw UserException('Failed to update profile: ${res.error!.message}');
    }
  }
}

class UserException implements Exception {
  final String message;
  const UserException(this.message);
  @override
  String toString() => 'UserException: $message';
}
