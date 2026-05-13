import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/controller/startTutorial/start_tutorial_controller.dart';
import 'package:tendria/common/settings/language_controller.dart';
 
enum TutorialAnchor { top, bottom, left, right }
 
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
  final RxBool isVisible      = false.obs;
  final RxInt  currentStep    = 0.obs;
  final RxBool isAnimatingOut = false.obs;
 
  VoidCallback? onScrollToTarget;
 
  final GlobalKey distanceSliderKey = GlobalKey();
  final GlobalKey detectedPointsKey = GlobalKey();
  final GlobalKey searchButtonKey   = GlobalKey();
  final GlobalKey profileDotKey     = GlobalKey();
 
  bool _pendingShow = false;
  bool _usersReady  = false;
 
  late final List<TutorialStep> steps;
  @override
void onInit() {
  super.onInit();
  final l = Get.find<LanguageController>();
  steps = [
    TutorialStep(
      message: l.t('tutorial_radar_slider'),
      targetKey: distanceSliderKey,
      anchor: TutorialAnchor.bottom,
      icon: Icons.radar,
    ),
    TutorialStep(
      message: l.t('tutorial_radar_points'),
      targetKey: detectedPointsKey,
      anchor: TutorialAnchor.top,
      icon: Icons.people_alt_rounded,
    ),
    TutorialStep(
      message: l.t('tutorial_radar_search'),
      targetKey: searchButtonKey,
      anchor: TutorialAnchor.top,
      icon: Icons.touch_app_rounded,
    ),
    TutorialStep(
      message: l.t('tutorial_radar_profile'),
      targetKey: profileDotKey,
      anchor: TutorialAnchor.bottom,
      icon: Icons.person_search_rounded,
    ),
  ];
   ever(Get.find<StartTutorialController>().completed, (bool done) {
    if (done) _checkAndShowTutorial();
  });
}
 
void notifyPageReady() {
  _checkAndShowTutorial();
}
Future<void> _checkAndShowTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  final seen  = prefs.getBool(AppConstants.tutorialKey) ?? false;
  if (seen) return;

  final startSeen = prefs.getBool(AppConstants.startTutorialKey) ?? false;
  if (!startSeen) return;
 
  if (_usersReady) {
    showTutorial();
  } else {
    _pendingShow = true;
  }
}
 
  void notifyUsersReady() {
    _usersReady = true;
    if (_pendingShow) {
      _pendingShow = false;
      Future.delayed(const Duration(milliseconds: 300), () {
        showTutorial();
      });
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
      final nextIndex    = currentStep.value + 1;
      final nextStepData = steps[nextIndex];
  
      if (nextStepData.targetKey == profileDotKey) {
        final ctx = profileDotKey.currentContext;
        if (ctx == null) {
          _completeTutorial();
          return;
        }
        final box = ctx.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) {
          _completeTutorial();
          return;
        }
      }

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