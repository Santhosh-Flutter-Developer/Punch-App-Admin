import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  final RxBool isDarkMode = false.obs;
  final RxString currentRoute = '/dashboard'.obs;
  final RxBool isSidebarExpanded = true.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleSidebar() {
    isSidebarExpanded.value = !isSidebarExpanded.value;
  }

  void setRoute(String route) {
    currentRoute.value = route;
    Get.toNamed(route);
  }
}
