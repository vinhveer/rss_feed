import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/local_storage_service.dart';

class NamedColor {
  final String name;
  final MaterialColor color;

  const NamedColor(this.name, this.color);
}

class ColorController extends GetxController {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  final _storage = LocalStorageService();

  /// Theme mode: light, dark, system
  late final Rx<ThemeMode> themeMode;

  /// Primary color swatch
  late final Rx<MaterialColor> primarySwatch;

  /// Danh sách các màu với tên tương ứng
  static const List<NamedColor> availableColors = [
    NamedColor('Đỏ', Colors.red),
    NamedColor('Hồng', Colors.pink),
    NamedColor('Tím', Colors.purple),
    NamedColor('Tím đậm', Colors.deepPurple),
    NamedColor('Chàm', Colors.indigo),
    NamedColor('Xanh dương', Colors.blue),
    NamedColor('Xanh dương nhạt', Colors.lightBlue),
    NamedColor('Xanh lơ', Colors.cyan),
    NamedColor('Xanh lục lam', Colors.teal),
    NamedColor('Xanh lá', Colors.green),
    NamedColor('Xanh lá nhạt', Colors.lightGreen),
    NamedColor('Xanh vàng', Colors.lime),
    NamedColor('Vàng', Colors.yellow),
    NamedColor('Hổ phách', Colors.amber),
    NamedColor('Cam', Colors.orange),
    NamedColor('Cam đậm', Colors.deepOrange),
    NamedColor('Nâu', Colors.brown),
    NamedColor('Xám', Colors.grey),
    NamedColor('Xanh xám', Colors.blueGrey),
  ];

  @override
  void onInit() {
    super.onInit();
    // Load saved theme mode
    final savedThemeMode = _storage.get<String>(_themeModeKey);
    themeMode = (savedThemeMode != null 
        ? ThemeMode.values.firstWhere(
            (mode) => mode.toString() == savedThemeMode,
            orElse: () => ThemeMode.system)
        : ThemeMode.system).obs;

    // Load saved primary color
    final savedColorIndex = _storage.get<int>(_primaryColorKey);
    primarySwatch = (savedColorIndex != null && savedColorIndex < availableColors.length
        ? availableColors[savedColorIndex].color
        : Colors.blue).obs;
  }

  /// Getters
  ThemeMode get currentThemeMode => themeMode.value;
  MaterialColor get currentSwatch => primarySwatch.value;

  /// Lấy tên của màu hiện tại
  String getCurrentColorName() {
    return availableColors
        .firstWhereOrNull((c) => c.color == primarySwatch.value)
        ?.name ??
        'Không rõ';
  }

  /// Lấy tên của chế độ hiện tại
  String getCurrentMode() {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      default:
        return 'Hệ thống';
    }
  }

  /// Đổi chế độ theme
  void changeThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _storage.set(_themeModeKey, mode.toString());
  }

  /// Đổi màu chủ đạo
  void changePrimaryColor(MaterialColor color) {
    primarySwatch.value = color;
    final colorIndex = availableColors.indexWhere((c) => c.color == color);
    if (colorIndex != -1) {
      _storage.set(_primaryColorKey, colorIndex);
    }
  }
}
