import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tendria/common/controller/tutorial_controller.dart';
import 'package:tendria/common/controller/tutorial_overlay.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/presentation/controller/nearby_users_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';
import 'package:tendria/features/user/presentation/controller/update_profile_controller.dart';

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

  final ScrollController _scrollController = ScrollController();
  final UpdateProfileController _updater = Get.find<UpdateProfileController>();
  final NearbyUsersController controller = Get.find<NearbyUsersController>();
  final TutorialController tutorialCtrl = Get.find<TutorialController>();
  LanguageController get _l => Get.find<LanguageController>();

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _scanLineRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    tutorialCtrl.onScrollToTarget = _scrollToCurrentTarget;
  }

  @override
  void dispose() {
    tutorialCtrl.onScrollToTarget = null;
    _scrollController.dispose();
    _radarController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _scanLineRotationController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTarget() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final step = tutorialCtrl.currentStepData;
      if (step.targetKey == null) return;

      final ctx = step.targetKey!.currentContext;
      if (ctx == null) return;

      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    });
  }

  // ─── ESTADOS ────────────────────────────────────────────────────────────────

  /// Estado: permiso de ubicación denegado
  Widget _buildLocationPermissionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 72,
                color: ThemeColor.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _l.t('location_required_title'),
              style: ThemeColor.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _l.t('location_required_desc'),
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final granted = await controller.checkLocationPermission();
                  if (!granted) {
                    await Geolocator.openAppSettings();
                  } else {
                    controller.loadNearbyUsers();
                  }
                },
                icon: const Icon(Icons.location_on_rounded, color: Colors.white),
                label: Text(
                  _l.t('enable_location'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado: sin más usuarios / lista vacía
  Widget _buildNoMoreUsersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 72,
                color: ThemeColor.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _l.t('no_more_profiles'),
              style: ThemeColor.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _l.t('no_more_profiles_desc'),
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Slider de distancia (reutilizado aquí también)
            Obx(() {
              final profileCtrl = Get.find<ProfileController>();
              final km =
                  profileCtrl.userEntity.value?.preferences?.distancekm ?? 50;
              return KeyedSubtree(
                key: tutorialCtrl.distanceSliderKey,
                child: _DistanceSlider(
                  initialKm: km,
                  updater: _updater,
                  l: _l,
                ),
              );
            }),

            SizedBox(height: ThemeColor.paddingSmall),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Get.toNamed(RoutesNames.updateProfilePage),
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                label: Text(
                  _l.t('modify_preferences'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  controller.noMoreUsers.value = false;
                  controller.loadNearbyUsers();
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: ThemeColor.primaryColor,
                ),
                label: Text(
                  _l.t('try_again'),
                  style: TextStyle(
                    color: ThemeColor.primaryColor,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: ThemeColor.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado principal: radar con usuarios
  Widget _buildMainContent() {
    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingLarge,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: ThemeColor.paddingLarge),

                  Image.asset(
                    'assets/logo/logo.png',
                    width: 100,
                    height: 100,
                  ),

                  SizedBox(height: ThemeColor.paddingSmall),

                  Obx(() {
                    final profileCtrl = Get.find<ProfileController>();
                    final km =
                        profileCtrl
                            .userEntity
                            .value
                            ?.preferences
                            ?.distancekm ??
                        50;
                    return KeyedSubtree(
                      key: tutorialCtrl.distanceSliderKey,
                      child: _DistanceSlider(
                        initialKm: km,
                        updater: _updater,
                        l: _l,
                      ),
                    );
                  }),

                  SizedBox(height: ThemeColor.paddingSmall),

                  Obx(
                    () => Text(
                      controller.isLoading.value
                          ? _l.t('searching')
                          : _l.t('nearby'),
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondaryColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingLarge),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final size = math.min(constraints.maxWidth, 350.0);
                      return SizedBox(
                        width: size,
                        height: size,
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
                              Image.asset(
                                'assets/gift/gitf.gif',
                                width: size,
                                height: size,
                                fit: BoxFit.contain,
                              ),
                              _buildDetectedPoints(),
                            ],
                          );
                        }),
                      );
                    },
                  ),

                  SizedBox(height: ThemeColor.paddingLarge),
                  SizedBox(height: ThemeColor.paddingLarge),
                  SizedBox(height: ThemeColor.paddingLarge),

                  Obx(
                    () => SizedBox(
                      key: tutorialCtrl.searchButtonKey,
                      width: double.infinity,
                      height: 52,
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
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _l.t('search_btn'),
                                style: ThemeColor.buttonText.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingMedium),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () =>
                          Get.offAllNamed(RoutesNames.homePage),
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
                        _l.t('view_profile'),
                        style: ThemeColor.buttonText.copyWith(
                          fontSize: 16,
                          color: ThemeColor.tertiaryColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingLarge),
                ],
              ),
            ),
          ),
        ),

        // Tutorial overlay — solo cuando está visible
        Obx(
          () => tutorialCtrl.isVisible.value
              ? const TutorialOverlay()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ─── BUILD PRINCIPAL ────────────────────────────────────────────────────────
  // Un único Scaffold raíz para que los snackbars siempre tengan dónde anclarse
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      body: Obx(() {
        // 1. Sin permiso de ubicación
        if (controller.locationPermissionDenied.value) {
          return _buildLocationPermissionState();
        }

        // 2. Sin más usuarios / lista vacía
        if (controller.noMoreUsers.value ||
            (!controller.isLoading.value &&
                controller.nearbyUsers.isEmpty)) {
          return _buildNoMoreUsersState();
        }

        // 3. Estado normal con radar
        return _buildMainContent();
      }),
    );
  }

  // ─── PUNTOS DETECTADOS ──────────────────────────────────────────────────────

  Widget _buildDetectedPoints() {
    return Obx(() {
      final users = controller.currentRadarUsers;
      if (users.isEmpty) return const SizedBox.shrink();

      final points = _calculateUserPositions(users);

      return SizedBox(
        key: tutorialCtrl.detectedPointsKey,
        width: 350,
        height: 350,
        child: Stack(
          clipBehavior: Clip.none,
          children: points
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final point = entry.value;
                final user = users[index];
                return _buildDetectedPoint(
                  point['x'] as double,
                  point['y'] as double,
                  point['delay'] as double,
                  user,
                  index,
                );
              })
              .toList()
              .reversed
              .toList(),
        ),
      );
    });
  }

  List<Map<String, dynamic>> _calculateUserPositions(
    List<GetUserEntity> users,
  ) {
    final positions = <Map<String, dynamic>>[];
    final random = math.Random();
    final int maxUsersToShow = math.min(users.length, 10);

    for (int i = 0; i < maxUsersToShow; i++) {
      final goldenAngle = math.pi * (3 - math.sqrt(5));
      double angle = i * goldenAngle;
      double radius = 70 + (i * 18);
      radius = radius.clamp(70.0, 165.0);
      angle += (random.nextDouble() - 0.5) * 0.6;
      radius += (random.nextDouble() - 0.5) * 15;
      double x = radius * math.cos(angle);
      double y = radius * math.sin(angle);
      positions.add({'x': x, 'y': y, 'delay': i * 0.15});
    }
    return positions;
  }

  Widget _buildDetectedPoint(
    double x,
    double y,
    double delay,
    GetUserEntity user,
    int userIndex,
  ) {
    final bool isFirstProfile = userIndex == 0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Positioned(
          left: 175 + x - 35,
          top: 175 + y - 45,
          child: GestureDetector(
            key: isFirstProfile ? tutorialCtrl.profileDotKey : null,
            behavior: HitTestBehavior.translucent,
            onTap: () =>
                controller.showUserPreviewDialog(user, userIndex),
            child: SizedBox(
              width: 70,
              height: 110,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (user.status != null && user.status!.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 70),
                      margin: const EdgeInsets.only(bottom: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            ThemeColor.backgroundColor.withOpacity(0.92),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                          bottomLeft: Radius.circular(2),
                        ),
                        border: Border.all(
                          color:
                              ThemeColor.radarScanner.withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeColor.radarScanner
                                .withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        user.status!,
                        style: TextStyle(
                          color: ThemeColor.radarScanner,
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
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
                              color: ThemeColor.radarScanner
                                  .withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user.fotoUrl != null &&
                                  user.fotoUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: user.fotoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _avatarPlaceholder(),
                                  errorWidget: (context, url, error) =>
                                      _avatarPlaceholder(),
                                )
                              : _avatarPlaceholder(),
                        ),
                      ),

                      if (isFirstProfile)
                        Obx(() {
                          if (!tutorialCtrl.isVisible.value ||
                              tutorialCtrl.currentStep.value != 3) {
                            return const SizedBox.shrink();
                          }
                          return Positioned(
                            right: -8,
                            top: -8,
                            child: _PulsingTouchIcon(
                              color: ThemeColor.tertiaryColor,
                            ),
                          );
                        }),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 70),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            ThemeColor.backgroundColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              ThemeColor.radarScanner.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name ?? _l.t('user'),
                            style: TextStyle(
                              color: ThemeColor.radarScanner,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${user.age ?? 0} ${_l.t('years')}',
                            style: TextStyle(
                              color: ThemeColor.radarScanner
                                  .withOpacity(0.7),
                              fontSize: 7,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: ThemeColor.radarScanner.withOpacity(0.3),
      child: Icon(
        Icons.person,
        color: ThemeColor.radarScanner,
        size: 20,
      ),
    );
  }
}

// ─── DISTANCE SLIDER ──────────────────────────────────────────────────────────

class _DistanceSlider extends StatefulWidget {
  final double initialKm;
  final UpdateProfileController updater;
  final LanguageController l;

  const _DistanceSlider({
    required this.initialKm,
    required this.updater,
    required this.l,
  });

  @override
  State<_DistanceSlider> createState() => _DistanceSliderState();
}

class _DistanceSliderState extends State<_DistanceSlider> {
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialKm.clamp(0.1, 300.0);
  }

  @override
  void didUpdateWidget(_DistanceSlider old) {
    super.didUpdateWidget(old);
    final newKm = widget.initialKm.clamp(0.1, 300.0);
    if ((newKm - _current).abs() > 0.05) {
      setState(() => _current = newKm);
    }
  }

  String get _label {
    if (_current >= 300) return widget.l.t('no_limit');
    if (_current < 1) return '${(_current * 1000).toInt()} m';
    return '${_current.toStringAsFixed(_current == _current.roundToDouble() ? 0 : 1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ThemeColor.paddingSmall),
      padding: EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: ThemeColor.largeBorderRadius,
        border: Border.all(
          color: ThemeColor.radarScanner.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.radar,
                    size: 16,
                    color: ThemeColor.radarScanner,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.l.t('max_distance'),
                    style: ThemeColor.bodySmall.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                _label,
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.radarScanner,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ThemeColor.radarScanner,
              inactiveTrackColor:
                  ThemeColor.radarScanner.withOpacity(0.2),
              thumbColor: ThemeColor.radarScanner,
              overlayColor: ThemeColor.radarScanner.withOpacity(0.15),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _current,
              min: 0.1,
              max: 300,
              divisions: 2990,
              onChanged: (value) => setState(() => _current = value),
              onChangeEnd: (value) =>
                  widget.updater.updateDistance(value),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PULSING TOUCH ICON ───────────────────────────────────────────────────────

class _PulsingTouchIcon extends StatefulWidget {
  final Color color;
  const _PulsingTouchIcon({required this.color});

  @override
  State<_PulsingTouchIcon> createState() => _PulsingTouchIconState();
}

class _PulsingTouchIconState extends State<_PulsingTouchIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PAINTERS ─────────────────────────────────────────────────────────────────

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeColor.radarScanner.withOpacity(0.08)
      ..strokeWidth = 1;
    const double spacing = 30;
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
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          ThemeColor.radarScanner.withOpacity(0.0),
          ThemeColor.radarScanner.withOpacity(0.3),
          ThemeColor.radarScanner.withOpacity(0.6),
          ThemeColor.radarScanner.withOpacity(0.0),
        ],
        stops: const [0.0, 0.3, 0.5, 1.0],
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
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
          Rect.fromLTWH(center.dx, center.dy - 1.5, radius, 3))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        center, Offset(center.dx + radius, center.dy), paint);

    final glowPaint = Paint()
      ..color = ThemeColor.radarScanner
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
        Offset(center.dx + radius, center.dy), 4, glowPaint);
    canvas.drawCircle(
      Offset(center.dx + radius, center.dy),
      2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}