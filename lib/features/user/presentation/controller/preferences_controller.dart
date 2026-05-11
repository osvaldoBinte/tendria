import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/language_controller.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_qualities_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/post_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/post_qualities_usecase.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/entities/preferences_entity.dart';
import 'package:tendria/features/user/domain/entities/preferences_step.dart';
import 'package:tendria/features/user/domain/entities/upload_media_entity.dart';
import 'package:tendria/features/user/domain/usecase/preferences_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/upload_media_usecase.dart';
import 'package:tendria/features/user/domain/usecase/upload_picture_perfile_usecase.dart';
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class PreferencesController extends GetxController {
  final PreferencesUserUsecase preferencesUserUsecase;
  final UploadMediaUsecase uploadMediaUsecase;
  final FetchInterestsUsecase fetchInterestsUsecase;
  final FetchQualitiesUsecase fetchQualitiesUsecase;
  final PostInterestsUsecase postInterestsUsecase;
  final PostQualitiesUsecase postQualitiesUsecase;
  final UploadPicturePerfileUsecase uploadPicturePerfileUsecase;

  PreferencesController({
    required this.preferencesUserUsecase,
    required this.uploadMediaUsecase,
    required this.fetchInterestsUsecase,
    required this.fetchQualitiesUsecase,
    required this.postInterestsUsecase,
    required this.postQualitiesUsecase,
    required this.uploadPicturePerfileUsecase,
  });

  LanguageController get _l => Get.find<LanguageController>();

  // ─── ESTADO ──────────────────────────────────────────────────────────────────

  final Rx<PreferencesStep> currentStep = PreferencesStep.genderPreference.obs;
  final RxInt currentStepIndex = 0.obs;
  final RxBool showSuccessScreen = false.obs;
  final RxBool isInitialized = false.obs;

  final RxList<PreferencesStep> availableSteps = <PreferencesStep>[].obs;
  final RxBool isPickingPhotos = false.obs;

  final RxBool isLoading = false.obs;
  final RxBool isUploadingPhotos = false.obs;
  final RxBool isLoadingInterests = false.obs;
  final RxBool isLoadingQualities = false.obs;
  final RxBool isLoadingUserData = false.obs;

  final RxString selectedGenderPreference = ''.obs;
  final RxString selectedConnectionType = ''.obs;

  final RxInt minAge = 18.obs;
  final RxInt maxAge = 80.obs;
  final RxDouble distanceKm = 1000.0.obs;

  final RxBool preferencesAlreadySent = false.obs;
  final RxBool photosAlreadySent = false.obs;
  final RxBool interestsAlreadySent = false.obs;
  final RxBool qualitiesAlreadySent = false.obs;

  final RxList<String> selectedPhotos = <String>[].obs;
  final int maxPhotos = 6;
  final int minPhotos = 2;

  final RxList<int> selectedInterests = <int>[].obs;
  final RxList<int> selectedQualities = <int>[].obs;
  final RxList<CatalogEntity> interests = <CatalogEntity>[].obs;
  final RxList<CatalogEntity> qualities = <CatalogEntity>[].obs;
  final int maxInterests = 5;
  final int maxQualities = 3;

  final ImagePicker _picker = ImagePicker();
  ProfileController? _profileController;
  final RxString customGenderInput = ''.obs;

  // ─── OPCIONES (labels traducidos en la Page, values fijos aquí) ───────────

  final List<Map<String, dynamic>> genderOptions = [
    {'label': 'Hombres', 'value': 'Hombre', 'icon': Icons.male},
    {'label': 'Mujeres', 'value': 'Mujer', 'icon': Icons.female},
    {
      'label': 'Persona no binaria',
      'value': 'No_binario',
      'icon': Icons.transgender,
    },
    {'label': 'Todos', 'value': 'Todos', 'icon': Icons.people},
  ];

  final List<Map<String, dynamic>> connectionOptions = [
    {'label': 'Amistad y buena vibra', 'value': 'amistad'},
    {'label': 'Conocer gente y pasarla bien', 'value': 'citas'},
    {'label': 'Algo estable y con futuro', 'value': 'algo_serio'},
    {'label': 'Conexiones sin ataduras', 'value': 'casual'},
  ];

  // ─── INIT ─────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    try {
      _profileController = Get.find<ProfileController>();
    } catch (e) {
      print('ProfileController no encontrado, se cargará sin datos previos');
    }
    _initializeController();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ─── INICIALIZACIÓN ───────────────────────────────────────────────────────────

  Future<void> _initializeController() async {
    try {
      await _loadCatalogs();
      await _loadUserData();
      _determineAvailableSteps();
      if (availableSteps.isNotEmpty) {
        currentStep.value = availableSteps.first;
        currentStepIndex.value = 0;
      }
      isInitialized.value = true;
    } catch (e) {
      print('Error en inicialización: $e');
      isInitialized.value = true;
    }
  }

  Future<void> _loadUserData() async {
    try {
      isLoadingUserData.value = true;
      if (_profileController != null) {
        if (_profileController!.userEntity.value != null) {
          _preloadExistingData(_profileController!.userEntity.value!);
        } else {
          await _profileController!.loadUserProfile();
          if (_profileController!.userEntity.value != null) {
            _preloadExistingData(_profileController!.userEntity.value!);
          }
        }
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    } finally {
      isLoadingUserData.value = false;
    }
  }

  void _preloadExistingData(GetUserEntity user) {
    if (user.preferences != null) {
      final prefs = user.preferences!;
      if (prefs.searchgender != null) {
        preferencesAlreadySent.value = true;
        selectedGenderPreference.value = prefs.searchgender!;
      }
      if (prefs.agemin != null) minAge.value = prefs.agemin!;
      if (prefs.agemax != null) maxAge.value = prefs.agemax!;
      if (prefs.distancekm != null) distanceKm.value = prefs.distancekm!;
      if (prefs.connectiontype != null) {
        selectedConnectionType.value = prefs.connectiontype!;
      }
    }

    if (user.assets != null &&
        user.assets!.isNotEmpty &&
        user.assets!.length >= minPhotos) {
      photosAlreadySent.value = true;
    }

    if (user.interestsIds != null && user.interestsIds!.isNotEmpty) {
      interestsAlreadySent.value = true;
      selectedInterests.value = user.interestsIds!.map((i) => i.id).toList();
    }

    if (user.qualitiesIds != null && user.qualitiesIds!.isNotEmpty) {
      qualitiesAlreadySent.value = true;
      selectedQualities.value = user.qualitiesIds!.map((q) => q.id).toList();
    }
  }

  void _determineAvailableSteps() {
    availableSteps.clear();
    final user = _profileController?.userEntity.value;

    final hasPreferences =
        user?.preferences != null && user!.preferences!.searchgender != null;
    if (!hasPreferences) {
      availableSteps.add(PreferencesStep.genderPreference);
      availableSteps.add(PreferencesStep.connectionType);
      availableSteps.add(PreferencesStep.ageRange);
    }

    final hasPhotos = user?.assets != null &&
        user!.assets!.isNotEmpty &&
        user.assets!.length >= minPhotos;
    if (!hasPhotos) availableSteps.add(PreferencesStep.photos);

    final hasInterests =
        user?.interestsIds != null && user!.interestsIds!.isNotEmpty;
    if (!hasInterests) availableSteps.add(PreferencesStep.interests);

    final hasQualities =
        user?.qualitiesIds != null && user!.qualitiesIds!.isNotEmpty;
    if (!hasQualities) availableSteps.add(PreferencesStep.qualities);
  }

  // ─── CATÁLOGOS ────────────────────────────────────────────────────────────────

  Future<void> _loadCatalogs() async {
    await Future.wait([_loadInterests(), _loadQualities()]);
  }

  Future<void> _loadInterests() async {
    try {
      isLoadingInterests.value = true;
      final result = await fetchInterestsUsecase.execute();
      interests.value = result;
    } catch (e) {
      print('Error cargando intereses: $e');
    } finally {
      isLoadingInterests.value = false;
    }
  }

  Future<void> _loadQualities() async {
    try {
      isLoadingQualities.value = true;
      final result = await fetchQualitiesUsecase.execute();
      qualities.value = result;
    } catch (e) {
      print('Error cargando cualidades: $e');
    } finally {
      isLoadingQualities.value = false;
    }
  }

  // ─── NAVEGACIÓN ───────────────────────────────────────────────────────────────

  void nextStep() {
    if (validateCurrentStep()) {
      if (currentStepIndex.value < availableSteps.length - 1) {
        currentStepIndex.value++;
        currentStep.value = availableSteps[currentStepIndex.value];
      }
    }
  }

  void previousStep() {
    if (currentStepIndex.value > 0) {
      currentStepIndex.value--;
      currentStep.value = availableSteps[currentStepIndex.value];
    }
  }

  // ─── VALIDACIONES ─────────────────────────────────────────────────────────────

  bool validateCurrentStep() {
    switch (currentStep.value) {
      case PreferencesStep.genderPreference:
        return _validateGenderPreference();
      case PreferencesStep.connectionType:
        return _validateConnectionType();
      case PreferencesStep.ageRange:
        return _validateAgeRange();
      case PreferencesStep.photos:
        return true;
      case PreferencesStep.interests:
        return _validateInterests();
      case PreferencesStep.qualities:
        return true;
    }
  }

  bool _validateGenderPreference() {
    if (selectedGenderPreference.value.isEmpty) {
      _showErrorAlert(
        _l.t('pref_selection_required'),
        _l.t('pref_select_gender'),
      );
      return false;
    }
    return true;
  }

  bool _validateConnectionType() {
    if (selectedConnectionType.value.isEmpty) {
      _showErrorAlert(
        _l.t('pref_selection_required'),
        _l.t('pref_select_connection'),
      );
      return false;
    }
    return true;
  }

  bool _validateAgeRange() {
    if (minAge.value > maxAge.value) {
      _showErrorAlert(
        _l.t('pref_invalid_range'),
        _l.t('pref_age_range_error'),
      );
      return false;
    }
    return true;
  }

  bool _validateInterests() {
    if (selectedInterests.isEmpty) {
      _showErrorAlert(
        _l.t('pref_selection_required'),
        _l.t('val_interest_required'),
      );
      return false;
    }
    return true;
  }

  // ─── SELECCIÓN ────────────────────────────────────────────────────────────────

  void selectGenderPreference(String gender) {
    selectedGenderPreference.value = gender;
  }

  void selectConnectionType(String type) {
    selectedConnectionType.value = type;
  }

  void updateMinAge(int age) => minAge.value = age;
  void updateMaxAge(int age) => maxAge.value = age;
  void updateDistance(double distance) => distanceKm.value = distance;

  void toggleInterest(int interestId) {
    if (selectedInterests.contains(interestId)) {
      selectedInterests.remove(interestId);
    } else {
      if (selectedInterests.length >= maxInterests) {
        _showErrorAlert(
          _l.t('pref_limit_reached'),
          _l.t('bs_max_interests'),
        );
        return;
      }
      selectedInterests.add(interestId);
    }
  }

  void toggleQuality(int qualityId) {
    if (selectedQualities.contains(qualityId)) {
      selectedQualities.remove(qualityId);
    } else {
      if (selectedQualities.length >= maxQualities) {
        _showErrorAlert(
          _l.t('pref_limit_reached'),
          _l.t('bs_max_qualities'),
        );
        return;
      }
      selectedQualities.add(qualityId);
    }
  }

  // ─── FOTOS ────────────────────────────────────────────────────────────────────

  Future<String> _ensureValidImageFormat(String originalPath) async {
    final ext = originalPath.toLowerCase();
    if (ext.endsWith('.png') || ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      return originalPath;
    }
    try {
      final File originalFile = File(originalPath);
      final Uint8List bytes = await originalFile.readAsBytes();
      final String tempDir =
          (await Directory.systemTemp.createTemp('tendria_img')).path;
      final String newPath =
          '$tempDir/photo_${DateTime.now().millisecondsSinceEpoch}.png';
      final File newFile = File(newPath);
      await newFile.writeAsBytes(bytes);
      print('🖼️ Imagen convertida: $originalPath → $newPath');
      return newPath;
    } catch (e) {
      print('⚠️ No se pudo convertir la imagen, usando original: $e');
      return originalPath;
    }
  }

  Future<void> pickMultipleImages() async {
    final remaining = maxPhotos - selectedPhotos.length;
    if (remaining <= 0) {
      _showErrorAlert(
        _l.t('pref_limit_reached'),
        '${_l.t('pref_photos_max')} $maxPhotos',
      );
      return;
    }
    try {
      isPickingPhotos.value = true;
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (images.isEmpty) return;
      final toAdd = images.take(remaining).toList();
      final List<String> convertedPaths = [];
      for (final image in toAdd) {
        final converted = await _ensureValidImageFormat(image.path);
        convertedPaths.add(converted);
      }
      selectedPhotos.addAll(convertedPaths);
      if (images.length > remaining) {
        _showErrorAlert(
          _l.t('pref_limit_reached'),
          '${_l.t('pref_photos_partial')} $remaining (${_l.t('pref_photos_max')} $maxPhotos)',
        );
      }
    } catch (e) {
      _showErrorAlert(
        _l.t('error'),
        '${_l.t('pref_photos_pick_error')}: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isPickingPhotos.value = false;
    }
  }

  Future<void> pickImage() async {
    if (selectedPhotos.length >= maxPhotos) {
      _showErrorAlert(
        _l.t('pref_limit_reached'),
        '${_l.t('pref_photos_max')} $maxPhotos',
      );
      return;
    }
    try {
      isPickingPhotos.value = true;
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        final converted = await _ensureValidImageFormat(image.path);
        selectedPhotos.add(converted);
      }
    } catch (e) {
      print('Error seleccionando Foto: $e');
      _showErrorAlert(
        _l.t('error'),
        '${_l.t('pref_photos_pick_error')}: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isPickingPhotos.value = false;
    }
  }

  Future<void> takePhoto() async {
    if (selectedPhotos.length >= maxPhotos) {
      _showErrorAlert(
        _l.t('pref_limit_reached'),
        '${_l.t('pref_photos_max')} $maxPhotos',
      );
      return;
    }
    try {
      isPickingPhotos.value = true;
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (photo != null) {
        final converted = await _ensureValidImageFormat(photo.path);
        selectedPhotos.add(converted);
      }
    } catch (e) {
      _showErrorAlert(
        _l.t('error'),
        '${_l.t('pref_photo_take_error')}: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isPickingPhotos.value = false;
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
    }
  }

  void showPhotoOptions() {
    if (Get.context == null) return;

    showCustomAlert(
      context: Get.context!,
      title: '',
      message: '',
      confirmText: '',
      type: CustomAlertType.confirm,
      customWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeColor.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: ThemeColor.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _l.t('pref_add_photos'),
                    style: ThemeColor.headingSmall.copyWith(
                      color: ThemeColor.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      Icon(Icons.close, color: ThemeColor.textSecondaryColor),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  title: _l.t('pref_gallery_multiple'),
                  subtitle: _l.t('pref_gallery_multiple_hint'),
                  onTap: () {
                    Get.back();
                    pickMultipleImages();
                  },
                ),
                const SizedBox(height: 8),
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  title: _l.t('pref_take_photo'),
                  subtitle: _l.t('pref_take_photo_hint'),
                  onTap: () {
                    Get.back();
                    takePhoto();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ThemeColor.mediumBorderRadius,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: ThemeColor.dividerColor, width: 1),
            borderRadius: ThemeColor.mediumBorderRadius,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor.withOpacity(0.1),
                  borderRadius: ThemeColor.smallBorderRadius,
                ),
                child: Icon(icon, color: ThemeColor.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeColor.subtitleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: ThemeColor.bodySmall.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ThemeColor.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SUBMIT ───────────────────────────────────────────────────────────────────

  Future<void> submitPreferences() async {
    try {
      isLoading.value = true;

      // ── Fotos ──
      if (currentStep.value == PreferencesStep.photos) {
        if (selectedPhotos.length < minPhotos) {
          _showErrorAlert(
            _l.t('pref_photos_required'),
            _l.t('pref_photos_min'),
          );
          isLoading.value = false;
          return;
        }
        if (selectedPhotos.isNotEmpty && !photosAlreadySent.value) {
          print('📸 Subiendo ${selectedPhotos.length} fotos...');
          isUploadingPhotos.value = true;
          final mediaEntities = selectedPhotos
              .map((path) => UploadMediaEntity(mediaPath: path))
              .toList();
          await uploadMediaUsecase.execute(mediaEntities);
          photosAlreadySent.value = true;
          isUploadingPhotos.value = false;
          if (selectedPhotos.isNotEmpty) {
            print('🖼️ Estableciendo foto de perfil...');
            await uploadPicturePerfileUsecase.execute(selectedPhotos.first);
            print('✅ Foto de perfil establecida');
          }
          print('✅ Fotos subidas exitosamente');
        }
      }

      // ── Intereses ──
      if (currentStep.value == PreferencesStep.interests) {
        if (selectedInterests.isEmpty) {
          _showErrorAlert(
            _l.t('pref_interests_required'),
            _l.t('val_interest_required'),
          );
          isLoading.value = false;
          return;
        }
        if (!interestsAlreadySent.value && selectedInterests.isNotEmpty) {
          print('🎯 Guardando ${selectedInterests.length} intereses...');
          await postInterestsUsecase.execute(selectedInterests.toList());
          interestsAlreadySent.value = true;
          print('✅ Intereses guardados exitosamente');
        }
      }

      // ── Cualidades ──
      if (currentStep.value == PreferencesStep.qualities) {
        if (selectedQualities.isEmpty) {
          _showErrorAlert(
            _l.t('pref_qualities_required'),
            _l.t('pref_select_quality'),
          );
          isLoading.value = false;
          return;
        }
        print('⭐ ${selectedQualities.length} cualidades seleccionadas');
      }

      // ── Preferencias ──
      if (!preferencesAlreadySent.value &&
          currentStep.value == PreferencesStep.ageRange &&
          selectedGenderPreference.value.isNotEmpty &&
          selectedConnectionType.value.isNotEmpty) {
        print(
          '⚙️ Enviando preferencias con edad min:${minAge.value} max:${maxAge.value}...',
        );
        final preferencesEntity = PreferencesEntity(
          agemin: minAge.value,
          agemax: maxAge.value,
          distancekm: distanceKm.value,
          searchgender: selectedGenderPreference.value,
          connectiontype: selectedConnectionType.value,
        );
        await preferencesUserUsecase.execute(preferencesEntity);
        preferencesAlreadySent.value = true;
      }

      // ── Avanzar o finalizar ──
      if (currentStepIndex.value < availableSteps.length - 1) {
        print('➡️ Avanzando al siguiente paso...');
        currentStepIndex.value++;
        currentStep.value = availableSteps[currentStepIndex.value];
      } else {
        print('🚀 Último paso alcanzado, enviando lo pendiente...');
        if (!qualitiesAlreadySent.value && selectedQualities.isNotEmpty) {
          print('⭐ Guardando ${selectedQualities.length} cualidades...');
          await postQualitiesUsecase.execute(selectedQualities.toList());
          qualitiesAlreadySent.value = true;
          print('✅ Cualidades guardadas exitosamente');
        }
        if (_profileController != null) {
          print('🔄 Recargando perfil del usuario...');
          await _profileController!.loadUserProfile();
        }
        print('✅ Proceso completado exitosamente');
        showSuccessScreen.value = true;
        _clearData();
      }
    } catch (e) {
      print('❌ Error guardando preferencias: $e');
      _showErrorAlert(
        _l.t('error'),
        '${_l.t('snack_could_not_update')}: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isLoading.value = false;
      isUploadingPhotos.value = false;
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  void _showErrorAlert(String title, String message, {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: _l.t('accept'),
        type: CustomAlertType.error,
        onConfirm: onDismiss,
      );
    }
  }

  void _showSuccessAlert(String title, String message,
      {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: _l.t('accept'),
        type: CustomAlertType.success,
        onConfirm: onDismiss,
      );
    }
  }

  void _clearData() {
    selectedPhotos.clear();
    currentStepIndex.value = 0;
    if (availableSteps.isNotEmpty) {
      currentStep.value = availableSteps.first;
    }
  }
}