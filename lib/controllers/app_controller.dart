import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rss_feed/pages/appearance_settings/color_scheme_settings_page.dart';
import 'package:rss_feed/pages/appearance_settings/theme_mode_setting_page.dart';
import 'package:rss_feed/pages/page_choose_topic.dart';
import 'package:rss_feed/pages/page_explore.dart';
import 'package:rss_feed/pages/page_favourite.dart';
import 'package:rss_feed/pages/page_home.dart';
import 'package:rss_feed/pages/page_read.dart';
import 'package:rss_feed/pages/page_settings.dart';

class AppController extends GetxController {
  // Trang hiện tại và trạng thái cuộn
  final RxInt _currentIndex = 0.obs;
  final RxBool _isScrolled = false.obs;

  // Theme mode (light, dark, system) và swatch màu chủ đạo
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  final Rx<MaterialColor> _primarySwatch = Rx<MaterialColor>(Colors.blue);

  // Getters
  int get currentIndex => _currentIndex.value;
  bool get isScrolled => _isScrolled.value;
  ThemeMode get themeMode => _themeMode.value;
  MaterialColor get primarySwatch => _primarySwatch.value;

  // Các trang chính
  final List<PageInfo> _pages = [
    PageInfo(page: PageHome(), title: 'Trang chủ', id: 'page_home'),
    PageInfo(page: PageExplore(), title: 'Khám phá', id: 'page_explore'),
    PageInfo(page: PageFavourite(), title: 'Yêu thích', id: 'page_favourite'),
    PageInfo(page: PageSettings(), title: 'Cài đặt', id: 'page_settings'),
  ];

  Widget get currentPage => _pages[currentIndex].page;
  String get currentTitle => _pages[currentIndex].title;

  // Thay đổi trang
  void changePage(int index) => _currentIndex.value = index;

  // Điều hướng
  void goToChooseTopic() => Get.to(() => PageChooseTopic());
  void goToPageRead() => Get.to(() => PageRead());
  void goToColorSchemeSettingsPage() => Get.to(() => ColorSchemeSettingsPage());
  void goToThemeModeSettingPage() => Get.to(() => ThemeModeSettingPage());

  // Cập nhật trạng thái cuộn
  void updateScrollStatus(double offset) => _isScrolled.value = offset > 0;

  // Thay đổi theme mode
  void changeThemeMode(ThemeMode mode) => _themeMode.value = mode;

  // Thay đổi màu chủ đạo
  void changePrimaryColor(MaterialColor color) => _primarySwatch.value = color;

  @override
  void onInit() {
    super.onInit();
  }
}

class PageInfo {
  final Widget page;
  final String title;
  final String id;
  PageInfo({required this.page, required this.title, required this.id});
}