import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:tendria/common/theme/App_Theme.dart';
 
class giftSentSuccess extends StatelessWidget {
  final String giftName;
  final int giftValue;
  final int newBalance;
  final VoidCallback? onBackToChat;
  final VoidCallback? onViewAchievements;

  const giftSentSuccess({
    Key? key,
    required this.giftName,
    required this.giftValue,
    required this.newBalance,
    this.onBackToChat,
    this.onViewAchievements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [ 
          Positioned.fill(child: Container(color: Colors.black)),
 
          Positioned.fill(child: CustomPaint(painter: _StarsPainter())),
 
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      const Color(0xFFFFE49A),
                      const Color(0xFFD4AF37),
                      const Color(0xFFD4AF37).withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.25, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 200),
 
                  Text(
                    'Regalo Enviado con Éxito',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 14),
 
                  Text(
                    'Has iluminado el día de Tatendría con un detalle '
                    'exclusivo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),
 
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeColor.cardBackground.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemeColor.primaryColor.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'RESUMEN DEL REGALO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 1,
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ThemeColor.primaryColor.withOpacity(0.15),
                              ),
                              child: Icon(Icons.star_rounded,
                                  color: ThemeColor.primaryColor, size: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withOpacity(0.1), height: 1),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: 'Regalo',
                          valueWidget: Text(
                            giftName,
                            style: TextStyle(
                              color: ThemeColor.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: 'Valor',
                          valueWidget: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.monetization_on_rounded,
                                  color: ThemeColor.primaryColor, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                '$giftValue créditos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: 'Nuevo Saldo',
                          valueWidget: Text(
                            '$newBalance créditos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
 
                  GestureDetector(
                    onTap: onBackToChat ?? () => Get.back(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'VOLVER AL CHAT',
                          style: ThemeColor.buttonText.copyWith(
                            color: Colors.black,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
   
                  GestureDetector(
                    onTap: onViewAchievements ?? () {},
                    child: Text(
                      'VER MIS LOGROS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ThemeColor.primaryColor,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.underline,
                        decorationColor: ThemeColor.primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;

  const _SummaryRow({required this.label, required this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        valueWidget,
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);  
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 60; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height * 0.55; 
      final radius = random.nextDouble() * 1.4 + 0.3;
      paint.color = Colors.white.withOpacity(random.nextDouble() * 0.6 + 0.2);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}