import 'package:get/get.dart';
import 'package:tendria/common/errors/convert_message.dart';
import 'package:tendria/common/settings/routes_names.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/like/domain/usecase/get_like_by_users_usecase.dart';
import 'package:tendria/features/like/domain/entities/liked_by_users_entity.dart';

class LikedByUsersController extends GetxController {
  final GetLikeByUsersUsecase getLikeByUsersUsecase;

  LikedByUsersController({required this.getLikeByUsersUsecase});

  // Estados reactivos
  final RxList<LikedByUsersEntity> likedByUsers = <LikedByUsersEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLikedByUsers();
  }

  // Cargar usuarios que te dieron like
  Future<void> loadLikedByUsers() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Obtener el postId del usuario actual
      // Nota: Ajusta esto según tu lógica de negocio
      final postId = 0; // Puedes obtenerlo de AuthService o pasarlo como argumento

      final result = await getLikeByUsersUsecase.execute(postId);
      
      // Ordenar por fecha más reciente
      result.sort((a, b) => b.likedAt.compareTo(a.likedAt));
      
      likedByUsers.value = result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar usuarios: ${cleanExceptionMessage(e)}';
      print('Error loading liked by users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refrescar lista
  Future<void> refreshLikedByUsers() async {
    await loadLikedByUsers();
  }

  // Navegar al perfil del usuario
  void navigateToProfile(int userId) {
    Get.toNamed(RoutesNames.profileDetailPage, arguments: {
      'userId': userId,
    });
  }

  // Dar like de vuelta
  void likeBack(LikedByUsersEntity user) {
    showSuccessSnackbar('¡Match con ${user.username}!');
    // Aquí puedes llamar al usecase de toggle like si es necesario
    // await toggleLikeUsecase.execute(user.fromusererId, true);
  }

  // Formatear tiempo transcurrido
  String getTimeAgo(DateTime likedAt) {
    final now = DateTime.now();
    final difference = now.difference(likedAt);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return 'Hace ${(difference.inDays / 7).floor()}sem';
    }
  }
}