import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/features/auth/domain/entities/user/create_user_entity.dart';
import 'package:tendria/features/auth/domain/usecase/create_user_usecase.dart';

class RegisterController extends GetxController {
  final CreateUserUsecase createUserUsecase;
  
  RegisterController({required this.createUserUsecase});

  // Controllers de texto
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController heightController;
  late final TextEditingController cityController;

  // Focus Nodes
  late final FocusNode nameFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;
  late final FocusNode confirmPasswordFocusNode;
  late final FocusNode heightFocusNode;
  late final FocusNode cityFocusNode;

  // Estados observables
  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxBool isLoadingLocation = false.obs;
  final RxBool locationObtained = false.obs;

  // Datos del formulario
  final Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  final RxString selectedGender = ''.obs;
  final RxString selectedLanguage = ''.obs;
  final RxList<int> selectedInterests = <int>[].obs;
  final RxList<int> selectedQualities = <int>[].obs;

  // Ubicación
  final RxString latitude = ''.obs;
  final RxString longitude = ''.obs;

  // Errores de validación
  final RxBool emailError = false.obs;
  final RxBool passwordError = false.obs;
  final RxBool confirmPasswordError = false.obs;
  final RxBool nameError = false.obs;

  // Mensajes de error
  final RxString emailErrorMessage = ''.obs;
  final RxString passwordErrorMessage = ''.obs;
  final RxString confirmPasswordErrorMessage = ''.obs;
  final RxString nameErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
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

    // Listeners para validación en tiempo real
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
    nameController.addListener(_validateName);
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

  bool _validateAllFields() {
    bool isValid = true;

    if (nameController.text.isEmpty) {
      nameError.value = true;
      nameErrorMessage.value = 'El nombre es requerido';
      isValid = false;
    }

    if (emailController.text.isEmpty) {
      emailError.value = true;
      emailErrorMessage.value = 'El correo es requerido';
      isValid = false;
    }

    if (passwordController.text.isEmpty) {
      passwordError.value = true;
      passwordErrorMessage.value = 'La contraseña es requerida';
      isValid = false;
    }

    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError.value = true;
      confirmPasswordErrorMessage.value = 'Confirma tu contraseña';
      isValid = false;
    }

    if (dateOfBirth.value == null) {
      _showErrorAlert('Campo requerido', 'Selecciona tu fecha de nacimiento');
      isValid = false;
    }

    if (selectedGender.value.isEmpty) {
      _showErrorAlert('Campo requerido', 'Selecciona tu género');
      isValid = false;
    }

    if (heightController.text.isEmpty) {
      _showErrorAlert('Campo requerido', 'Ingresa tu altura');
      isValid = false;
    }

    if (selectedLanguage.value.isEmpty) {
      _showErrorAlert('Campo requerido', 'Selecciona tu idioma principal');
      isValid = false;
    }

    if (cityController.text.isEmpty) {
      _showErrorAlert('Campo requerido', 'Ingresa tu ciudad');
      isValid = false;
    }

    if (!locationObtained.value) {
      _showErrorAlert('Ubicación requerida', 'Por favor, obtén tu ubicación');
      isValid = false;
    }

    if (selectedInterests.isEmpty) {
      _showErrorAlert('Campo requerido', 'Selecciona al menos un interés');
      isValid = false;
    }

    if (selectedQualities.isEmpty) {
      _showErrorAlert('Campo requerido', 'Selecciona al menos una cualidad');
      isValid = false;
    }

    // Validar errores existentes
    if (emailError.value || passwordError.value || confirmPasswordError.value || nameError.value) {
      isValid = false;
    }

    return isValid;
  }

  // ==========================================
  // PERMISOS Y UBICACIÓN
  // ==========================================

  Future<void> requestLocationPermission() async {
    try {
      isLoadingLocation.value = true;

      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorAlert(
          'Servicio deshabilitado',
          'Por favor, habilita el servicio de ubicación en tu dispositivo',
        );
        isLoadingLocation.value = false;
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorAlert(
            'Permiso denegado',
            'Necesitamos acceso a tu ubicación para crear tu perfil',
          );
          isLoadingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedDialog();
        isLoadingLocation.value = false;
        return;
      }

      // Obtener ubicación
      await _getCurrentLocation();
    } catch (e) {
      print('Error obteniendo permisos: $e');
      _showErrorAlert(
        'Error',
        'No se pudo obtener la ubicación: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude.toString();
      longitude.value = position.longitude.toString();
      locationObtained.value = true;

      _showSuccessAlert(
        'Ubicación obtenida',
        'Tu ubicación se ha obtenido correctamente',
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      _showErrorAlert(
        'Error',
        'No se pudo obtener tu ubicación: ${cleanExceptionMessage(e)}',
      );
    }
  }

  void _showPermissionDeniedDialog() {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: 'Permiso denegado permanentemente',
        message: 'Para usar esta función, necesitas habilitar los permisos de ubicación en la configuración de tu dispositivo.',
        confirmText: 'Ir a configuración',
        cancelText: 'Cancelar',
        type: CustomAlertType.warning,
        onConfirm: () {
          openAppSettings();
        },
      );
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
  // REGISTRO
  // ==========================================

  Future<void> onRegisterTap() async {
    if (!_validateAllFields()) return;

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
        city: cityController.text.trim(),
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
      _showErrorAlert(
        'Error en el registro',
        cleanExceptionMessage(e),
      );
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
    confirmPasswordFocusNode.unfocus();
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

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    heightController.clear();
    cityController.clear();
    
    dateOfBirth.value = null;
    selectedGender.value = '';
    selectedLanguage.value = '';
    selectedInterests.clear();
    selectedQualities.clear();
    latitude.value = '';
    longitude.value = '';
    locationObtained.value = false;
  }

  @override
  void onClose() {
    // Remover listeners
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    confirmPasswordController.removeListener(_validateConfirmPassword);
    nameController.removeListener(_validateName);

    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    heightController.dispose();
    cityController.dispose();

    // Dispose focus nodes
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    heightFocusNode.dispose();
    cityFocusNode.dispose();

    super.onClose();
  }
}