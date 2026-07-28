import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class ContentUnlocked extends StatefulWidget {
  const ContentUnlocked({Key? key}) : super(key: key);

  @override
  State<ContentUnlocked> createState() => _ContentUnlockedScreenState();
}

class _ContentUnlockedScreenState extends State<ContentUnlocked> {
  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final mode = themeCtrl.themeMode.value; 
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: ThemeColor.vipBackgroundGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                  decoration: BoxDecoration(
                    color: ThemeColor.cardBackground.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: ThemeColor.subtleBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [ 
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ThemeColor.primaryColor.withOpacity(0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColor.primaryColor.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ThemeColor.primaryColor,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
 
                      Text(
                        'Contenido desbloqueado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ThemeColor.primaryColor,
                        ),
                      ),

                      const SizedBox(height: 10),
 
                      Text(
                        'Este contenido ahora está disponible de forma '
                        'permanente.',
                        textAlign: TextAlign.center,
                        style: ThemeColor.bodyMedium.copyWith(
                          color: ThemeColor.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),
 
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/contenido-desbloqueado.png',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 28),
 
                      GestureDetector(
                        onTap: () { 
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: ThemeColor.primaryColor,
                            borderRadius: ThemeColor.circularBorderRadius,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'VER CONTENIDO',
                                  style: ThemeColor.buttonText.copyWith(
                                    color: Colors.black,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
 
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          'Volver al inicio',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}