import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';

void showSnackBarGetx(String message, Color color) {
  Get.closeAllSnackbars();
  Get.snackbar(
    '',
    message,
    titleText: const SizedBox.shrink(),
    messageText: Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: ThemeColor.textLightColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: color,
    snackPosition: SnackPosition.TOP,
    borderRadius: 12,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 350),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    isDismissible: true,
    dismissDirection: DismissDirection.up,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

void showSuccessSnackbarGetx(String message) =>
    showSnackBarGetx(message, ThemeColor.successColor);

void showErrorSnackbarGetx(String message) =>
    showSnackBarGetx(message, ThemeColor.errorColor);

void showInfoSnackbarGetx(String message) =>
    showSnackBarGetx(message, ThemeColor.infoColor);

void showWarningSnackbarGetx(String message) =>
    showSnackBarGetx(message, ThemeColor.warningColor);