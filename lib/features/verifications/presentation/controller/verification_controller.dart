import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendria/common/settings/language_controller.dart';
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
 
  LanguageController get _l => Get.find<LanguageController>();
 
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
    {'name': 'México',         'code': '+52',  'flag': '🇲🇽'},
    {'name': 'España',         'code': '+34',  'flag': '🇪🇸'},
    {'name': 'Estados Unidos', 'code': '+1',   'flag': '🇺🇸'},
    {'name': 'Argentina',      'code': '+54',  'flag': '🇦🇷'},
    {'name': 'Colombia',       'code': '+57',  'flag': '🇨🇴'},
    {'name': 'Chile',          'code': '+56',  'flag': '🇨🇱'},
    {'name': 'Venezuela',      'code': '+58',  'flag': '🇻🇪'},
    {'name': 'Perú',           'code': '+51',  'flag': '🇵🇪'},
    {'name': 'Ecuador',        'code': '+593', 'flag': '🇪🇨'},
    {'name': 'Bolivia',        'code': '+591', 'flag': '🇧🇴'},
    {'name': 'Paraguay',       'code': '+595', 'flag': '🇵🇾'},
    {'name': 'Uruguay',        'code': '+598', 'flag': '🇺🇾'},
    {'name': 'Guatemala',      'code': '+502', 'flag': '🇬🇹'},
    {'name': 'Cuba',           'code': '+53',  'flag': '🇨🇺'},
    {'name': 'Honduras',       'code': '+504', 'flag': '🇭🇳'},
    {'name': 'El Salvador',    'code': '+503', 'flag': '🇸🇻'},
    {'name': 'Nicaragua',      'code': '+505', 'flag': '🇳🇮'},
    {'name': 'Costa Rica',     'code': '+506', 'flag': '🇨🇷'},
    {'name': 'Panamá',         'code': '+507', 'flag': '🇵🇦'},
    {'name': 'República Dom.', 'code': '+1',   'flag': '🇩🇴'},
    {'name': 'Brasil',         'code': '+55',  'flag': '🇧🇷'},
    {'name': 'Francia',        'code': '+33',  'flag': '🇫🇷'},
    {'name': 'Alemania',       'code': '+49',  'flag': '🇩🇪'},
    {'name': 'Italia',         'code': '+39',  'flag': '🇮🇹'},
    {'name': 'Portugal',       'code': '+351', 'flag': '🇵🇹'},
    {'name': 'Reino Unido',    'code': '+44',  'flag': '🇬🇧'},
    {'name': 'Canadá',         'code': '+1',   'flag': '🇨🇦'},
    {'name': 'China',          'code': '+86',  'flag': '🇨🇳'},
    {'name': 'Japón',          'code': '+81',  'flag': '🇯🇵'},
    {'name': 'Corea del Sur',  'code': '+82',  'flag': '🇰🇷'},
    {'name': 'India',          'code': '+91',  'flag': '🇮🇳'},
    {'name': 'Australia',      'code': '+61',  'flag': '🇦🇺'},
  ];

  void selectCountry(Map<String, String> country) {
    selectedCountry.value = country['name']!;
    selectedDialCode.value = country['code']!;
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
 
  static const Map<String, String> _cityToCountry = {
    
    'mexico': 'México', 'méxico': 'México', 'cdmx': 'México',
    'guadalajara': 'México', 'monterrey': 'México', 'puebla': 'México',
    'tijuana': 'México', 'juárez': 'México', 'juarez': 'México',
    'mérida': 'México', 'merida': 'México', 'tuxtla': 'México',
    'cancún': 'México', 'cancun': 'México', 'oaxaca': 'México',
    'chihuahua': 'México', 'veracruz': 'México', 'aguascalientes': 'México',
    'tlaxcala': 'México', 'hermosillo': 'México', 'culiacán': 'México',
    'culiacan': 'México', 'saltillo': 'México', 'morelia': 'México',
    
    'madrid': 'España', 'barcelona': 'España', 'valencia': 'España',
    'sevilla': 'España', 'bilbao': 'España', 'españa': 'España',
    'spain': 'España', 'zaragoza': 'España', 'málaga': 'España',
    'malaga': 'España',
    
    'buenos aires': 'Argentina', 'córdoba': 'Argentina', 'rosario': 'Argentina',
    'argentina': 'Argentina', 'mendoza': 'Argentina',
   
    'bogotá': 'Colombia', 'bogota': 'Colombia', 'medellín': 'Colombia',
    'medellin': 'Colombia', 'cali': 'Colombia', 'colombia': 'Colombia',
    'barranquilla': 'Colombia', 'cartagena': 'Colombia',
    
    'santiago': 'Chile', 'valparaíso': 'Chile', 'valparaiso': 'Chile',
    'chile': 'Chile', 
    'new york': 'Estados Unidos', 'los angeles': 'Estados Unidos',
    'chicago': 'Estados Unidos', 'houston': 'Estados Unidos',
    'usa': 'Estados Unidos', 'united states': 'Estados Unidos',
    'miami': 'Estados Unidos', 'dallas': 'Estados Unidos',
    
    'são paulo': 'Brasil', 'sao paulo': 'Brasil',
    'rio de janeiro': 'Brasil', 'brasil': 'Brasil', 'brazil': 'Brasil',
    'brasília': 'Brasil', 'brasilia': 'Brasil',
    
    'lima': 'Perú', 'perú': 'Perú', 'peru': 'Perú', 'arequipa': 'Perú',
     
    'caracas': 'Venezuela', 'venezuela': 'Venezuela', 'maracaibo': 'Venezuela',
   
    'quito': 'Ecuador', 'guayaquil': 'Ecuador', 'ecuador': 'Ecuador',
    
    'san josé': 'Costa Rica', 'san jose': 'Costa Rica',
    'costa rica': 'Costa Rica',
    
    'guatemala': 'Guatemala', 'ciudad de guatemala': 'Guatemala',
    
    'panamá': 'Panamá', 'panama': 'Panamá',
   
    'tegucigalpa': 'Honduras', 'honduras': 'Honduras',
    
    'san salvador': 'El Salvador', 'el salvador': 'El Salvador',
    
    'managua': 'Nicaragua', 'nicaragua': 'Nicaragua',
   
    'la habana': 'Cuba', 'habana': 'Cuba', 'cuba': 'Cuba',
    
    'santo domingo': 'República Dom.', 'república dominicana': 'República Dom.',
   
    'la paz': 'Bolivia', 'bolivia': 'Bolivia', 'santa cruz': 'Bolivia',
     
    'asunción': 'Paraguay', 'asuncion': 'Paraguay', 'paraguay': 'Paraguay',
     
    'montevideo': 'Uruguay', 'uruguay': 'Uruguay',
   
    'lisboa': 'Portugal', 'lisbon': 'Portugal', 'porto': 'Portugal',
    'portugal': 'Portugal',
   
    'paris': 'Francia', 'parís': 'Francia', 'france': 'Francia',
    'francia': 'Francia',
   
    'berlin': 'Alemania', 'berlín': 'Alemania', 'munich': 'Alemania',
    'alemania': 'Alemania', 'germany': 'Alemania',
   
    'roma': 'Italia', 'rome': 'Italia', 'milán': 'Italia', 'milan': 'Italia',
    'italia': 'Italia', 'italy': 'Italia',
   
    'london': 'Reino Unido', 'londres': 'Reino Unido',
    'manchester': 'Reino Unido', 'reino unido': 'Reino Unido',
    
    'sydney': 'Australia', 'melbourne': 'Australia', 'australia': 'Australia',
    
    'toronto': 'Canadá', 'vancouver': 'Canadá', 'montreal': 'Canadá',
    'canada': 'Canadá', 'canadá': 'Canadá',
     
    'mumbai': 'India', 'delhi': 'India', 'india': 'India',
   
    'beijing': 'China', 'shanghai': 'China', 'china': 'China',
     
    'tokyo': 'Japón', 'osaka': 'Japón', 'japón': 'Japón', 'japan': 'Japón',
 
    'seoul': 'Corea del Sur', 'busan': 'Corea del Sur',
    'korea': 'Corea del Sur',
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
     print('Error al cargar verificaciones: $e');
     
    } finally {
      isLoadingVerifications.value = false;
    }
  }
 
  void clearPhoneForm({String? userCity}) {
    phoneController.clear();
    _autoSelectCountry(userCity);
  }

  void _autoSelectCountry(String? userCity) {
    if (userCity == null || userCity.isEmpty) {
      selectedCountry.value = '';
      selectedDialCode.value = '';
      selectedCountryFlag.value = '';
      return;
    }

    final cityLower = userCity.toLowerCase();
    String? countryName;

    for (final entry in _cityToCountry.entries) {
      if (cityLower.contains(entry.key) || entry.key.contains(cityLower)) {
        countryName = entry.value;
        break;
      }
    }

    if (countryName != null) {
      final country = countries.firstWhereOrNull(
        (c) => c['name'] == countryName,
      );
      if (country != null) {
        selectCountry(country);
        return;
      }
    }

    selectedCountry.value = '';
    selectedDialCode.value = '';
    selectedCountryFlag.value = '';
  }

  Future<void> submitPhone() async {
    final numero = phoneController.text.trim();
    if (numero.isEmpty) {
      showErrorSnackbarGetx(_l.t('verify_phone_empty'));
      return;
    }
    if (selectedCountry.value.isEmpty) {
      showErrorSnackbarGetx(_l.t('verify_country_empty'));
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
      showSuccessSnackbarGetx(_l.t('verify_phone_success'));
    } catch (e) {
      showErrorSnackbarGetx('$e');
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
      showErrorSnackbarGetx(_l.t('verify_username_empty'));
      return;
    }
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      showErrorSnackbarGetx(_l.t('verify_browser_error'));
    }
  }

  Future<void> submitSocial() async {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      showErrorSnackbarGetx(_l.t('verify_username_empty'));
      return;
    }
    if (generatedSocialUrl.value.isEmpty) {
      showErrorSnackbarGetx(_l.t('verify_url_error'));
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
      showSuccessSnackbarGetx(_l.t('verify_social_success'));
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
      showErrorSnackbarGetx(_l.t('verify_selfie_empty'));
      return;
    }
    if (profilePhotoUrl.isEmpty) {
      showErrorSnackbarGetx(_l.t('verify_no_profile_photo'));
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
      showSuccessSnackbarGetx(_l.t('verify_selfie_success'));
    } catch (e) {
      showErrorSnackbarGetx('$e');
    } finally {
      isSubmittingSelfie.value = false;
    }
  }
}