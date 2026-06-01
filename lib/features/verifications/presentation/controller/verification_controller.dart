import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:tendria/common/widgets/alert/snackbar_helper_getx.dart';
import 'package:tendria/features/verifications/presentation/page/selfie_camera_page.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:tendria/features/verifications/domain/entities/get_verification_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verification_selfie_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verifications_entity.dart';
import 'package:tendria/features/verifications/domain/usecase/get_verification_usecase.dart';
import 'package:tendria/features/verifications/domain/usecase/verification_selfie_usecase.dart';
import 'package:tendria/features/verifications/domain/usecase/verification_usecase.dart';

class VerificationController extends GetxController {
  final VerificationUsecase verificationUsecase;
  final VerificationSelfieUsecase verificationSelfieUsecase;
  final GetVerificationUsecase getVerificationUsecase;

  VerificationController({
    required this.verificationUsecase,
    required this.verificationSelfieUsecase,
    required this.getVerificationUsecase,
  });
 
  final RxBool isLoadingVerifications = false.obs;
  final RxBool isSubmittingPhone = false.obs;
  final RxBool isSubmittingSocial = false.obs;
  final RxBool isSubmittingSelfie = false.obs;

  final RxList<GetVerificationEntity> verifications =
      <GetVerificationEntity>[].obs;
 
  final Rx<File?> selfieFile = Rx<File?>(null);
 
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedCountry = ''.obs;
  final RxString selectedDialCode = ''.obs;
  final RxString selectedCountryFlag = ''.obs;

  static const List<Map<String, String>> countries = [
    {'name': 'México',          'code': '+52',  'flag': '🇲🇽'},
    {'name': 'España',          'code': '+34',  'flag': '🇪🇸'},
    {'name': 'Estados Unidos',  'code': '+1',   'flag': '🇺🇸'},
    {'name': 'Argentina',       'code': '+54',  'flag': '🇦🇷'},
    {'name': 'Colombia',        'code': '+57',  'flag': '🇨🇴'},
    {'name': 'Chile',           'code': '+56',  'flag': '🇨🇱'},
    {'name': 'Venezuela',       'code': '+58',  'flag': '🇻🇪'},
    {'name': 'Perú',            'code': '+51',  'flag': '🇵🇪'},
    {'name': 'Ecuador',         'code': '+593', 'flag': '🇪🇨'},
    {'name': 'Bolivia',         'code': '+591', 'flag': '🇧🇴'},
    {'name': 'Paraguay',        'code': '+595', 'flag': '🇵🇾'},
    {'name': 'Uruguay',         'code': '+598', 'flag': '🇺🇾'},
    {'name': 'Guatemala',       'code': '+502', 'flag': '🇬🇹'},
    {'name': 'Cuba',            'code': '+53',  'flag': '🇨🇺'},
    {'name': 'Honduras',        'code': '+504', 'flag': '🇭🇳'},
    {'name': 'El Salvador',     'code': '+503', 'flag': '🇸🇻'},
    {'name': 'Nicaragua',       'code': '+505', 'flag': '🇳🇮'},
    {'name': 'Costa Rica',      'code': '+506', 'flag': '🇨🇷'},
    {'name': 'Panamá',          'code': '+507', 'flag': '🇵🇦'},
    {'name': 'República Dom.',  'code': '+1',   'flag': '🇩🇴'},
    {'name': 'Brasil',          'code': '+55',  'flag': '🇧🇷'},
    {'name': 'Francia',         'code': '+33',  'flag': '🇫🇷'},
    {'name': 'Alemania',        'code': '+49',  'flag': '🇩🇪'},
    {'name': 'Italia',          'code': '+39',  'flag': '🇮🇹'},
    {'name': 'Portugal',        'code': '+351', 'flag': '🇵🇹'},
    {'name': 'Reino Unido',     'code': '+44',  'flag': '🇬🇧'},
    {'name': 'Canadá',          'code': '+1',   'flag': '🇨🇦'},
    {'name': 'China',           'code': '+86',  'flag': '🇨🇳'},
    {'name': 'Japón',           'code': '+81',  'flag': '🇯🇵'},
    {'name': 'Corea del Sur',   'code': '+82',  'flag': '🇰🇷'},
    {'name': 'India',           'code': '+91',  'flag': '🇮🇳'},
    {'name': 'Australia',       'code': '+61',  'flag': '🇦🇺'},
  ];

  void selectCountry(Map<String, String> country) {
    selectedCountry.value   = country['name']!;
    selectedDialCode.value  = country['code']!;
    selectedCountryFlag.value = country['flag']!;
  }
 
  final TextEditingController usernameController = TextEditingController();
  final RxString selectedSocialNetwork = 'instagram'.obs;
  final RxString generatedSocialUrl = ''.obs;
 
  static const Map<String, String> _socialBaseUrls = {
    'instagram': 'https://instagram.com/',
    'facebook': 'https://facebook.com/',
    'twitter': 'https://x.com/',
    'tiktok': 'https://tiktok.com/@',
    'linkedin': 'https://linkedin.com/in/',
  };

 
  @override
  void onInit() {
    super.onInit();
    loadVerifications();
  }

  @override
  void onClose() {
    phoneController.dispose();
    usernameController.dispose();
    super.onClose();
  }
 
  bool isVerified(String tipo) =>
      verifications.any((v) => v.type == tipo && v.estado == 'aprobado');

  bool isPending(String tipo) =>
      verifications.any((v) => v.type == tipo && v.estado == 'pendiente');

  GetVerificationEntity? getVerification(String tipo) {
    try {
      return verifications.firstWhere((v) => v.type == tipo);
    } catch (_) {
      return null;
    }
  }

  int get verifiedCount =>
      ['selfie', 'telefono', 'red_social'].where(isVerified).length;
 
  Future<void> loadVerifications() async {
    try {
      isLoadingVerifications.value = true;
      final result = await getVerificationUsecase.call();
      verifications.assignAll(result);
    } catch (e) {
      showErrorSnackbarGetx('No se pudieron cargar las verificaciones');
    } finally {
      isLoadingVerifications.value = false;
    }
  }
 
  void clearPhoneForm() {
    phoneController.clear();
    selectedCountry.value = '';
    selectedDialCode.value = '';
    selectedCountryFlag.value = '';
  }

  Future<void> submitPhone() async {
    final numero = phoneController.text.trim();
    if (numero.isEmpty) {
      showErrorSnackbarGetx('Ingresa tu número de teléfono');
      return;
    }
    if (selectedCountry.value.isEmpty) {
      showErrorSnackbarGetx('Selecciona tu país');
      return;
    }
    try {
      isSubmittingPhone.value = true;
      final fullNumber = '${selectedDialCode.value}$numero';
      await verificationUsecase.call(
        VerificationsEntity(
          type: 'telefono',
          phone: VerificationsDataPhoneEntity(
            type: 'telefono',
            numero: fullNumber,
            pais: selectedCountry.value,
          ),
        ),
      );
      await loadVerifications();
      Get.back();
      showSuccessSnackbarGetx('Teléfono enviado para verificación');
    } catch (e) {
      showErrorSnackbarGetx ('$e');
    } finally {
      isSubmittingPhone.value = false;
    }
  }
 
  void clearSocialForm() {
    usernameController.clear();
    selectedSocialNetwork.value = 'instagram';
    generatedSocialUrl.value = '';
  }
 
  void onUsernameChanged(String username) {
    final base = _socialBaseUrls[selectedSocialNetwork.value] ?? '';
    final clean = username.trim().replaceFirst(RegExp(r'^@'), '');
    generatedSocialUrl.value = clean.isNotEmpty ? '$base$clean' : '';
  }

  void onSocialNetworkChanged(String network) {
    selectedSocialNetwork.value = network;
    onUsernameChanged(usernameController.text);
  }
 
  Future<void> openSocialProfile() async {
    final url = generatedSocialUrl.value;
    if (url.isEmpty) {
      showErrorSnackbarGetx('Ingresa tu nombre de usuario primero');
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showErrorSnackbarGetx('No se pudo abrir el navegador');
    }
  }

  Future<void> submitSocial() async {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      showErrorSnackbarGetx('Ingresa tu nombre de usuario');
      return;
    }
    if (generatedSocialUrl.value.isEmpty) {
      showErrorSnackbarGetx('La URL no se pudo generar');
      return;
    }
    try {
      isSubmittingSocial.value = true;
      await verificationUsecase.call(
        VerificationsEntity(
          type: 'red_social',
          social: VerificationsDataSocialEntity(
            type: 'red_social',
            red: selectedSocialNetwork.value,
            url: generatedSocialUrl.value,
            username: username.replaceFirst(RegExp(r'^@'), ''),
          ),
        ),
      );
      await loadVerifications();
      Get.back();
      showSuccessSnackbarGetx('Red social enviada para verificación');
    } catch (e) {
      showErrorSnackbarGetx('$e');
    } finally {
      isSubmittingSocial.value = false;
    }
  }
 
  void clearSelfie() => selfieFile.value = null;

  Future<void> pickSelfie() async {
    final result = await Get.to<SelfieCameraResult>(
      () => const SelfieCameraPage(),
      transition: Transition.downToUp,
    );
    if (result != null) selfieFile.value = result.photo;
  }

  Future<void> submitSelfie(String profilePhotoUrl) async {
    if (selfieFile.value == null) {
      showErrorSnackbarGetx('Toma una selfie primero');
      return;
    }
    if (profilePhotoUrl.isEmpty) {
      showErrorSnackbarGetx('No tienes foto de perfil configurada');
      return;
    }
    try {
      isSubmittingSelfie.value = true;
      await verificationSelfieUsecase.call(
        VerificationSelfieEntity(
          foto: selfieFile.value!,
          fotoPerfil: profilePhotoUrl,
        ),
      );
      await loadVerifications();
      Get.back();
      showSuccessSnackbarGetx('Selfie enviada para verificación');
    } catch (e) {
      showErrorSnackbarGetx('$e');
    } finally {
      isSubmittingSelfie.value = false;
    }
  }
  
}