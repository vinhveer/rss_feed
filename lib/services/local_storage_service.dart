import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final _storage = GetStorage();

  /// Get value from storage
  /// Returns null if key doesn't exist
  T? get<T>(String key) {
    try {
      return _storage.read<T>(key);
    } catch (e) {
      Get.log('Error reading from storage: $e');
      return null;
    }
  }

  /// Set value to storage
  /// If value is null, the key will be removed
  Future<void> set<T>(String key, T? value) async {
    try {
      if (value == null) {
        await _storage.remove(key);
      } else {
        await _storage.write(key, value);
      }
    } catch (e) {
      Get.log('Error writing to storage: $e');
    }
  }
} 