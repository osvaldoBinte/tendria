import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class FinishOnboardingVip extends StatefulWidget {
  const FinishOnboardingVip({Key? key}) : super(key: key);

  @override
  State<FinishOnboardingVip> createState() => _FinishOnboardingVipScreenState();
}

class _FinishOnboardingVipScreenState extends State<FinishOnboardingVip> {
  int _currentPage = 3;  

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      body: Obx(() {
        final mode = themeCtrl.themeMode.value; 
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: ThemeColor.backgroundColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 24),
 
                  Text(
                    'Tatendria VIP',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ThemeColor.primaryColor,
                    ),
                  ),

                  const Spacer(flex: 3),
 
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ThemeColor.primaryColor.withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ThemeColor.primaryColor.withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.military_tech_rounded,
                          color: ThemeColor.primaryColor,
                          size: 44,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),
 
                  Text(
                    'Comienza tu\nexperiencia VIP.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: ThemeColor.textPrimary,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 14),
 
                  Text(
                    'Descubre contenido exclusivo y forma parte '
                    'de una comunidad diferente.',
                    textAlign: TextAlign.center,
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 4),
 
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: ThemeColor.circularBorderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeColor.primaryColor.withOpacity(0.5),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () { 
                      },
                      child: Container(
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
                                'ENTRAR A TATENDRIA VIP',
                                style: ThemeColor.buttonText.copyWith(
                                  color: Colors.black,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? ThemeColor.primaryColor
                              : ThemeColor.subtleBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}