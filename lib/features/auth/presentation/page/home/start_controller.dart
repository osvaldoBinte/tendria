
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/features/page/parami/for_you_page.dart';
import 'package:tendria/features/page/profiledetail/profile_detail_page.dart';

class StartController extends GetxController {
  final List<Widget> pages = [
     Container(),
     ForYouPage(),
     ProfileDetailScreen(),
     Container(),


  ];

  final List<String> iconPaths = [
    'assets/icons/home/perfil.png',
    'assets/icons/home/parati.png', 
    'assets/icons/home/home.png',
    'assets/icons/home/mensaje.png',
  ];

  final List<String> selectedIconPaths = [
    'assets/icons/home/perfil.png',
    'assets/icons/home/parati.png', 
    'assets/icons/home/home.png',
    'assets/icons/home/mensaje.png',
  ];

  final RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  Widget get currentPage => pages[selectedIndex.value];

  String getIconPath(int index) {
    return selectedIndex.value == index 
        ? selectedIconPaths[index] 
        : iconPaths[index];
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

