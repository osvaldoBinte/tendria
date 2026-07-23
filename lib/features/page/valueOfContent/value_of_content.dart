import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/controller/theme_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class valueOfContent extends StatefulWidget {
  const valueOfContent({Key? key}) : super(key: key);

  @override
  State<valueOfContent> createState() => _valueOfContentScreenState();
}

class _valueOfContentScreenState extends State<valueOfContent> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      body: Obx(() {
        final mode = themeCtrl.themeMode.value; 

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ThemeColor.backgroundColor,
                ThemeColor.backgroundColor,
                ThemeColor.secondaryColor.withOpacity(0.6),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => themeCtrl.toggleVip(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: ThemeColor.subtleBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: ThemeColor.subtleBorder),
                          ),
                          child: Icon(
                            mode == AppThemeMode.vip
                                ? Icons.workspace_premium_rounded
                                : Icons.dark_mode_rounded,
                            color: ThemeColor.primaryColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                     
                      Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ThemeColor.cardBackground.withOpacity(0.4),
                          border: Border.all(
                            color: ThemeColor.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/iconsPREMIUM.png',
                            width: 400,
                            height: 400,
                          ),
                        ),
                      ),
                    ],
                  ),

                   
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: ThemeColor.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'El contenido tiene '),
                          TextSpan(
                            text: 'valor.',
                            style: TextStyle(color: ThemeColor.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Aquí puedes acceder a contenido exclusivo, '
                      'desbloquear experiencias y apoyar directamente '
                      'a los creadores.',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),


                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor,
                        borderRadius: ThemeColor.circularBorderRadius,
                      ),
                      child: Center(
                        child: Text(
                          'Continuar',
                          style: ThemeColor.buttonText.copyWith(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
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

                  const Spacer(flex: 3),
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
