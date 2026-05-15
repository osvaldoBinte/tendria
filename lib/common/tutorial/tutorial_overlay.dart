import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'tutorial_controller.dart';

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TutorialController>();

    return Obx(() {
      if (!ctrl.isVisible.value) return const SizedBox.shrink();

      final step = ctrl.currentStepData;
      final targetRect = step.targetKey != null
          ? ctrl.getTargetRect(step.targetKey!)
          : null;

      return Stack(
        children: [
          GestureDetector(
            onTap: ctrl.nextStep,
            child: Container(color: Colors.black.withOpacity(0.58)),
          ),

          if (targetRect != null)
            Positioned.fromRect(
              rect: targetRect.inflate(8),
              child: GestureDetector(
                onTap: ctrl.nextStep,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ThemeColor.tertiaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColor.tertiaryColor.withOpacity(0.35),
                        blurRadius: 18,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          _buildTooltip(context, ctrl, step, targetRect),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: ctrl.skipTutorial,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Get.find<LanguageController>().t('tutorial_skip'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),

         /* Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(ctrl.steps.length, (i) {
                  final active = i == ctrl.currentStep.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? ThemeColor.tertiaryColor : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),*/
        ],
      );
    });
  }

  Widget _buildTooltip(
    BuildContext context,
    TutorialController ctrl,
    TutorialStep step,
    Rect? targetRect,
  ) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    const double iconSize = 52.0;
    const double iconBoxH = 64.0;
    const double bubbleH = 72.0;
    const double totalH = iconBoxH + bubbleH;
    const double horizontalPad = 24.0;

    double top;
    bool iconAbove;

    if (targetRect != null) {
      switch (step.anchor) {
        case TutorialAnchor.bottom:
          iconAbove = false;
          top = targetRect.top - totalH - 12;
          break;

        case TutorialAnchor.top:
          iconAbove = true;
          top = targetRect.bottom + 12;
          break;

        default:
          iconAbove = true;
          top = screenH / 2 - totalH / 2;
      }
    } else {
      iconAbove = true;
      top = screenH / 2 - totalH / 2;
    }

    top = top.clamp(topPad + 60.0, screenH - totalH - 80.0);

    double centerX = targetRect != null
        ? (targetRect.left + targetRect.right) / 2
        : screenW / 2;

    const double bubbleMaxW = 280.0;
    double bubbleLeft = (centerX - bubbleMaxW / 2).clamp(
      horizontalPad,
      screenW - bubbleMaxW - horizontalPad,
    );

    return Obx(
      () => AnimatedOpacity(
        opacity: ctrl.isAnimatingOut.value ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 220),
        child: Stack(
          children: [
            Positioned(
              top: iconAbove ? top : top + bubbleH,

              left: (centerX - iconSize / 2).clamp(
                horizontalPad,
                screenW - iconSize - horizontalPad,
              ),
              child: GestureDetector(
                onTap: ctrl.nextStep,
                child: _BouncingClickIcon(
                  size: iconSize,
                  flipVertical: !iconAbove,
                ),
              ),
            ),

            Positioned(
              top: iconAbove ? top + iconBoxH : top,
              left: bubbleLeft,
              width: bubbleMaxW,
              child: GestureDetector(
                onTap: ctrl.nextStep,
                child: _DialogBubble(
                  message: step.message,
                  isLast: ctrl.isLastStep,
                  accentColor: ThemeColor.tertiaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncingClickIcon extends StatefulWidget {
  final double size;
  final bool flipVertical;
  const _BouncingClickIcon({required this.size, this.flipVertical = false});

  @override
  State<_BouncingClickIcon> createState() => _BouncingClickIconState();
}

class _BouncingClickIconState extends State<_BouncingClickIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _bounce = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, __) {
        final dy = widget.flipVertical ? -_bounce.value : _bounce.value;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scaleY: widget.flipVertical ? -1.0 : 1.0,
            child: Image.asset(
              'assets/clik.png',
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class _DialogBubble extends StatelessWidget {
  final String message;
  final bool isLast;
  final Color accentColor;

  const _DialogBubble({
    required this.message,
    required this.isLast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: ThemeColor.textPrimaryColor,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            isLast
                ? Icons.check_circle_outline_rounded
                : Icons.arrow_forward_ios_rounded,
            color: accentColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}
