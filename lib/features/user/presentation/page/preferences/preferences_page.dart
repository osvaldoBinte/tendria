// lib/features/user/presentation/page/preferences/preferences_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/auth/presentation/page/home/start_page.dart';
import 'package:tendria/features/user/domain/entities/preferences_step.dart';
import 'package:tendria/features/user/presentation/controller/preferences_controller.dart';
import 'package:tendria/features/user/presentation/page/radarscanner/radar_scanner_page.dart';
import 'package:tendria/features/user/presentation/profiledetail/profile_detail_page.dart';
import 'package:tendria/features/user/presentation/widget/AgeWheelWidget.dart';
import 'package:tendria/features/user/presentation/widget/DistanceWheelWidget.dart';

class PreferencesPage extends GetView<PreferencesController> {
  const PreferencesPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.backgroundColorfondo,
      body: SafeArea(
        child: Obx(() {
          if (!controller.isInitialized.value ||
              controller.isLoadingUserData.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeColor.primaryColor,
                ),
              ),
            );
          }

           if (controller.showSuccessScreen.value) {
            return RadarScannerScreen();
          }

          if (controller.availableSteps.isEmpty) {
            return RadarScannerScreen();
          }

          switch (controller.currentStep.value) {
            case PreferencesStep.genderPreference:
              return _buildGenderPreferenceStep();
            case PreferencesStep.connectionType:
              return _buildConnectionTypeStep();
            case PreferencesStep.ageRange:
              return _buildAgeRangeStep();
            case PreferencesStep.photos:
              return _buildPhotosStep();
            case PreferencesStep.interests:
              return _buildInterestsStep();
            case PreferencesStep.qualities:
              return _buildQualitiesStep();
          }
        }),
      ),
    );
  }

  // ==========================================
  // PASO 1: PREFERENCIA DE GÉNERO
  // ==========================================
  Widget _buildGenderPreferenceStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Header
                  Text(
                    '¿Qué tipo de personas te\ngustaría conocer?',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    'Esta preferencia es flexible y editable más\nadelante.',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Opciones de género
                  // Opciones de género
                  ...controller.genderOptions.map((option) {
                    return Column(
                      children: [
                        _buildGenderPreferenceOption(
                          option['icon'] as IconData, // ← icon primero
                          option['label'], // ← label segundo
                          option['value'], // ← value tercero
                          hasCustomInput: option['hasCustomInput'] ?? false,
                        ),
                        SizedBox(height: ThemeColor.paddingSmall),
                      ],
                    );
                  }).toList(),
                  SizedBox(height: ThemeColor.paddingLarge),

                  // Nota informativa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: ThemeColor.textSecondaryColor,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Te mostraremos perfiles compatibles con tus preferencias.',
                          style: ThemeColor.bodySmall.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildGenderPreferenceOption(
    IconData icon,
    String label,
    String value, {
    bool hasCustomInput = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedGenderPreference.value == value;

      return GestureDetector(
        onTap: () => controller.selectGenderPreference(value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ThemeColor.primaryColor
                  : ThemeColor.textSecondaryColor,
            ),
            color: isSelected
                ? ThemeColor.primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? ThemeColor.tertiaryColor
                    : ThemeColor.textSecondaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(child: Text(label)),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? ThemeColor.primaryColor
                    : ThemeColor.textSecondaryColor,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==========================================
  // PASO 2: TIPO DE CONEXIÓN
  // ==========================================
  Widget _buildConnectionTypeStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Header
                  Text(
                    '¿Qué tipo de conexión\nquieres?',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    'Selecciona hasta dos opciones que vayan\ncontigo.',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Opciones de conexión
                  ...controller.connectionOptions.map((option) {
                    return Column(
                      children: [
                        _buildConnectionOption(
                          option['label'],
                          option['value'],
                        ),
                        SizedBox(height: ThemeColor.paddingSmall),
                      ],
                    );
                  }).toList(),

                  SizedBox(height: ThemeColor.paddingLarge),

                  // Nota informativa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: ThemeColor.textSecondaryColor,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mostraremos esta preferencia para mejorar tus coincidencias.',
                          style: ThemeColor.bodySmall.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildConnectionOption(String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedConnectionType.value == value;

      return InkWell(
        onTap: () => controller.selectConnectionType(value),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingLarge,
            vertical: ThemeColor.paddingMedium + 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ThemeColor.mediumBorderRadius,
            border: isSelected
                ? Border.all(color: ThemeColor.tertiaryColor, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textDarkColor,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? ThemeColor.tertiaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? ThemeColor.tertiaryColor
                        : ThemeColor.textSecondaryColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.circle, color: Colors.white, size: 12)
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==========================================
  // PASO 3: RANGO DE EDAD Y DISTANCIA
  // ==========================================

  Widget _buildAgeRangeStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  Text(
                    '¿Qué rango de edad\nprefieres?',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    'Puedes ajustar esto más tarde.',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Labels
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'Mínimo',
                            style: ThemeColor.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.textDarkColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Máximo',
                            style: ThemeColor.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.textDarkColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),

                  // Ruedas de edad
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IgnorePointer(
                          child: Container(
                            height: 60,
                            margin: EdgeInsets.symmetric(
                              horizontal: ThemeColor.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: ThemeColor.extraLargeBorderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            // Edad mínima
                            Expanded(
                              child: AgeWheelWidget(
                                initialAge: controller.minAge.value,
                                onChanged: (age) {
                                  controller.updateMinAge(age);
                                  if (age > controller.maxAge.value) {
                                    controller.updateMaxAge(age);
                                  }
                                },
                              ),
                            ),
                            // Edad máxima
                            Expanded(
                              child: AgeWheelWidget(
                                initialAge: controller.maxAge.value,
                                onChanged: (age) {
                                  controller.updateMaxAge(age);
                                  if (age < controller.minAge.value) {
                                    controller.updateMinAge(age);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Label selección actual
                  Obx(
                    () => Center(
                      child: Text(
                        'De ${controller.minAge.value} a ${controller.maxAge.value} años',
                        style: ThemeColor.bodyMedium.copyWith(
                          color: ThemeColor.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Distancia
                  Text(
                    'Distancia máxima',
                    style: ThemeColor.headingSmall.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Obx(
                    () => Text(
                      controller.distanceKm.value >= 300
                          ? 'Sin límite de distancia'
                          : 'Hasta ${controller.distanceKm.value} km',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingMedium),

                  // Rueda de distancia
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IgnorePointer(
                          child: Container(
                            height: 60,
                            margin: EdgeInsets.symmetric(
                              horizontal: ThemeColor.paddingExtraLarge * 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: ThemeColor.extraLargeBorderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DistanceWheelWidget(
                          initialDistance: controller.distanceKm.value,
                          onChanged: (km) => controller.updateDistance(km),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),
                ],
              ),
            ),
          ),
        ),
        _buildNavigationButtons(),
      ],
    );
  }

  // Rueda de edad reutilizable
  Widget _buildAgeWheel({
    required int initialAge,
    required void Function(int age) onChanged,
  }) {
    final scrollController = FixedExtentScrollController(
      initialItem: (initialAge - 18).clamp(0, 62),
    );
    final RxInt selected = initialAge.obs;

    return ListWheelScrollView.useDelegate(
      controller: scrollController,
      itemExtent: 60,
      diameterRatio: 1.5,
      perspective: 0.003,
      physics: FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        selected.value = 18 + index;
        onChanged(18 + index);
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 63, // 18 a 80
        builder: (context, index) {
          return Obx(() {
            final isSelected = index == selected.value - 18;
            return Container(
              height: 60,
              alignment: Alignment.center,
              child: Text(
                '${18 + index}',
                style: ThemeColor.bodyLarge.copyWith(
                  color: isSelected
                      ? ThemeColor.textDarkColor
                      : ThemeColor.textSecondaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: isSelected ? 20 : 16,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildDistanceWheel({
    required double initialDistance,
    required void Function(double km) onChanged,
  }) {
    // Calcular índice inicial
    int initialIndex;
    if (initialDistance < 1) {
      initialIndex = ((initialDistance * 10).round() - 1).clamp(0, 8);
    } else {
      initialIndex = (9 + (initialDistance.toInt() - 1)).clamp(0, 308);
    }

    final scrollController = FixedExtentScrollController(
      initialItem: initialIndex,
    );
    final RxInt selected = initialIndex.obs;

    String labelForIndex(int index) {
      if (index < 9) return '${(index + 1) * 100} m';
      final km = index - 9 + 1;
      return km >= 300 ? '∞  Sin límite' : '$km km';
    }

    double kmForIndex(int index) {
      if (index < 9) return ((index + 1) * 100) / 1000.0;
      return (index - 9 + 1).toDouble();
    }

    return ListWheelScrollView.useDelegate(
      controller: scrollController,
      itemExtent: 60,
      diameterRatio: 1.5,
      perspective: 0.003,
      physics: FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        selected.value = index;
        onChanged(kmForIndex(index));
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 309, // 9 metros + 300 km
        builder: (context, index) {
          return Obx(() {
            final isSelected = index == selected.value;
            return Container(
              height: 60,
              alignment: Alignment.center,
              child: Text(
                labelForIndex(index),
                style: ThemeColor.bodyLarge.copyWith(
                  color: isSelected
                      ? ThemeColor.textDarkColor
                      : ThemeColor.textSecondaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: isSelected ? 20 : 16,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // ==========================================
  // PASO 4: FOTOS
  // ==========================================
  Widget _buildPhotosStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),
                  Text(
                    'Preséntate con fotos',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    'Sube al menos 2 fotos que muestren tu esencia.\nLas mejores conexiones empiezan con buenas\nfotos.',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Grid de fotos
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: ThemeColor.paddingSmall,
                      mainAxisSpacing: ThemeColor.paddingSmall,
                      childAspectRatio: 1,
                    ),
                    itemCount: controller.maxPhotos,
                    itemBuilder: (context, index) {
                      return Obx(() {
                        final photos = controller.selectedPhotos;
                        final isPicking = controller.isPickingPhotos.value;

                        if (index < photos.length) {
                          // Slot con foto ya cargada
                          return _buildPhotoItem(photos[index], index);
                        }

                        // Todos los slots vacíos muestran loading mientras se selecciona
                        if (isPicking) {
                          return _buildLoadingPhotoSlot();
                        }

                        // Slots vacíos normales
                        return _buildAddPhotoButton();
                      });
                    },
                  ),

                  SizedBox(height: ThemeColor.paddingLarge),

                  Obx(
                    () => Center(
                      child: Text(
                        '${controller.selectedPhotos.length}/${controller.maxPhotos} fotos',
                        style: ThemeColor.bodyMedium.copyWith(
                          color: ThemeColor.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildNavigationButtons(),
      ],
    );
  }

  /// Slot con spinner mientras se procesan las fotos
  Widget _buildLoadingPhotoSlot() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.primaryColor.withOpacity(0.05),
        borderRadius: ThemeColor.mediumBorderRadius,
        border: Border.all(
          color: ThemeColor.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(String photoPath, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ThemeColor.mediumBorderRadius,
            border: Border.all(color: ThemeColor.dividerColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: ThemeColor.mediumBorderRadius,
            child: Image.file(
              File(photoPath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removePhoto(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: controller.showPhotoOptions,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ThemeColor.mediumBorderRadius,
          border: Border.all(color: ThemeColor.dividerColor, width: 1),
        ),
        child: Icon(Icons.add, color: ThemeColor.textSecondaryColor, size: 32),
      ),
    );
  }

  // ==========================================
  // PASO 5: INTERESES
  // ==========================================
  Widget _buildInterestsStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Header
                  Text(
                    'Elige tus intereses\nprincipales',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    'Tus gustos nos ayudan a encontrar mejores\ncoincidencias.',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Buscador
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ThemeColor.paddingLarge,
                      vertical: ThemeColor.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: ThemeColor.mediumBorderRadius,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: ThemeColor.textSecondaryColor,
                        ),
                        SizedBox(width: ThemeColor.paddingSmall),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar intereses',
                              hintStyle: ThemeColor.bodyMedium.copyWith(
                                color: ThemeColor.textSecondaryColor,
                              ),
                              border: InputBorder.none,
                            ),
                            style: ThemeColor.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingLarge),

                  // Contador y título
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Intereses populares',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textDarkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${controller.selectedInterests.length}/${controller.maxInterests} seleccionados',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingMedium),

                  // Lista de intereses
                  Obx(() {
                    if (controller.isLoadingInterests.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(ThemeColor.paddingExtraLarge),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeColor.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.interests.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay intereses disponibles',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: ThemeColor.paddingSmall,
                      runSpacing: ThemeColor.paddingSmall,
                      children: controller.interests.map((interest) {
                        final isSelected = controller.selectedInterests
                            .contains(interest.id);
                        return _buildInterestChip(
                          interest.name,
                          _getInterestIcon(interest.name),
                          isSelected,
                          () => controller.toggleInterest(interest.id),
                        );
                      }).toList(),
                    );
                  }),

                  SizedBox(height: ThemeColor.paddingLarge),

                  // Mensaje de búsqueda
                  Center(
                    child: Text(
                      'si no se encuentran tus resultados escríbelos...',
                      style: ThemeColor.bodySmall.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingMedium),

                  SizedBox(height: ThemeColor.paddingExtraLarge),
                ],
              ),
            ),
          ),
        ),

        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildInterestChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium,
          vertical: ThemeColor.paddingSmall + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ThemeColor.tertiaryColor : Colors.white,
          borderRadius: ThemeColor.circularBorderRadius,
          border: Border.all(
            color: isSelected ? ThemeColor.tertiaryColor : Colors.white,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : ThemeColor.textDarkColor,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: ThemeColor.bodyMedium.copyWith(
                color: isSelected ? Colors.white : ThemeColor.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getInterestIcon(String interest) {
    final icons = {
      // Arte
      'Pintura': Icons.brush,
      'Fotografía': Icons.camera_alt,
      'Arte': Icons.palette,

      // Entretenimiento
      'Cine': Icons.movie,
      'Videojuegos': Icons.videogame_asset,
      'Anime': Icons.auto_awesome,

      // Música
      'Música en vivo': Icons.mic,
      'Rock': Icons.music_note,
      'Reggaetón': Icons.headphones,
      'Conciertos': Icons.music_note,
      'Festivales': Icons.festival,
      'Bailar': Icons.music_note,

      // Fitness & bienestar
      'Gimnasio': Icons.fitness_center,
      'Correr': Icons.directions_run,
      'Yoga': Icons.self_improvement,
      'Meditación': Icons.spa,
      'Deportes': Icons.sports_soccer,

      // Aventura
      'Senderismo': Icons.terrain,
      'Viajar': Icons.flight_takeoff,
      'Playa': Icons.beach_access,

      // Gastronomía
      'Café': Icons.coffee,
      'Vino': Icons.wine_bar,
      'Cocinar': Icons.restaurant_menu,
      'Foodie': Icons.restaurant,

      // Intelectual
      'Lectura': Icons.menu_book,
      'Libros': Icons.book,
      'Psicología': Icons.psychology,
      'Programación': Icons.code,

      // Lifestyle & negocios
      'Emprendimiento': Icons.rocket_launch,
      'Startups': Icons.trending_up,
      'Criptomonedas': Icons.currency_bitcoin,
      'Autos deportivos': Icons.directions_car,
      'Nómada digital': Icons.laptop_mac,

      // Mascotas
      'Perros': Icons.pets,
      'Gatos': Icons.pets,

      // Romance
      'Relación seria': Icons.favorite,
      'Algo casual': Icons.sentiment_satisfied_alt,

      // Otros
      'Escribir': Icons.edit,
      'Museos y galerías': Icons.museum,
    };

    return icons[interest] ?? Icons.favorite;
  }

  // ==========================================
  // PASO 6: CUALIDADES
  // ==========================================
  Widget _buildQualitiesStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ThemeColor.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Header
                  Text(
                    'Lo que más aprecias en una\npersona',
                    style: ThemeColor.headingLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textDarkColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: ThemeColor.paddingSmall),
                  Text(
                    'Estas cualidades nos ayudan a crear mejores\ncoincidencias.',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingExtraLarge),

                  // Contador
                  Obx(
                    () => Text(
                      'Lo que buscas en alguien        ${controller.selectedQualities.length}/${controller.maxQualities} seleccionados',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textDarkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: ThemeColor.paddingMedium),

                  // Lista de cualidades
                  Obx(() {
                    if (controller.isLoadingQualities.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(ThemeColor.paddingExtraLarge),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeColor.primaryColor,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.qualities.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay cualidades disponibles',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: ThemeColor.paddingSmall,
                      runSpacing: ThemeColor.paddingSmall,
                      children: controller.qualities.map((quality) {
                        final isSelected = controller.selectedQualities
                            .contains(quality.id);
                        return _buildQualityChip(
                          quality.name,
                          isSelected,
                          () => controller.toggleQuality(quality.id),
                        );
                      }).toList(),
                    );
                  }),

                  SizedBox(height: ThemeColor.paddingExtraLarge * 2),
                ],
              ),
            ),
          ),
        ),

        _buildFinalButtons(),
      ],
    );
  }

  Widget _buildQualityChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingLarge,
          vertical: ThemeColor.paddingMedium - 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ThemeColor.tertiaryColor : Colors.white,
          borderRadius: ThemeColor.circularBorderRadius,
          border: Border.all(
            color: isSelected ? ThemeColor.tertiaryColor : Colors.white,
          ),
        ),
        child: Text(
          label,
          style: ThemeColor.bodyMedium.copyWith(
            color: isSelected ? Colors.white : ThemeColor.textDarkColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // NAVEGACIÓN INFERIOR
  // ==========================================
  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(ThemeColor.paddingLarge),
      decoration: BoxDecoration(color: ThemeColor.backgroundColorfondo),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildBackButton(), SizedBox(), _buildNextButton()],
      ),
    );
  }

  Widget _buildFinalButtons() {
    return Container(
      padding: EdgeInsets.all(ThemeColor.paddingLarge),
      decoration: BoxDecoration(color: ThemeColor.backgroundColorfondo),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          SizedBox(),
          Obx(() {
            final isSaving = controller.isLoading.value;

            return GestureDetector(
              onTap: isSaving ? null : controller.submitPreferences,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSaving
                      ? ThemeColor.tertiaryColor.withOpacity(0.6)
                      : ThemeColor.tertiaryColor,
                  shape: BoxShape.circle,
                ),
                child: isSaving
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Icon(Icons.check, color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Obx(
      () => controller.currentStepIndex.value > 0
          ? GestureDetector(
              onTap: controller.previousStep,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ThemeColor.tertiaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            )
          : SizedBox(width: 56),
    );
  } // En PreferencesPage, actualizar _buildNextButton:

  Widget _buildNextButton() {
    return Obx(() {
      final isSaving = controller.isLoading.value;

      // Verificar si es el último paso
      final isLastStep =
          controller.currentStepIndex.value >=
          controller.availableSteps.length - 1;

      return GestureDetector(
        onTap: isSaving
            ? null
            : () {
                // Validar el paso actual primero
                if (!controller.validateCurrentStep()) {
                  return; // Si no es válido, no continuar
                }

                // Si NO es el último paso, guardar y avanzar
                if (!isLastStep) {
                  controller
                      .submitPreferences(); // Guarda y avanza automáticamente
                } else {
                  // ✅ SI ES el último paso, ejecutar submitPreferences para enviar todo
                  controller.submitPreferences();
                }
              },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isSaving
                ? ThemeColor.tertiaryColor.withOpacity(0.6)
                : ThemeColor.tertiaryColor,
            shape: BoxShape.circle,
          ),
          child: isSaving
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Icon(
                  // Mostrar check si es el último paso, flecha si no
                  isLastStep ? Icons.check : Icons.arrow_forward,
                  color: Colors.white,
                ),
        ),
      );
    });
  }
}
