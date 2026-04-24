import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';

void showSnackBar(String message, Color color) {
  final context = Get.context!;
  final topPadding = MediaQuery.of(context).padding.top;

  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: ThemeColor.textLightColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: ThemeColor.textLightColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // 👇 Margen para posicionarla arriba
      margin: EdgeInsets.only(
        top: topPadding + 8,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).size.height - topPadding - 100,
      ),
      dismissDirection: DismissDirection.up,
    ),
  );
}
void showSuccessSnackbar(String message) {
  showSnackBar(message, ThemeColor.successColor);
}

void showErrorSnackbar(String message) {
  showSnackBar(message, ThemeColor.errorColor);
}

void showInfoSnackbar(String message) {
  showSnackBar(message, ThemeColor.primaryColor);
}

void showWarningSnackbar(String message) {
  showSnackBar(message, Colors.orange);
}