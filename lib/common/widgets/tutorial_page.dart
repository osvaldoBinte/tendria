import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  final RxInt currentIndex = 0.obs;

  final List<String> tutorialImages = [
    'assets/tutorial/tutorial1.png',
    'assets/tutorial/tutorial2.png',
    'assets/tutorial/tutorial3.png',
    'assets/tutorial/tutorial4.png',
    'assets/tutorial/tutorial5.png',
    'assets/tutorial/tutorial6.png',
    'assets/tutorial/tutorial7.png',
    'assets/tutorial/tutorial8.png',
  ];
void nextPage() async {
  if (currentIndex.value < tutorialImages.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    await _markTutorialAsSeen(); // 👈
    Get.offAllNamed(RoutesNames.welcomePage);
  }
}Future<void> _markTutorialAsSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(AppConstants.tutorialKey, true);
  print('Tutorial guardado: ${prefs.getBool(AppConstants.tutorialKey)}');
}

  void previousPage() {
    if (currentIndex.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.textPrimaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
  child: PageView.builder(
    controller: _pageController,
    itemCount: tutorialImages.length,
    onPageChanged: (index) {
      currentIndex.value = index;
    },
    itemBuilder: (context, index) {
      return AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          double value = 1.0;

          if (_pageController.position.haveDimensions) {
            value = (_pageController.page! - index);
            value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
          }

          return Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: value,
              child: Transform.scale(
                scale: value,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    tutorialImages[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  ),
),

            Obx(() => _buildNavigationButtons(
                  isLastStep:
                      currentIndex.value == tutorialImages.length - 1,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons({bool isLastStep = false}) {
    return Container(
      padding: EdgeInsets.all(ThemeColor.paddingLarge),
      decoration:
          BoxDecoration(color: ThemeColor.backgroundColorfondo),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BOTÓN ATRÁS
          Obx(() => currentIndex.value > 0
              ? GestureDetector(
                  onTap: previousPage,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: ThemeColor.tertiaryColor,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                )
              : const SizedBox(width: 56)),

          // OMITIR
          GestureDetector(
            onTap: () async {
    await _markTutorialAsSeen(); // 👈
    Get.offAllNamed(RoutesNames.welcomePage);
  },
            child: Text(
              'Omitir',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // BOTÓN SIGUIENTE
          GestureDetector(
            onTap: nextPage,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ThemeColor.tertiaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLastStep ? Icons.check : Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}