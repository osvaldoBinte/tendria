// lib/features/user/presentation/controller/preferences_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/routes_names.dart';
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
import 'package:tendria/features/user/presentation/controller/profile_controller.dart';

class PreferencesController extends GetxController {
  final PreferencesUserUsecase preferencesUserUsecase;
  final UploadMediaUsecase uploadMediaUsecase;
  final FetchInterestsUsecase fetchInterestsUsecase;
  final FetchQualitiesUsecase fetchQualitiesUsecase;
  final PostInterestsUsecase postInterestsUsecase;
  final PostQualitiesUsecase postQualitiesUsecase;

  PreferencesController({
    required this.preferencesUserUsecase,
    required this.uploadMediaUsecase,
    required this.fetchInterestsUsecase,
    required this.fetchQualitiesUsecase,
    required this.postInterestsUsecase,
    required this.postQualitiesUsecase,
  });

  // Control de pasos
  final Rx<PreferencesStep> currentStep = PreferencesStep.genderPreference.obs;
  final RxInt currentStepIndex = 0.obs;
  final RxBool showSuccessScreen = false.obs;
  final RxBool isInitialized = false.obs;

  // Lista de pasos disponibles (solo los que faltan por completar)
  final RxList<PreferencesStep> availableSteps = <PreferencesStep>[].obs;

  // Estados de carga
  final RxBool isLoading = false.obs;
  final RxBool isUploadingPhotos = false.obs;
  final RxBool isLoadingInterests = false.obs;
  final RxBool isLoadingQualities = false.obs;
  final RxBool isLoadingUserData = false.obs;

  // Datos de preferencias
  final RxString selectedGenderPreference = ''.obs;
  final RxString selectedConnectionType = ''.obs;
  final RxInt minAge = 18.obs;
  final RxInt maxAge = 35.obs;
  // ❌ ELIMINADO: final RxNum distanceKm = RxNum(50);

  // NUEVO: Flags para saber qué ya fue enviado
  final RxBool preferencesAlreadySent = false.obs;
  final RxBool photosAlreadySent = false.obs;
  final RxBool interestsAlreadySent = false.obs;
  final RxBool qualitiesAlreadySent = false.obs;
  
  // Fotos seleccionadas
  final RxList<String> selectedPhotos = <String>[].obs;
  final int maxPhotos = 6;
  final int minPhotos = 2;

  // Intereses y Cualidades
  final RxList<int> selectedInterests = <int>[].obs;
  final RxList<int> selectedQualities = <int>[].obs;
  final RxList<CatalogEntity> interests = <CatalogEntity>[].obs;
  final RxList<CatalogEntity> qualities = <CatalogEntity>[].obs;
  final int maxInterests = 5;
  final int maxQualities = 3;

  // ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Referencia al ProfileController
  ProfileController? _profileController;

  // Opciones de género
  final List<Map<String, dynamic>> genderOptions = [
    {'label': 'Hombres', 'value': 'Hombre'},
    {'label': 'Mujeres', 'value': 'Mujer'},
    {'label': 'Persona no binaria', 'value': 'No_binario'},
    {'label': 'Mostrarme a todas las personas', 'value': 'Todos'},
  ];

  final List<Map<String, dynamic>> connectionOptions = [
    {'label': 'Amistad y buena vibra', 'value': 'amistad'},
    {'label': 'Citas y conocer a alguien', 'value': 'citas'},
    {'label': 'Algo serio y con futuro', 'value': 'algo_serio'},
    {'label': 'Casual, sin ataduras', 'value': 'casual'},
  ];

  final RxString customGenderInput = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Intentar obtener el ProfileController si existe
    try {
      _profileController = Get.find<ProfileController>();
    } catch (e) {
      print('ProfileController no encontrado, se cargará sin datos previos');
    }
    
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      // Cargar catálogos
      await _loadCatalogs();
      
      // Cargar datos del usuario desde ProfileController
      await _loadUserData();
      
      // Determinar qué pasos mostrar
      _determineAvailableSteps();
      
      // Establecer el paso inicial
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

  // ==========================================
  // CARGAR DATOS DEL USUARIO
  // ==========================================

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
    // Pre-cargar preferencias si existen
    if (user.preferences != null && user.preferences!.isNotEmpty) {
      final prefs = user.preferences!.first;
      
      if (prefs.searchgender != null) {
        preferencesAlreadySent.value = true;
        selectedGenderPreference.value = prefs.searchgender!;
      }
      
      if (prefs.agemin != null) minAge.value = prefs.agemin!;
      if (prefs.agemax != null) maxAge.value = prefs.agemax!;
      // ❌ ELIMINADO: if (prefs.distancekm != null) distanceKm.value = prefs.distancekm!;
      if (prefs.connectiontype != null) {
        selectedConnectionType.value = prefs.connectiontype!;
      }
    }
    
    // Pre-cargar fotos
    if (user.assets != null && user.assets!.isNotEmpty && user.assets!.length >= minPhotos) {
      photosAlreadySent.value = true;
    }
    
    // Pre-cargar intereses seleccionados
    if (user.interestsIds != null && user.interestsIds!.isNotEmpty) {
      interestsAlreadySent.value = true;
      selectedInterests.value = user.interestsIds!.map((i) => i.id).toList();
    }
    
    // Pre-cargar cualidades seleccionadas
    if (user.qualitiesIds != null && user.qualitiesIds!.isNotEmpty) {
      qualitiesAlreadySent.value = true;
      selectedQualities.value = user.qualitiesIds!.map((q) => q.id).toList();
    }
    
    print('Estado de envíos previos:');
    print('  Preferencias: ${preferencesAlreadySent.value}');
    print('  Fotos: ${photosAlreadySent.value}');
    print('  Intereses: ${interestsAlreadySent.value}');
    print('  Cualidades: ${qualitiesAlreadySent.value}');
  }

  // ==========================================
  // DETERMINAR PASOS DISPONIBLES
  // ==========================================

  void _determineAvailableSteps() {
    availableSteps.clear();
    
    final user = _profileController?.userEntity.value;
    
    final hasPreferences = user?.preferences != null && 
                          user!.preferences!.isNotEmpty &&
                          user.preferences!.first.searchgender != null;

    if (!hasPreferences) {
      availableSteps.add(PreferencesStep.genderPreference);
      availableSteps.add(PreferencesStep.connectionType);
      availableSteps.add(PreferencesStep.ageRange);
    }
    
    // Verificar si faltan fotos
    final hasPhotos = user?.assets != null && 
                     user!.assets!.isNotEmpty && 
                     user.assets!.length >= minPhotos;
    
    if (!hasPhotos) {
      availableSteps.add(PreferencesStep.photos);
    }
    
    // Verificar si faltan intereses
    final hasInterests = user?.interestsIds != null && 
                        user!.interestsIds!.isNotEmpty;
    
    if (!hasInterests) {
      availableSteps.add(PreferencesStep.interests);
    }
    
    // Verificar si faltan cualidades
    final hasQualities = user?.qualitiesIds != null && 
                        user!.qualitiesIds!.isNotEmpty;
    
    if (!hasQualities) {
      availableSteps.add(PreferencesStep.qualities);
    }
    
    print('Pasos disponibles: ${availableSteps.map((s) => s.toString()).toList()}');
  }

  // ==========================================
  // CARGAR CATÁLOGOS
  // ==========================================

  Future<void> _loadCatalogs() async {
    await Future.wait([
      _loadInterests(),
      _loadQualities(),
    ]);
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

  // ==========================================
  // NAVEGACIÓN ENTRE PASOS
  // ==========================================

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
        'Selección requerida',
        'Selecciona un tipo de persona',
      );
      return false;
    }
    return true;
  }

  bool _validateConnectionType() {
    if (selectedConnectionType.value.isEmpty) {
      _showErrorAlert(
        'Selección requerida',
        'Selecciona al menos un tipo de conexión',
      );
      return false;
    }
    return true;
  }

  bool _validateAgeRange() {
    if (minAge.value > maxAge.value) {
      _showErrorAlert(
        'Rango inválido',
        'La edad mínima no puede ser mayor que la edad máxima',
      );
      return false;
    }
    return true;
  }

  bool _validateInterests() {
    if (selectedInterests.isEmpty) {
      _showErrorAlert(
        'Selección requerida',
        'Selecciona al menos un interés',
      );
      return false;
    }
    return true;
  }

  // ==========================================
  // SELECCIÓN DE PREFERENCIAS
  // ==========================================

  void selectGenderPreference(String gender) {
    selectedGenderPreference.value = gender;
  }

  void selectConnectionType(String type) {
    selectedConnectionType.value = type;
  }

  void updateMinAge(int age) {
    minAge.value = age;
  }

  void updateMaxAge(int age) {
    maxAge.value = age;
  }

  // ❌ ELIMINADO: void updateDistance(int distance)

  void toggleInterest(int interestId) {
    if (selectedInterests.contains(interestId)) {
      selectedInterests.remove(interestId);
    } else {
      if (selectedInterests.length >= maxInterests) {
        _showErrorAlert(
          'Límite alcanzado',
          'Puedes seleccionar máximo $maxInterests intereses',
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
          'Límite alcanzado',
          'Puedes seleccionar máximo $maxQualities cualidades',
        );
        return;
      }
      selectedQualities.add(qualityId);
    }
  }

  // ==========================================
  // MANEJO DE FOTOS
  // ==========================================

  Future<void> pickImage() async {
    if (selectedPhotos.length >= maxPhotos) {
      _showErrorAlert(
        'Límite alcanzado',
        'Puedes subir máximo $maxPhotos fotos',
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        selectedPhotos.add(image.path);
      }
    } catch (e) {
      print('Error seleccionando Foto: $e');
      _showErrorAlert(
        'Error',
        'No se pudo seleccionar la Foto: ${cleanExceptionMessage(e)}',
      );
    }
  }

  Future<void> takePhoto() async {
    if (selectedPhotos.length >= maxPhotos) {
      _showErrorAlert(
        'Límite alcanzado',
        'Puedes subir máximo $maxPhotos fotos',
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        selectedPhotos.add(photo.path);
      }
    } catch (e) {
      print('Error tomando foto: $e');
      _showErrorAlert(
        'Error',
        'No se pudo tomar la foto: ${cleanExceptionMessage(e)}',
      );
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
    }
  }

  void showPhotoOptions() {
    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galería'),
                onTap: () {
                  Get.back();
                  pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Cámara'),
                onTap: () {
                  Get.back();
                  takePhoto();
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  // ==========================================
  // ENVÍO FINAL - CON VERIFICACIÓN POR PASO
  // ==========================================
  Future<void> submitPreferences() async {
    try {
      isLoading.value = true;

      // CASO 1: Si estamos en el paso de FOTOS - VALIDAR Y SUBIR
      if (currentStep.value == PreferencesStep.photos) {
        if (selectedPhotos.length < minPhotos) {
          _showErrorAlert(
            'Fotos requeridas',
            'Debes subir al menos $minPhotos fotos',
          );
          isLoading.value = false;
          return;
        }
        
        // ✅ SUBIR FOTOS INMEDIATAMENTE si no se han subido
        if (selectedPhotos.isNotEmpty && !photosAlreadySent.value) {
          print('📸 Subiendo ${selectedPhotos.length} fotos...');
          isUploadingPhotos.value = true;
          
          final mediaEntities = selectedPhotos
              .map((path) => UploadMediaEntity(mediaPath: path))
              .toList();
          
          await uploadMediaUsecase.execute(mediaEntities);
          photosAlreadySent.value = true;
          isUploadingPhotos.value = false;
          
          print('✅ Fotos subidas exitosamente');
        }
      }

      // CASO 2: Si estamos en el paso de INTERESES - VALIDAR Y GUARDAR
      if (currentStep.value == PreferencesStep.interests) {
        if (selectedInterests.isEmpty) {
          _showErrorAlert(
            'Intereses requeridos',
            'Debes seleccionar al menos un interés',
          );
          isLoading.value = false;
          return;
        }
        
        // ✅ GUARDAR INTERESES INMEDIATAMENTE si no se han guardado
        if (!interestsAlreadySent.value && selectedInterests.isNotEmpty) {
          print('🎯 Guardando ${selectedInterests.length} intereses...');
          await postInterestsUsecase.execute(selectedInterests.toList());
          interestsAlreadySent.value = true;
          print('✅ Intereses guardados exitosamente');
        }
      }

      // CASO 3: Si estamos en el paso de CUALIDADES - VALIDAR (se guardará al final)
      if (currentStep.value == PreferencesStep.qualities) {
        if (selectedQualities.isEmpty) {
          _showErrorAlert(
            'Cualidades requeridas',
            'Debes seleccionar al menos una cualidad',
          );
          isLoading.value = false;
          return;
        }
        
        print('⭐ ${selectedQualities.length} cualidades seleccionadas');
      }

      // CASO 4: Guardar preferencias si están disponibles y no se han enviado
      if (!preferencesAlreadySent.value &&
          selectedGenderPreference.value.isNotEmpty &&
          selectedConnectionType.value.isNotEmpty) {
        print('⚙️ Enviando preferencias (género, edad)...'); // ✅ SIN distancia
        
        final preferencesEntity = PreferencesEntity(
          agemin: minAge.value,
          agemax: maxAge.value,
          // ❌ ELIMINADO: distancekm: distanceKm.value,
          searchgender: selectedGenderPreference.value,
          connectiontype: selectedConnectionType.value,
        );

        await preferencesUserUsecase.execute(preferencesEntity);
        preferencesAlreadySent.value = true;
      }

      // CASO 5: Si NO es el último paso, avanzar automáticamente
      if (currentStepIndex.value < availableSteps.length - 1) {
        print('➡️ Avanzando al siguiente paso...');
        currentStepIndex.value++;
        currentStep.value = availableSteps[currentStepIndex.value];
      } else {
        // ✅ CASO 6: SI ES EL ÚLTIMO PASO, ENVIAR SOLO LO QUE FALTA
        print('🚀 Último paso alcanzado, enviando lo pendiente...');
        
        // Guardar cualidades si no se han enviado (lo único que falta)
        if (!qualitiesAlreadySent.value && selectedQualities.isNotEmpty) {
          print('⭐ Guardando ${selectedQualities.length} cualidades...');
          await postQualitiesUsecase.execute(selectedQualities.toList());
          qualitiesAlreadySent.value = true;
          print('✅ Cualidades guardadas exitosamente');
        }

        // Recargar datos en ProfileController
        if (_profileController != null) {
          print('🔄 Recargando perfil del usuario...');
          await _profileController!.loadUserProfile();
        }

        // Mostrar pantalla de éxito
        print('✅ Proceso completado exitosamente');
        showSuccessScreen.value = true;
        _clearData();
      }
    } catch (e) {
      print('❌ Error guardando preferencias: $e');
      _showErrorAlert(
        'Error',
        'No se pudieron guardar las preferencias: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isLoading.value = false;
      isUploadingPhotos.value = false;
    }
  }

  // ==========================================
  // ALERTAS
  // ==========================================

  void _showErrorAlert(String title, String message, {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
        onConfirm: onDismiss,
      );
    }
  }

  void _showSuccessAlert(String title, String message, {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.success,
        onConfirm: onDismiss,
      );
    }
  }

  // ==========================================
  // LIMPIEZA
  // ==========================================

  void _clearData() {
    selectedPhotos.clear();
    currentStepIndex.value = 0;
    if (availableSteps.isNotEmpty) {
      currentStep.value = availableSteps.first;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}