// lib/features/user/presentation/controller/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/entities/upload_media_entity.dart';
import 'package:tendria/features/user/domain/usecase/get_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/upload_media_usecase.dart';
import 'package:tendria/features/user/domain/usecase/upload_picture_perfile_usecase.dart';

class ProfileController extends GetxController {
  final GetUserUsecase getUserUsecase;
  final UploadMediaUsecase uploadMediaUsecase;
  final UploadPicturePerfileUsecase uploadPicturePerfileUsecase;

  ProfileController({
    required this.getUserUsecase,
    required this.uploadMediaUsecase,
    required this.uploadPicturePerfileUsecase
  });

  // Estados
  final RxBool isLoading = false.obs;
  final RxBool isUploadingPhoto = false.obs;
  final RxBool isUploadingProfilePhoto = false.obs;
  
  // Datos del usuario
  final Rx<GetUserEntity?> userEntity = Rx<GetUserEntity?>(null);
  
  // ImagePicker
  final ImagePicker _picker = ImagePicker();
  
  // Getters para acceso fácil
  String get userName => userEntity.value?.name ?? 'Usuario';
  int get userAge => userEntity.value?.age ?? 0;
  String get profilePhotoUrl => userEntity.value?.fotoUrl ?? '';
  String get profileBio => userEntity.value?.bio ?? '';

  List<AssetEntity> get assets => userEntity.value?.assets ?? [];
  List<QualitiesIdsEntity> get qualities => userEntity.value?.qualitiesIds ?? [];
  List<InterestsIdsEntity> get interests => userEntity.value?.interestsIds ?? [];
  
  // Máximo de fotos permitidas
  final int maxPhotos = 6;
  
  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // ==========================================
  // CARGAR PERFIL
  // ==========================================
  
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = await getUserUsecase.execute();
      userEntity.value = user;
    } catch (e) {
      print('Error cargando perfil: $e');
      _showErrorAlert(
        'Error',
        'No se pudo cargar el perfil: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // FOTO DE PERFIL (PRINCIPAL)
  // ==========================================
  
 void showProfilePhotoOptions() {
  if (Get.context != null) {
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColor.surfaceColor,
            borderRadius: ThemeColor.extraLargeBorderRadius,
            boxShadow: [ThemeColor.darkShadow],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con título
              Container(
                padding: EdgeInsets.all(ThemeColor.paddingLarge),
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ThemeColor.extraLargeRadius),
                    topRight: Radius.circular(ThemeColor.extraLargeRadius),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: ThemeColor.primaryColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: ThemeColor.paddingMedium),
                    Expanded(
                      child: Text(
                        'Cambiar foto de perfil',
                        style: ThemeColor.headingSmall.copyWith(
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: ThemeColor.textSecondaryColor),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Opciones
              Padding(
                padding: EdgeInsets.all(ThemeColor.paddingMedium),
                child: Column(
                  children: [
                    // Opción Galería
                    _buildPhotoOption(
                      icon: Icons.photo_library,
                      title: 'Seleccionar de galería',
                      subtitle: 'Elige una foto de tus archivos',
                      onTap: () {
                        Get.back();
                        pickProfilePhotoFromGallery();
                      },
                    ),

                    SizedBox(height: ThemeColor.paddingSmall),

                    // Opción Cámara
                    _buildPhotoOption(
                      icon: Icons.camera_alt,
                      title: 'Tomar foto',
                      subtitle: 'Captura una nueva foto',
                      onTap: () {
                        Get.back();
                        takeProfilePhoto();
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: ThemeColor.paddingSmall),
            ],
          ),
        ),
      ),
    );
  }
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
        padding: EdgeInsets.all(ThemeColor.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(
            color: ThemeColor.dividerColor,
            width: 1,
          ),
          borderRadius: ThemeColor.mediumBorderRadius,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor.withOpacity(0.1),
                borderRadius: ThemeColor.smallBorderRadius,
              ),
              child: Icon(
                icon,
                color: ThemeColor.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: ThemeColor.paddingMedium),
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
                  SizedBox(height: 4),
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

  Future<void> pickProfilePhotoFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadProfilePhoto(image.path);
      }
    } catch (e) {
      print('Error seleccionando foto de perfil: $e');
      _showErrorAlert(
        'Error',
        'No se pudo seleccionar la foto: ${cleanExceptionMessage(e)}',
      );
    }
  }

  Future<void> takeProfilePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        await uploadProfilePhoto(photo.path);
      }
    } catch (e) {
      print('Error tomando foto de perfil: $e');
      _showErrorAlert(
        'Error',
        'No se pudo tomar la foto: ${cleanExceptionMessage(e)}',
      );
    }
  }

  Future<void> uploadProfilePhoto(String photoPath) async {
    try {
      isUploadingProfilePhoto.value = true;

      await uploadPicturePerfileUsecase.execute(photoPath);

      // Recargar perfil para obtener la nueva foto
      await loadUserProfile();

      _showSuccessAlert(
        '¡Listo!',
        'Tu foto de perfil se ha actualizado correctamente',
      );
    } catch (e) {
      print('Error subiendo foto de perfil: $e');
      _showErrorAlert(
        'Error',
        'No se pudo actualizar la foto de perfil: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isUploadingProfilePhoto.value = false;
    }
  }

  // ==========================================
  // MANEJO DE FOTOS DE GALERÍA
  // ==========================================
  
  Future<void> addPhoto() async {
    if (assets.length >= maxPhotos) {
      _showErrorAlert(
        'Límite alcanzado',
        'Puedes tener máximo $maxPhotos fotos en tu perfil',
      );
      return;
    }

    showPhotoOptions();
  }

  void showPhotoOptions() {
    if (Get.context != null) {
      showModalBottomSheet(
        context: Get.context!,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.black87),
                title: Text('Galería'),
                onTap: () {
                  Get.back();
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.black87),
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

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadPhoto(image.path);
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
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        await uploadPhoto(photo.path);
      }
    } catch (e) {
      print('Error tomando foto: $e');
      _showErrorAlert(
        'Error',
        'No se pudo tomar la foto: ${cleanExceptionMessage(e)}',
      );
    }
  }

  Future<void> uploadPhoto(String photoPath) async {
    try {
      isUploadingPhoto.value = true;

      final mediaEntity = UploadMediaEntity(mediaPath: photoPath);
      await uploadMediaUsecase.execute([mediaEntity]);

      // Recargar perfil para obtener la nueva foto
      await loadUserProfile();

      _showSuccessAlert(
        'Foto agregada',
        'Tu foto se ha agregado correctamente',
      );
    } catch (e) {
      print('Error subiendo foto: $e');
      _showErrorAlert(
        'Error',
        'No se pudo subir la foto: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  // ==========================================
  // NAVEGACIÓN
  // ==========================================
  
  void onSettingsTap() {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: 'Cerrar sesión',
        message: '¿Estás seguro que deseas cerrar sesión?',
        confirmText: 'Aceptar',
        cancelText: 'Cancelar',
        type: CustomAlertType.warning,
        onCancel: () => Get.back(),
        onConfirm: () {
          Get.back();
          AuthService authService = AuthService();
          authService.logout();
          Get.offAllNamed(RoutesNames.loginPage);
        },
      );
    }
  }

  void onHelpTap() {
    // Navegar a ayuda
    print('Ir a ayuda');
  }

  void onEditProfile() {
    // Navegar a editar perfil
    print('Editar perfil');
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
}