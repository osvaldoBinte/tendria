import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendria/common/constants/constants.dart';

/// Posición relativa de un tooltip de tutorial
enum TutorialAnchor { top, bottom, left, right }

/// Modelo de cada paso del tutorial
class TutorialStep {
  final String message;
  final GlobalKey? targetKey;
  final TutorialAnchor anchor;
  final IconData icon;

  const TutorialStep({
    required this.message,
    this.targetKey,
    this.anchor = TutorialAnchor.bottom,
    this.icon = Icons.touch_app_rounded,
  });
}

class TutorialController extends GetxController {
  // ─── Estado ───────────────────────────────────────────────────────────────
  final RxBool isVisible      = false.obs;
  final RxInt  currentStep    = 0.obs;
  final RxBool isAnimatingOut = false.obs;

  // ─── Callback de scroll registrado por la pantalla ────────────────────────
  VoidCallback? onScrollToTarget;

  // ─── Claves globales para posicionar los tooltips ─────────────────────────
  final GlobalKey radarKey          = GlobalKey();
  final GlobalKey detectedPointsKey = GlobalKey();
  final GlobalKey searchButtonKey   = GlobalKey();
  final GlobalKey profileDotKey     = GlobalKey();

   late final List<TutorialStep> steps;

  @override
  void onInit() {
    super.onInit();

    steps = [
      TutorialStep(
        message: 'Aquí puedes ver quién está cerca de ti en tiempo real',
        targetKey: radarKey,
        anchor: TutorialAnchor.bottom,
        icon: Icons.radar,
      ),
      TutorialStep(
        message:
            'Te damos un grupo pequeño de perfiles cercanos para que puedas ver a cada persona',
        targetKey: detectedPointsKey,
        anchor: TutorialAnchor.top,
        icon: Icons.people_alt_rounded,
      ),
      TutorialStep(
        message: 'Vuelve a pulsar para ver más',
        targetKey: searchButtonKey,
        anchor: TutorialAnchor.top,
        icon: Icons.touch_app_rounded,
      ),
      TutorialStep(
        message: 'Pulsa para ver los perfiles',
        targetKey: profileDotKey,
        anchor: TutorialAnchor.bottom,
        icon: Icons.person_search_rounded,
      ),
    ];

    _checkAndShowTutorial();
  }
 
  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen  = prefs.getBool(AppConstants.tutorialKey) ?? false;
    if (!seen) {
      await Future.delayed(const Duration(milliseconds: 800));
      showTutorial();
    }
  }

  void showTutorial() {
    currentStep.value    = 0;
    isAnimatingOut.value = false;
    isVisible.value      = true;

     Future.delayed(const Duration(milliseconds: 300), () {
      onScrollToTarget?.call();
    });
  }

  void nextStep() {
    if (currentStep.value < steps.length - 1) {
      isAnimatingOut.value = true;
      Future.delayed(const Duration(milliseconds: 250), () {
        currentStep.value++;
        isAnimatingOut.value = false;
 
        onScrollToTarget?.call();
      });
    } else {
      _completeTutorial();
    }
  }

  void skipTutorial() => _completeTutorial();

  Future<void> _completeTutorial() async {
    isAnimatingOut.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isVisible.value      = false;
    isAnimatingOut.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.tutorialKey, true);
  }
 
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tutorialKey);
  }
 

  TutorialStep get currentStepData => steps[currentStep.value];

  bool get isLastStep => currentStep.value == steps.length - 1;
 
  Rect? getTargetRect(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }
}