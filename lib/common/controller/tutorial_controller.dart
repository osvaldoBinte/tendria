import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendria/common/constants/constants.dart';


/// Posición relativa de un tooltip de tutorial
enum TutorialAnchor { top, bottom, left, right }

/// Modelo de cada paso del tutorial
class TutorialStep {
  final String message;
  final GlobalKey? targetKey;   // la clave del widget que se destaca
  final TutorialAnchor anchor;  // dónde aparece el globo de diálogo
  final IconData icon;          // icono decorativo del globo

  const TutorialStep({
    required this.message,
    this.targetKey,
    this.anchor = TutorialAnchor.bottom,
    this.icon = Icons.touch_app_rounded,
  });
}

class TutorialController extends GetxController {
  // ─── Estado ───────────────────────────────────────────────────────────────
  final RxBool isVisible       = false.obs;
  final RxInt  currentStep     = 0.obs;
  final RxBool isAnimatingOut  = false.obs;

  // ─── Claves globales para posicionar los tooltips ─────────────────────────
  /// Radar completo (toda la pantalla)
  final GlobalKey radarKey         = GlobalKey();
  /// Contenedor de los puntos/perfiles detectados
  final GlobalKey detectedPointsKey = GlobalKey();
  /// Botón "Buscar perfiles"
  final GlobalKey searchButtonKey  = GlobalKey();
  /// Un avatar de perfil cualquiera en el radar
  final GlobalKey profileDotKey    = GlobalKey();

  // ─── Pasos del tutorial ───────────────────────────────────────────────────
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

  // ─── Lógica ───────────────────────────────────────────────────────────────

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen  = prefs.getBool(AppConstants.tutorialKey) ?? false;
    if (!seen) {
      // Pequeño delay para que la pantalla termine de construirse
      await Future.delayed(const Duration(milliseconds: 800));
      showTutorial();
    }
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

  /// Permite resetear el tutorial desde ajustes (útil en desarrollo)
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tutorialKey);
  }

  // ─── Helpers de UI ────────────────────────────────────────────────────────

  TutorialStep get currentStepData => steps[currentStep.value];

  bool get isLastStep => currentStep.value == steps.length - 1;

  /// Devuelve el Rect del widget apuntado (null si no se encontró)
  Rect? getTargetRect(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }
}