import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RadarScannerScreen extends StatefulWidget {
  const RadarScannerScreen({Key? key}) : super(key: key);

  @override
  State<RadarScannerScreen> createState() => _RadarScannerScreenState();
}

class _RadarScannerScreenState extends State<RadarScannerScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _scanLineRotationController;

  final NearbyUsersController controller = Get.find<NearbyUsersController>();

  @override
  void initState() {
    super.initState();

    // Animación del radar giratorio (barrido)
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Animación de pulso
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Animación de ondas expansivas
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Animación de línea de escaneo girando
    _scanLineRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _scanLineRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      body: Stack(
        children: [
          // Fondo con efecto de grid
          _buildGridBackground(),

          // Contenido principal centrado
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingLarge,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Espaciador superior
                  const Spacer(flex: 2),

                  // Título
                  Text(
                    '¡Todo listo!',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingMedium),

                  // Descripción
                  Obx(() => Text(
                        controller.isLoading.value
                            ? 'Buscando conexiones...'
                            : 'Conexiones que están cerca de ti',
                        style: ThemeColor.bodyMedium.copyWith(
                          color: ThemeColor.textSecondaryColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      )),

                  SizedBox(height: ThemeColor.paddingExtraLarge * 2),

                  // Radar
                  SizedBox(
                    width: 350,
                    height: 350,
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ThemeColor.radarScanner,
                          ),
                        );
                      }

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ondas expansivas
                          _buildRippleEffect(),

                          // Círculos del radar
                          _buildRadarCircles(),

                          // Líneas de cruz (HORIZONTAL Y VERTICAL)
                          _buildCrosshair(),

                          // Efecto de barrido del radar
                          _buildRadarSweep(),

                          // Línea de escaneo girando alrededor del círculo
                          _buildRotatingScanLine(),

                          // Punto central con pulso
                          _buildCenterDot(),

                          // Puntos detectados con datos reales
                          _buildDetectedPoints(),
                        ],
                      );
                    }),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge * 2),

                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  await controller.loadNextBatch();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.tertiaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: ThemeColor.circularBorderRadius,
                            ),
                            elevation: 0,
                            disabledBackgroundColor:
                                ThemeColor.tertiaryColor.withOpacity(0.5),
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Ver perfiles cercanos',
                                  style: ThemeColor.buttonText
                                      .copyWith(fontSize: 16),
                                ),
                        ),
                      )),

                  SizedBox(height: ThemeColor.paddingMedium),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Get.offAllNamed(RoutesNames.homePage),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeColor.tertiaryColor,
                        side: BorderSide(
                          color: ThemeColor.tertiaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: ThemeColor.circularBorderRadius,
                        ),
                      ),
                      child: Text(
                        'Ver mi perfil',
                        style: ThemeColor.buttonText.copyWith(
                          fontSize: 16,
                          color: ThemeColor.tertiaryColor,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),

          // Indicadores laterales
          _buildSideIndicators(),
        ],
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      painter: GridPainter(),
      child: Container(),
    );
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            double delay = index * 0.33;
            double progress = (_rippleController.value + delay) % 1.0;
            return Opacity(
              opacity: 1 - progress,
              child: Container(
                width: 350 * progress,
                height: 350 * progress,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeColor.radarScanner.withOpacity(0.5),
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRadarCircles() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Círculo exterior
        Container(
          width: 350,
          height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ThemeColor.radarScanner.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: ThemeColor.radarScanner.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        // Círculo medio exterior
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ThemeColor.radarScanner.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        // Círculo medio
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ThemeColor.radarScanner.withOpacity(0.6),
              width: 2,
            ),
          ),
        ),
        // Círculo interior
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ThemeColor.radarScanner.withOpacity(0.7),
              width: 2,
            ),
          ),
        ),
        // Círculo central
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ThemeColor.radarScanner.withOpacity(0.8),
              width: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCrosshair() {
    return Stack(
      children: [
        // Línea HORIZONTAL
        Positioned(
          top: 175 - 1.5,
          left: 0,
          right: 0,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  ThemeColor.radarScanner.withOpacity(0.3),
                  ThemeColor.radarScanner.withOpacity(0.7),
                  ThemeColor.radarScanner,
                  ThemeColor.radarScanner.withOpacity(0.7),
                  ThemeColor.radarScanner.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeColor.radarScanner.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),

        // Línea VERTICAL
        Positioned(
          left: 175 - 1.5,
          top: 0,
          bottom: 0,
          child: Container(
            width: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  ThemeColor.radarScanner.withOpacity(0.3),
                  ThemeColor.radarScanner.withOpacity(0.7),
                  ThemeColor.radarScanner,
                  ThemeColor.radarScanner.withOpacity(0.7),
                  ThemeColor.radarScanner.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeColor.radarScanner.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadarSweep() {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _radarController.value * 2 * math.pi,
          child: CustomPaint(
            painter: RadarSweepPainter(),
            size: const Size(350, 350),
          ),
        );
      },
    );
  }

  Widget _buildRotatingScanLine() {
    return AnimatedBuilder(
      animation: _scanLineRotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _scanLineRotationController.value * 2 * math.pi,
          child: CustomPaint(
            painter: RotatingScanLinePainter(),
            size: const Size(350, 350),
          ),
        );
      },
    );
  }

  Widget _buildCenterDot() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double scale = 1 + (_pulseController.value * 0.5);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeColor.radarScanner,
              boxShadow: [
                BoxShadow(
                  color: ThemeColor.radarScanner
                      .withOpacity(1 - _pulseController.value),
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 Widget _buildDetectedPoints() {
  return Obx(() {
    final users = controller.currentRadarUsers;
    
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calcular posiciones basadas en distancia
    final points = _calculateUserPositions(users);

    return Stack(
      children: points.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value;
        final user = users[index];
        
        // PASAR EL ÍNDICE REAL DEL USUARIO
        return _buildDetectedPoint(
          point['x'] as double,
          point['y'] as double,
          point['delay'] as double,
          user,
          index,  // ← AGREGAR ESTE PARÁMETRO
        );
      }).toList(),
    );
  });
}

 List<Map<String, dynamic>> _calculateUserPositions(List<dynamic> users) {
  final positions = <Map<String, dynamic>>[];
  final random = math.Random();
  
  final int maxUsersToShow = math.min(users.length, 10);
  
  for (int i = 0; i < maxUsersToShow; i++) {
    final user = users[i];
    
    // Distribución en espiral (Fibonacci)
    final goldenAngle = math.pi * (3 - math.sqrt(5)); // ~137.5 grados
    double angle = i * goldenAngle;
    
    // Radio aumenta progresivamente
    double radius = 55 + (i * 12); // Empieza en 55px y crece 12px por usuario
    radius = radius.clamp(55.0, 160.0);
    
    // Añadir pequeña variación aleatoria
    angle += (random.nextDouble() - 0.5) * 0.4;
    radius += (random.nextDouble() - 0.5) * 10;
    
    // Calcular posición
    double x = radius * math.cos(angle);
    double y = radius * math.sin(angle);
    
    positions.add({
      'x': x,
      'y': y,
      'delay': i * 0.15,
    });
  }
  
  return positions;
}

Widget _buildDetectedPoint(
  double x, 
  double y, 
  double delay, 
  dynamic user,
  int userIndex,
) {
  return AnimatedBuilder(
    animation: _pulseController,
    builder: (context, child) {
      double progress = (_pulseController.value + delay) % 1.0;
      double scale = 1 + (progress * 0.3);
      double opacity = 1 - (progress * 0.5);

      return Transform.translate(
        offset: Offset(x, y),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Onda expansiva del punto (SIN GestureDetector)
               /* Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeColor.radarScanner
                            .withOpacity(opacity * 0.6),
                        width: 2,
                      ),
                    ),
                  ),
                ),*/
                
                // GestureDetector SOLO en la foto
                GestureDetector(  behavior: HitTestBehavior.opaque, // ← IMPORTANTE
                  onTap: () {
                    print('Click en usuario: ${user.name}, índice: $userIndex');
                    print('Total usuarios: ${controller.currentRadarUsers.length}');
                    
                    // Usar el índice que pasamos como parámetro
                    controller.currentUserIndex.value = userIndex;
                    controller.updateCurrentProfile();
                    
                    // Verificar que el perfil se haya actualizado
                    print('Perfil actualizado: ${controller.profile.value.name}');
                    
                    Get.toNamed(RoutesNames.profileDetailPage);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeColor.radarScanner,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeColor.radarScanner.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: user.fotoUrl != null && user.fotoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: user.fotoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: ThemeColor.radarScanner.withOpacity(0.3),
                                child: Icon(
                                  Icons.person,
                                  color: ThemeColor.radarScanner,
                                  size: 20,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: ThemeColor.radarScanner.withOpacity(0.3),
                                child: Icon(
                                  Icons.person,
                                  color: ThemeColor.radarScanner,
                                  size: 20,
                                ),
                              ),
                            )
                          : Container(
                              color: ThemeColor.radarScanner.withOpacity(0.3),
                              child: Icon(
                                Icons.person,
                                color: ThemeColor.radarScanner,
                                size: 20,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Nombre y edad (sin GestureDetector)
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ThemeColor.backgroundColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemeColor.radarScanner.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                '${user.name ?? 'Usuario'}, ${user.age ?? 0}',
                style: TextStyle(
                  color: ThemeColor.radarScanner,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    },
  );
}
  Widget _buildSideIndicators() {
    return Stack(
      children: [
        // Indicador izquierdo
        Positioned(
          left: 20,
          top: MediaQuery.of(context).size.height / 2 - 100,
          child: _buildVerticalIndicator(),
        ),
        // Indicador derecho
        Positioned(
          right: 20,
          top: MediaQuery.of(context).size.height / 2 - 100,
          child: _buildVerticalIndicator(),
        ),
      ],
    );
  }

  Widget _buildVerticalIndicator() {
    return AnimatedBuilder(
      animation: _scanLineRotationController,
      builder: (context, child) {
        return Column(
          children: List.generate(10, (index) {
            bool isActive =
                (_scanLineRotationController.value * 10).floor() == index;
            return Container(
              width: 4,
              height: 16,
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? ThemeColor.radarScanner
                    : ThemeColor.radarScanner.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: ThemeColor.radarScanner.withOpacity(0.8),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }
}

// Painters permanecen igual...
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeColor.radarScanner.withOpacity(0.08)
      ..strokeWidth = 1;

    double spacing = 30;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarSweepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final gradient = SweepGradient(
      colors: [
        ThemeColor.radarScanner.withOpacity(0.0),
        ThemeColor.radarScanner.withOpacity(0.3),
        ThemeColor.radarScanner.withOpacity(0.6),
        ThemeColor.radarScanner.withOpacity(0.0),
      ],
      stops: const [0.0, 0.3, 0.5, 1.0],
      startAngle: 0,
      endAngle: math.pi * 2,
    );

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RotatingScanLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          ThemeColor.radarScanner.withOpacity(0.1),
          ThemeColor.radarScanner.withOpacity(0.6),
          ThemeColor.radarScanner,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(
        Rect.fromLTWH(center.dx, center.dy - 1.5, radius, 3),
      )
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(center.dx + radius, center.dy),
      paint,
    );

    final glowPaint = Paint()
      ..color = ThemeColor.radarScanner
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(center.dx + radius, center.dy), 4, glowPaint);

    canvas.drawCircle(
      Offset(center.dx + radius, center.dy),
      2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}