import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/settings/language_controller.dart';

enum TutorialAnchor { top, bottom, left, right }

class UpdateProfileTutorialStep {
  final String message;
  final GlobalKey? targetKey;
  final TutorialAnchor anchor;

  const UpdateProfileTutorialStep({
    required this.message,
    this.targetKey,
    this.anchor = TutorialAnchor.bottom,
  });
}

class UpdateProfileTutorialController extends GetxController {
  final RxBool isVisible      = false.obs;
  final RxInt  currentStep    = 0.obs;
  final RxBool isAnimatingOut = false.obs;

  final GlobalKey ageRangeKey    = GlobalKey();
  final GlobalKey maxDistanceKey = GlobalKey();

  late final List<UpdateProfileTutorialStep> steps;

  static const String _prefKey = AppConstants.updateProfileTutorialKey;

 @override
void onInit() {
  super.onInit();
  final l = Get.find<LanguageController>();
  steps = [
    UpdateProfileTutorialStep(
      message: l.t('tutorial_update_age'),
      targetKey: ageRangeKey,
      anchor: TutorialAnchor.top,
    ),
    UpdateProfileTutorialStep(
      message: l.t('tutorial_update_distance'),
      targetKey: maxDistanceKey,
      anchor: TutorialAnchor.top,
    ),
  ];
}

  void notifyPageReady() => _checkAndShow();

  Future<void> _checkAndShow() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) ?? false) return;

    await Future.delayed(const Duration(milliseconds: 400));

    if (ageRangeKey.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 300));
    }

    showTutorial();
  }

  void showTutorial() {
    currentStep.value    = 0;
    isAnimatingOut.value = false;
    isVisible.value      = true;
  }

  void nextStep() {
    if (currentStep.value < steps.length - 1) {
      isAnimatingOut.value = true;
      Future.delayed(const Duration(milliseconds: 250), () {
        currentStep.value++;
        isAnimatingOut.value = false;
      });
    } else {
      _complete();
    }
  }

  void skipTutorial() => _complete();

  Future<void> _complete() async {
    isAnimatingOut.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isVisible.value      = false;
    isAnimatingOut.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  UpdateProfileTutorialStep get currentStepData => steps[currentStep.value];
  bool get isLastStep => currentStep.value == steps.length - 1;

  Rect? getTargetRect(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}