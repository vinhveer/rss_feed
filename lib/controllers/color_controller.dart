import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NamedColor {
  final String name;
  final MaterialColor color;

  const NamedColor(this.name, this.color);
}

class ColorController extends GetxController {
  /// Theme mode: light, dark, system
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// Primary color swatch
  final Rx<MaterialColor> primarySwatch = Colors.blue.obs;

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
  void changeThemeMode(ThemeMode mode) => themeMode.value = mode;

  /// Đổi màu chủ đạo
  void changePrimaryColor(MaterialColor color) => primarySwatch.value = color;
}
