import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
 
enum VipDialogType {
  unlocked,      
  invitation,      
  insufficientBalance, 
  purchaseSuccess,    
}
 
class VipFeedbackDialog extends StatelessWidget {
  final VipDialogType type;
  final String title;
  final String description;
 
  final Widget? extraContent;

  final String primaryLabel;
  final IconData? primaryIcon;
  final VoidCallback onPrimaryTap;

  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  const VipFeedbackDialog({
    Key? key,
    required this.type,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimaryTap,
    this.primaryIcon,
    this.extraContent,
    this.secondaryLabel,
    this.onSecondaryTap,
  }) : super(key: key);
 

  factory VipFeedbackDialog.unlocked({
    required VoidCallback onViewContent,
    required VoidCallback onBackHome,
    Widget? contentPreview,
  }) {
    return VipFeedbackDialog(
      type: VipDialogType.unlocked,
      title: 'Contenido desbloqueado',
      description:
          'Este contenido ahora está disponible de forma permanente.',
      extraContent: contentPreview,
      primaryLabel: 'VER CONTENIDO',
      primaryIcon: Icons.arrow_forward_rounded,
      onPrimaryTap: onViewContent,
      secondaryLabel: 'Volver al inicio',
      onSecondaryTap: onBackHome,
    );
  }

  factory VipFeedbackDialog.invitation({
    required int level,
    required VoidCallback onAccept,
    required VoidCallback onLater,
  }) {
    return VipFeedbackDialog(
      type: VipDialogType.invitation,
      title: 'Has recibido una invitación',
      description: 'Ahora puedes acceder a Nivel $level',
      primaryLabel: 'Aceptar invitación',
      onPrimaryTap: onAccept,
      secondaryLabel: 'Más tarde',
      onSecondaryTap: onLater,
    );
  }

  factory VipFeedbackDialog.insufficientBalance({
    required VoidCallback onBuyCredits,
    required VoidCallback onCancel,
  }) {
    return VipFeedbackDialog(
      type: VipDialogType.insufficientBalance,
      title: 'Saldo insuficiente',
      description:
          'No tienes suficientes créditos para desbloquear este contenido.',
      primaryLabel: 'Comprar créditos',
      onPrimaryTap: onBuyCredits,
      secondaryLabel: 'Cancelar',
      onSecondaryTap: onCancel,
    );
  }

  factory VipFeedbackDialog.purchaseSuccess({
    required int newBalance,
    required VoidCallback onContinue,
  }) {
    return VipFeedbackDialog(
      type: VipDialogType.purchaseSuccess,
      title: 'Compra exitosa',
      description: 'Tus créditos han sido añadidos a tu cuenta',
      extraContent: _BalanceBox(balance: newBalance),
      primaryLabel: 'Continuar',
      primaryIcon: Icons.arrow_forward_rounded,
      onPrimaryTap: onContinue,
    );
  }
 

  _VipDialogVisuals get _visuals {
    switch (type) {
      case VipDialogType.unlocked:
        return _VipDialogVisuals(
          icon: Icons.check_rounded,
          iconColor: Colors.black,
          iconBgColor: ThemeColor.primaryColor,
          cardColor: const Color(0xFF14100F),
          background: _DialogBackground.vipGradient,
          titleColor: ThemeColor.primaryColor,
          showParticles: false,
        );
      case VipDialogType.invitation:
        return _VipDialogVisuals(
          icon: Icons.star_rounded,
          iconColor: ThemeColor.primaryColor,
          iconBgColor: Colors.black,
          cardColor: const Color(0xFF5B4A2A),
          background: _DialogBackground.solidGold,
          titleColor: ThemeColor.primaryColor,
          showParticles: false,
        );
      case VipDialogType.insufficientBalance:
        return _VipDialogVisuals(
          icon: Icons.priority_high_rounded,
          iconColor: Colors.black,
          iconBgColor: ThemeColor.primaryColor,
          cardColor: const Color(0xFF0E0D10),
          background: _DialogBackground.dark,
          titleColor: Colors.white,
          showParticles: false,
        );
      case VipDialogType.purchaseSuccess:
        return _VipDialogVisuals(
          icon: Icons.check_rounded,
          iconColor: ThemeColor.primaryColor,
          iconBgColor: const Color(0xFF3A3020),
          cardColor: const Color(0xFF0E0D10),
          background: _DialogBackground.vipGradient,
          titleColor: Colors.white,
          showParticles: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _visuals;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [  
          Positioned.fill(child: _buildBackground(v.background)),
          if (v.showParticles) Positioned.fill(child: CustomPaint(painter: _ConfettiPainter())),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                  decoration: BoxDecoration(
                    color: v.cardColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [ 
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: v.iconBgColor.withOpacity(0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: v.iconBgColor.withOpacity(0.35),
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
                              color: v.iconBgColor,
                            ),
                            child: Icon(v.icon, color: v.iconColor, size: 28),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: v.titleColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.75),
                          height: 1.5,
                        ),
                      ),

                      if (extraContent != null) ...[
                        const SizedBox(height: 22),
                        extraContent!,
                      ],

                      const SizedBox(height: 28),
 
                      GestureDetector(
                        onTap: onPrimaryTap,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: ThemeColor.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  primaryLabel,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (primaryIcon != null) ...[
                                  const SizedBox(width: 6),
                                  Icon(primaryIcon, color: Colors.black, size: 18),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
 
                      if (secondaryLabel != null) ...[
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: onSecondaryTap,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: type == VipDialogType.insufficientBalance
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                secondaryLabel!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                  fontWeight: type == VipDialogType.insufficientBalance
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(_DialogBackground bg) {
    switch (bg) {
      case _DialogBackground.vipGradient:
        return Container(
          decoration: BoxDecoration(gradient: ThemeColor.vipBackgroundGradient),
        );
      case _DialogBackground.solidGold:
        return Container(color: const Color(0xFFC9A24B));
      case _DialogBackground.dark:
        return Container(color: const Color(0xFF16110C));
    }
  }
}

enum _DialogBackground { vipGradient, solidGold, dark }

class _VipDialogVisuals {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color cardColor;
  final _DialogBackground background;
  final Color titleColor;
  final bool showParticles;

  _VipDialogVisuals({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.cardColor,
    required this.background,
    required this.titleColor,
    required this.showParticles,
  });
}
 
class _BalanceBox extends StatelessWidget {
  final int balance;
  const _BalanceBox({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(
            'NUEVO SALDO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_rounded,
                  color: ThemeColor.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '$balance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(11);
    for (int i = 0; i < 26; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final isSquare = random.nextBool();
      final paintColor = [
        ThemeColor.primaryColor,
        Colors.white,
        Colors.white24,
      ][random.nextInt(3)];
      final paint = Paint()..color = paintColor.withOpacity(0.6);

      if (isSquare) {
        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(random.nextDouble() * math.pi);
        canvas.drawRect(const Rect.fromLTWH(-3, -3, 6, 6), paint);
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(dx, dy), random.nextDouble() * 2 + 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
 
Future<void> showVipDialog(VipFeedbackDialog dialog) {
  return Get.dialog(
    dialog,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.6),
  );
}