import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rss_feed/pages/account_pages/page_change_password.dart';
import 'package:rss_feed/pages/account_pages/page_forget_pass.dart';
import 'package:rss_feed/pages/account_pages/page_sign_up.dart';
import 'package:rss_feed/pages/settings_pages/page_choose_topic.dart';
import 'package:rss_feed/pages/explore_pages/page_explore.dart';
import 'package:rss_feed/pages/page_favourite.dart';
import 'package:rss_feed/pages/home_pages/page_home.dart';
import 'package:rss_feed/pages/account_pages/page_login.dart';
import 'package:rss_feed/pages/page_read.dart';
import 'package:rss_feed/pages/settings_pages/page_settings.dart';
import 'package:rss_feed/pages/settings_pages/color_scheme_settings_page.dart';
import 'package:rss_feed/pages/settings_pages/theme_mode_setting_page.dart';
import 'package:rss_feed/controllers/home_controller.dart';

class AppController extends GetxController {
  // Trang hiện tại và trạng thái cuộn
  final RxInt _currentIndex = 0.obs;
  final RxBool _isScrolled = false.obs;

  // Getters
  int get currentIndex => _currentIndex.value;
  bool get isScrolled => _isScrolled.value;

  // Các trang chính
  final List<PageInfo> _pages = [
    PageInfo(page: const PageHome(), id: 'page_home'),
    PageInfo(page: PageExplore(), id: 'page_explore'),
    PageInfo(page: PageFavourite(), id: 'page_favourite'),
    PageInfo(page: PageSettings(), id: 'page_settings'),
  ];

  Widget get currentPage => _pages[currentIndex].page;

  // Thay đổi trang
  void changePage(int index) {
    if (index == 0) {
      // Nếu chuyển về trang chủ, khởi tạo lại HomeController
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>();
      }
      Get.put(HomeController());
    }
    _currentIndex.value = index;
  }

  // Điều hướng
  void goToChooseTopic() => Get.to(() => PageChooseTopic());
  void goToPageRead(String url) => Get.to(() => PageRead(url: url, isVn: true, articleId: 0,));
  void goToPageSetting() => Get.to(() => PageSettings());
  void goToColorSchemeSettingsPage() => Get.to(() => ColorSchemeSettingsPage());
  void goToThemeModeSettingPage() => Get.to(() => ThemeModeSettingPage());
  void goToLoginPage() => Get.to(() => PageLogin());
  void goToChangePassword() => Get.to(() => PageChangePassword());
  void goToForgetPassword() => Get.to(() => PageForgetPass());
  void goToSignUp() => Get.to(() => PageSignUp());
  void goToPageChooseTopic() => Get.to(() => PageChooseTopic());

  // Cập nhật trạng thái cuộn
  void updateScrollStatus(double offset) => _isScrolled.value = offset > 0;
}

class PageInfo {
  final Widget page;
  final String id;
  PageInfo({required this.page, required this.id});
}