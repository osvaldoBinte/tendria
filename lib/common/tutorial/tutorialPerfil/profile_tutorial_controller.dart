import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/tutorial/startTutorial/start_tutorial_controller.dart';
import 'package:tendria/common/settings/language_controller.dart';

enum TutorialAnchor { top, bottom, left, right }

class ProfileTutorialStep {
  final String message;
  final GlobalKey? targetKey;
  final TutorialAnchor anchor;

  const ProfileTutorialStep({
    required this.message,
    this.targetKey,
    this.anchor = TutorialAnchor.bottom,
  });
}

class ProfileTutorialController extends GetxController {
  final RxBool isVisible      = false.obs;
  final RxInt  currentStep    = 0.obs;
  final RxBool isAnimatingOut = false.obs;

  final GlobalKey blockedUsersKey  = GlobalKey();
  final GlobalKey notificationsKey = GlobalKey();
  final GlobalKey editProfileKey   = GlobalKey();
  final GlobalKey settingsKey      = GlobalKey();
  final GlobalKey creditsKey       = GlobalKey();
  final GlobalKey statusKey        = GlobalKey();

  late final List<ProfileTutorialStep> steps;

  static const String _prefKey = AppConstants.profileTutorialKey;

  @override
void onInit() {
  super.onInit();
  final l = Get.find<LanguageController>();
  steps = [
    ProfileTutorialStep(
      message: l.t('tutorial_profile_blocked'),
      targetKey: blockedUsersKey,
      anchor: TutorialAnchor.top,
    ),
    ProfileTutorialStep(
      message: l.t('tutorial_profile_notifications'),
      targetKey: notificationsKey,
      anchor: TutorialAnchor.top,
    ),
    ProfileTutorialStep(
      message: l.t('tutorial_profile_edit'),
      targetKey: editProfileKey,
      anchor: TutorialAnchor.top,
    ),
    ProfileTutorialStep(
      message: l.t('tutorial_profile_settings'),
      targetKey: settingsKey,
      anchor: TutorialAnchor.top,
    ),
    ProfileTutorialStep(
      message: l.t('tutorial_profile_credits'),
      targetKey: creditsKey,
      anchor: TutorialAnchor.top,
    ),
    ProfileTutorialStep(
      message: l.t('tutorial_profile_status'),
      targetKey: statusKey,
      anchor: TutorialAnchor.top,
    ),
  ];
   ever(Get.find<StartTutorialController>().completed, (bool done) {
    if (done) _checkAndShow();
  });
}
 
  void notifyPageReady() {
    _checkAndShow();
  }
 

Future<void> _checkAndShow() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_prefKey) ?? false) return;

  final startSeen = prefs.getBool(AppConstants.startTutorialKey) ?? false;
  if (!startSeen) return;

   if (blockedUsersKey.currentContext == null) {
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

ProfileTutorialStep get currentStepData {
  if (currentStep.value < 0 || currentStep.value >= steps.length) {
    return steps.last;
  }
  return steps[currentStep.value];
}  bool get isLastStep => currentStep.value == steps.length - 1;

  Rect? getTargetRect(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }
}