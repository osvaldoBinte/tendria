// lib/features/user/presentation/controller/profile_controller.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/common/widgets/alert/custom_alert_type.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/entities/upload_media_entity.dart';
import 'package:tendria/features/user/domain/usecase/delete_media_usecase.dart';
import 'package:tendria/features/user/domain/usecase/get_user_usecase.dart';
import 'package:tendria/features/user/domain/usecase/upload_media_usecase.dart';
import 'package:tendria/features/user/domain/usecase/upload_picture_perfile_usecase.dart';

class ProfileController extends GetxController {
  final GetUserUsecase getUserUsecase;
  final UploadMediaUsecase uploadMediaUsecase;
  final UploadPicturePerfileUsecase uploadPicturePerfileUsecase;
 final DeleteMediaUsecase deleteMediaUsecase;
  ProfileController({
    required this.getUserUsecase,
    required this.uploadMediaUsecase,
    required this.uploadPicturePerfileUsecase,
    required this.deleteMediaUsecase
  });

  // Estados
  final RxBool isLoading = false.obs;
  final RxBool isUploadingPhoto = false.obs;
  final RxBool isUploadingProfilePhoto = false.obs;
    final RxBool isDeletingPhoto = false.obs; 
final RxString _cachedProfilePhotoUrl = ''.obs;

  final Rx<GetUserEntity?> userEntity = Rx<GetUserEntity?>(null);
  
  final ImagePicker _picker = ImagePicker();
  
  String get userName => userEntity.value?.name ?? 'Usuario';
  int get userAge => userEntity.value?.age ?? 0;
String get profilePhotoUrl {
  final current = userEntity.value?.fotoUrl ?? '';
  if (current.isNotEmpty) {
    _cachedProfilePhotoUrl.value = current;
  }
  return _cachedProfilePhotoUrl.value;
}
  String get profileBio => userEntity.value?.bio ?? '';
  String get  gender => userEntity.value?.gender ?? '';
  String get  primarylanguage => userEntity.value?.primarylanguage ?? '';
  int get  heightcm => userEntity.value?.heightcm ?? 0;
  List<AssetEntity> get assets => userEntity.value?.assets ?? [];
  List<QualitiesIdsEntity> get qualities => userEntity.value?.qualitiesIds ?? [];
  List<InterestsIdsEntity> get interests => userEntity.value?.interestsIds ?? [];
  String get city => userEntity.value?.city ?? '';
  String get status => userEntity.value?.status ?? '';

String get formattedDateOfBirth {
  final date = userEntity.value?.dateofbirth ?? '';
  if (date.isEmpty) return '';
  return date.split('T').first; 
}
  final int maxPhotos = 6;
  
@override
void onInit() {
  super.onInit();
  if (userEntity.value == null) {
    loadUserProfile();
  }
}
Future<void> loadUserProfile() async {
  try {
    isLoading.value = true;
    
    final user = await getUserUsecase.execute();
    userEntity.value = user; 
  } catch (e) {
    print('Error cargando perfil: $e');
  } finally {
    isLoading.value = false;
  }
}


Future<void> deletePhoto(int mediaId) async {
  try {
    isDeletingPhoto.value = true;

    final photoUrl = assets.firstWhereOrNull((a) => a.id == mediaId)?.url;

    await deleteMediaUsecase.execute(mediaId);

    if (photoUrl != null) {
      await CachedNetworkImage.evictFromCache(photoUrl); 
    }

    await loadUserProfile();
    showSuccessSnackbar('La foto se ha eliminado correctamente');
  } catch (e) {
    showErrorSnackbar('No se pudo eliminar la foto: ${cleanExceptionMessage(e)}');
  } finally {
    isDeletingPhoto.value = false;
  }
}

  void confirmDeletePhoto(int mediaId) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: 'Eliminar foto',
        message: '¿Estás seguro que deseas eliminar esta foto?',
        confirmText: 'Eliminar',
        cancelText: 'Cancelar',
        type: CustomAlertType.warning,
        onCancel: () => Get.back(),
        onConfirm: () {
          Get.back();
          deletePhoto(mediaId);
        },
      );
    }
  }
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

              Padding(
                padding: EdgeInsets.all(ThemeColor.paddingMedium),
                child: Column(
                  children: [
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

    // Guardar URL vieja para limpiar su cache
    final oldUrl = userEntity.value?.fotoUrl ?? '';
    final oldCacheKey = Uri.tryParse(oldUrl)?.path ?? oldUrl; // 👈

    await uploadPicturePerfileUsecase.execute(photoPath);
    await loadUserProfile();

    // Limpiar cache de la foto anterior para que muestre la nueva
    if (oldCacheKey.isNotEmpty) {
      await CachedNetworkImage.evictFromCache(oldCacheKey); // 👈
    }

    _showSuccessAlert('¡Listo!', 'Tu foto de perfil se ha actualizado correctamente');
  } catch (e) {
    _showErrorAlert('Error', 'No se pudo actualizar la foto: ${cleanExceptionMessage(e)}');
  } finally {
    isUploadingProfilePhoto.value = false;
  }
}

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
        // Header
        Container(
          padding: EdgeInsets.all(ThemeColor.paddingLarge),
          decoration: BoxDecoration(
            color: ThemeColor.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
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
                  Icons.photo_library,
                  color: ThemeColor.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: ThemeColor.paddingMedium),
              Expanded(
                child: Text(
                  'Agregar fotos',
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
              _buildPhotoOption(
                icon: Icons.photo_library,
                title: 'Galería (selección múltiple)',
                subtitle: 'Selecciona varias fotos de jalón',
                onTap: () {
                  Get.back();
                  pickMultipleImagesFromGallery();
                },
              ),
              SizedBox(height: ThemeColor.paddingSmall),
              _buildPhotoOption(
                icon: Icons.camera_alt,
                title: 'Tomar foto',
                subtitle: 'Captura una nueva foto',
                onTap: () {
                  Get.back();
                  takePhoto();
                },
              ),
              SizedBox(height: ThemeColor.paddingSmall),
            ],
          ),
        ),
      ],
    ),
  );
}
/// Selección múltiple de imágenes de galería
Future<void> pickMultipleImagesFromGallery() async {
  final remaining = maxPhotos - assets.length;
  if (remaining <= 0) return;

  try {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isEmpty) return;

    // Limitar a las que caben
    final toUpload = images.take(remaining).toList();

    if (images.length > remaining) {
      showSuccessSnackbar(
        'Solo se subirán $remaining fotos (límite del perfil)',
      );
    }

    await uploadMultiplePhotos(toUpload.map((e) => e.path).toList());
  } catch (e) {
    print('Error seleccionando fotos: $e');
    showErrorSnackbar(
      'No se pudo seleccionar las fotos: ${cleanExceptionMessage(e)}',
    );
  }
}

/// Sube múltiples fotos en una sola llamada
Future<void> uploadMultiplePhotos(List<String> paths) async {
  if (paths.isEmpty) return;

  try {
    isUploadingPhoto.value = true;

    final mediaEntities = paths
        .map((path) => UploadMediaEntity(mediaPath: path))
        .toList();

    await uploadMediaUsecase.execute(mediaEntities);

    await loadUserProfile();

    showSuccessSnackbar(
      '${paths.length} foto${paths.length > 1 ? 's' : ''} agregada${paths.length > 1 ? 's' : ''} correctamente',
    );
  } catch (e) {
    print('Error subiendo fotos: $e');
    showErrorSnackbar(
      'No se pudo subir las fotos: ${cleanExceptionMessage(e)}',
    );
  } finally {
    isUploadingPhoto.value = false;
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
      
      showErrorSnackbar(
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

      showSuccessSnackbar(
      
        'Tu foto se ha agregado correctamente',
      );
    } catch (e) {
      print('Error subiendo foto: $e');
      showErrorSnackbar(
    
        'No se pudo subir la foto: ${cleanExceptionMessage(e)}',
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  
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
  void onViewBlockedUsers() {
    Get.toNamed(RoutesNames.blockedUsersPage);
  }
  void onHelpTap() {
    Get.toNamed(RoutesNames.updateProfilePage);
  }
  void onViewNotifications() {
    Get.toNamed(RoutesNames.notificationPage);
  }

  void onEditProfile() {
    print('Editar perfil');
  }


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