import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/features/auth/domain/entities/user/create_user_entity.dart';
import 'package:tendria/features/auth/domain/entities/user/registration_step.dart';
import 'package:tendria/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_interests_usecase.dart';
import 'package:tendria/features/catalog/domain/usecase/fetch_qualities_usecase.dart';

class RegisterController extends GetxController {
  final CreateUserUsecase createUserUsecase;
  final FetchQualitiesUsecase fetchQualitiesUsecase;
  final FetchInterestsUsecase fetchInterestsUsecase;

  RegisterController({
    required this.createUserUsecase,
    required this.fetchQualitiesUsecase,
    required this.fetchInterestsUsecase,
  });

  final Rx<RegistrationStep> currentStep = RegistrationStep.basicInfo.obs;
  final RxInt currentStepIndex = 0.obs;
  late final FixedExtentScrollController heightScrollController;

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController heightController;
  late final TextEditingController cityController;

  late final FocusNode nameFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;
  late final FocusNode confirmPasswordFocusNode;
  late final FocusNode heightFocusNode;
  late final FocusNode cityFocusNode;

  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxBool isLoadingLocation = false.obs;
  final RxBool locationObtained = false.obs;
  final RxBool isLoadingQualities = false.obs;
  final RxBool isLoadingInterests = false.obs;

  final Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  final RxString selectedGender = ''.obs;
  final RxString selectedLanguage = 'Español'.obs;
  final RxList<int> selectedInterests = <int>[].obs;
  final RxList<int> selectedQualities = <int>[].obs;

  final RxList<CatalogEntity> qualities = <CatalogEntity>[].obs;
  final RxList<CatalogEntity> interests = <CatalogEntity>[].obs;

  final RxString latitude = ''.obs;
  final RxString longitude = ''.obs;
  final RxString city = ''.obs;

  final RxBool emailError = false.obs;
  final RxBool passwordError = false.obs;
  final RxBool confirmPasswordError = false.obs;
  final RxBool nameError = false.obs;

  final RxString emailErrorMessage = ''.obs;
  final RxString passwordErrorMessage = ''.obs;
  final RxString confirmPasswordErrorMessage = ''.obs;
  final RxString nameErrorMessage = ''.obs;

  final RxInt selectedHeight = 170.obs;

  void selectHeight(int height) {
    heightController.text = height.toString();
    selectedHeight.value = height;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadCatalogs();
    heightScrollController = FixedExtentScrollController(initialItem: 16);
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    heightController = TextEditingController();
    cityController = TextEditingController();

    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
    heightFocusNode = FocusNode();
    cityFocusNode = FocusNode();

    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
    nameController.addListener(_validateName);
  }

  // ==========================================
  // CARGA DE CATÁLOGOS
  // ==========================================

  Future<void> _loadCatalogs() async {
    await Future.wait([_loadQualities(), _loadInterests()]);
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

  // ==========================================
  // NAVEGACIÓN ENTRE PASOS
  // ==========================================

  void nextStep() {
    if (_validateCurrentStep()) {
      if (currentStepIndex.value < 4) {
        currentStepIndex.value++;
        currentStep.value = RegistrationStep.values[currentStepIndex.value];

        if (currentStep.value == RegistrationStep.personalInfo) {
          _autoGetLocation();
        }
      }
    }
  }

  void previousStep() {
    if (currentStepIndex.value > 0) {
      currentStepIndex.value--;
      currentStep.value = RegistrationStep.values[currentStepIndex.value];
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case RegistrationStep.basicInfo:
        return _validateBasicInfo();
      case RegistrationStep.personalInfo:
        return _validatePersonalInfo();
      case RegistrationStep.physicalInfo:
        return _validatePhysicalInfo();
      case RegistrationStep.interests:
        return _validateInterests();
      case RegistrationStep.qualities:
        return true; 
    }
  }

  bool _validateBasicInfo() {
    bool isValid = true;

    if (nameController.text.isEmpty || nameController.text.length < 3) {
      nameError.value = true;
      nameErrorMessage.value = nameController.text.isEmpty
          ? 'El nombre es requerido'
          : 'Mínimo 3 caracteres';
      isValid = false;
    }

    if (emailController.text.isEmpty) {
      emailError.value = true;
      emailErrorMessage.value = 'El correo es requerido';
      isValid = false;
    } else if (emailError.value) {
      isValid = false;
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 8) {
      passwordError.value = true;
      passwordErrorMessage.value = passwordController.text.isEmpty
          ? 'La contraseña es requerida'
          : 'Mínimo 8 caracteres';
      isValid = false;
    }

    if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError.value = true;
      confirmPasswordErrorMessage.value = 'Las contraseñas no coinciden';
      isValid = false;
    }

    return isValid;
  }

  bool _validatePersonalInfo() {
    if (dateOfBirth.value == null) {
      _showErrorAlert('Campo requerido', 'Selecciona tu fecha de nacimiento');
      return false;
    }

    if (selectedGender.value.isEmpty) {
      _showErrorAlert('Campo requerido', 'Selecciona tu género');
      return false;
    }

    return true;
  }

  bool _validatePhysicalInfo() {
    if (heightController.text.isEmpty) {
      _showErrorAlert('Campo requerido', 'Ingresa tu altura');
      return false;
    }

    final height = int.tryParse(heightController.text);
    if (height == null || height < 100 || height > 250) {
      _showErrorAlert(
        'Altura inválida',
        'Ingresa una altura válida entre 100 y 250 cm',
      );
      return false;
    }

    return true;
  }

  bool _validateInterests() {
    if (selectedInterests.isEmpty) {
      _showErrorAlert('Campo requerido', 'Selecciona al menos un interés');
      return false;
    }
    return true;
  }

  // ==========================================
  // VALIDACIONES
  // ==========================================

  void _validateName() {
    if (nameController.text.isEmpty) {
      nameError.value = false;
      return;
    }
    if (nameController.text.length < 3) {
      nameError.value = true;
      nameErrorMessage.value = 'El nombre debe tener al menos 3 caracteres';
    } else {
      nameError.value = false;
    }
  }

  void _validateEmail() {
    if (emailController.text.isEmpty) {
      emailError.value = false;
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text)) {
      emailError.value = true;
      emailErrorMessage.value = 'Ingresa un correo válido';
    } else {
      emailError.value = false;
    }
  }

  void _validatePassword() {
    if (passwordController.text.isEmpty) {
      passwordError.value = false;
      return;
    }
    if (passwordController.text.length < 8) {
      passwordError.value = true;
      passwordErrorMessage.value = 'Mínimo 8 caracteres';
    } else {
      passwordError.value = false;
    }
  }

  void _validateConfirmPassword() {
    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError.value = false;
      return;
    }
    if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError.value = true;
      confirmPasswordErrorMessage.value = 'Las contraseñas no coinciden';
    } else {
      confirmPasswordError.value = false;
    }
  }

  // ==========================================
  // UBICACIÓN AUTOMÁTICA
  // ==========================================

  Future<void> _autoGetLocation() async {
    try {
      isLoadingLocation.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude.toString();
      longitude.value = position.longitude.toString();
      locationObtained.value = true;

      city.value = 'Ciudad'; 
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // ==========================================
  // SELECCIÓN DE DATOS
  // ==========================================

  void selectDateOfBirth(DateTime date) {
    dateOfBirth.value = date;
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void selectLanguage(String language) {
    selectedLanguage.value = language;
  }

  void toggleInterest(int interestId) {
    if (selectedInterests.contains(interestId)) {
      selectedInterests.remove(interestId);
    } else {
      selectedInterests.add(interestId);
    }
  }

  void toggleQuality(int qualityId) {
    if (selectedQualities.contains(qualityId)) {
      selectedQualities.remove(qualityId);
    } else {
      selectedQualities.add(qualityId);
    }
  }

  // ==========================================
  // REGISTRO FINAL
  // ==========================================

  Future<void> onRegisterTap() async {
    if (selectedQualities.isEmpty) {
      _showErrorAlert('Campo requerido', 'Selecciona al menos una cualidad');
      return;
    }

    if (!locationObtained.value) {
      _showErrorAlert(
        'Ubicación requerida',
        'Necesitamos tu ubicación para completar el registro. Por favor, habilita los permisos de ubicación.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final entity = CreateUserEntity(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        dateofbirth: _formatDate(dateOfBirth.value!),
        gender: selectedGender.value,
        heightcm: heightController.text.trim(),
        primarylanguage: selectedLanguage.value,
        city: city.value.isNotEmpty ? city.value : 'Ciudad desconocida',
        lat: latitude.value,
        lng: longitude.value,
        interestsIds: selectedInterests.toList(),
        qualitiesIds: selectedQualities.toList(),
      );

      await createUserUsecase.execute(entity);

      _showSuccessAlert(
        'Registro exitoso',
        'Tu cuenta ha sido creada correctamente',
        onDismiss: () {
          Get.offAllNamed(RoutesNames.loginPage);
        },
      );

      _clearFields();
    } catch (e) {
      print('Error en registro: $e');
      _showErrorAlert('Error en el registro', cleanExceptionMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ==========================================
  // NAVEGACIÓN
  // ==========================================

  void onLoginTap() {
    Get.toNamed(RoutesNames.loginPage);
  }

  void onNameSubmitted() {
    emailFocusNode.requestFocus();
  }

  void onEmailSubmitted() {
    passwordFocusNode.requestFocus();
  }

  void onPasswordSubmitted() {
    confirmPasswordFocusNode.requestFocus();
  }

  void onConfirmPasswordSubmitted() {
    nextStep();
  }

  // ==========================================
  // ALERTAS
  // ==========================================

  void _showErrorAlert(
    String title,
    String message, {
    VoidCallback? onDismiss,
  }) {
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

  void _showSuccessAlert(
    String title,
    String message, {
    VoidCallback? onDismiss,
  }) {
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

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    heightController.clear();
    cityController.clear();

    dateOfBirth.value = null;
    selectedGender.value = '';
    selectedLanguage.value = 'Español';
    selectedInterests.clear();
    selectedQualities.clear();
    latitude.value = '';
    longitude.value = '';
    city.value = '';
    locationObtained.value = false;
    currentStepIndex.value = 0;
    currentStep.value = RegistrationStep.basicInfo;
      heightScrollController.dispose();

  }

  @override
  void onClose() {
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    confirmPasswordController.removeListener(_validateConfirmPassword);
    nameController.removeListener(_validateName);

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    heightController.dispose();
    cityController.dispose();

    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    heightFocusNode.dispose();
    cityFocusNode.dispose();

    super.onClose();
  }
}
