import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tendria/common/services/auth_service.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/stories/domain/entities/getstories/get_stories_entity.dart';
import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';
import 'package:tendria/features/stories/domain/entities/post/post_stories_entity.dart';
import 'package:tendria/features/stories/domain/usecase/add_like_to_story_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/create_strory_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/fetch_stories_by_id_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/fetch_stories_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/remove_story_usecase.dart';
import 'package:tendria/features/stories/domain/usecase/set_story_as_seen_usecase.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class StoryController extends GetxController with GetTickerProviderStateMixin {
  final FetchStoriesUsecase fetchStoriesUsecase;
  final AddLikeToStoryUsecase addLikeToStoryUsecase;
  final FetchStoriesByIdUsecase fetchStoriesByIdUsecase;
  final RemoveStoryUsecase removeStoryUsecase;
  final CreateStroryUsecase createStroryUsecase;
  final SetStoryAsSeenUsecase setStoryAsSeenUsecase;
  AuthService authService = AuthService();
  final RxBool isModalActive = false.obs;

  StoryController({
    required this.fetchStoriesUsecase,
    required this.addLikeToStoryUsecase,
    required this.fetchStoriesByIdUsecase,
    required this.removeStoryUsecase,
    required this.createStroryUsecase,
    required this.setStoryAsSeenUsecase
  });

  final RxList<GetStoriesEntity> allStories = <GetStoriesEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isViewingMyStory = false.obs;

  final RxList<StoryEntity> myStories = <StoryEntity>[].obs;
  final RxBool isLoadingMyStory = false.obs;
  final RxBool hasMyStory = false.obs;

  final RxInt currentMyStoryIndex = 0.obs;
  final RxInt currentUserIndex = 0.obs;
  final RxInt currentStoryIndex = 0.obs;
  final RxBool isCreatingStory = false.obs;

  // ✅ NUEVO: Controlador de video y estado
  VideoPlayerController? videoController;
  final RxBool isVideoInitialized = false.obs;
  
  AnimationController? progressController;
  Animation<double>? progressAnimation;

  // ✅ NUEVO: Duración por defecto y actual
  Duration _defaultStoryDuration = const Duration(seconds: 5);
  Duration _currentStoryDuration = const Duration(seconds: 5);

  GetStoriesEntity? get currentUser =>
      allStories.isNotEmpty ? allStories[currentUserIndex.value] : null;
StoryEntity? get currentStory {
  if (!isModalActive.value) return null;
  if (currentUser == null || currentUser!.historias.isEmpty) return null;
  if (currentStoryIndex.value >= currentUser!.historias.length) return null;
  return currentUser!.historias[currentStoryIndex.value];
}

StoryEntity? get currentMyStory {
  if (!isModalActive.value) return null;
  if (myStories.isEmpty) return null;
  if (currentMyStoryIndex.value >= myStories.length) return null;
  return myStories[currentMyStoryIndex.value];
}

List<StoryEntity> get currentUserStories {
  if (!isModalActive.value) return [];
  return currentUser?.historias ?? [];
}
  List<GetStoriesEntity> getStoriesForDisplay() {
    return allStories;
  }
  
  bool get isMyStoryActive => isViewingMyStory.value;
  
  StoryEntity? get activeStory {
    if (isViewingMyStory.value) {
      return currentMyStory;
    }
    return currentStory;
  }

  @override
  void onInit() {
    super.onInit();
    fetchStories();
    fetchMyStory();
  }

  @override
  void onClose() {
    progressController?.dispose();
    videoController?.dispose();
    super.onClose();
  }

  // ✅ NUEVO: Inicializar video si es necesario
  Future<void> initializeVideoIfNeeded() async {
    final story = isViewingMyStory.value 
        ? currentMyStory
        : currentStory;

    if (story == null) return;

    if (story.tipoContenido.toLowerCase() == 'video') {
      // Pausar mientras carga
      pauseStory();
      await _initializeVideo(story.urlContenido);
    } else {
      // Para imágenes, usar duración por defecto
      setStoryDuration(_defaultStoryDuration);
    }
  }

  // ✅ NUEVO: Inicializar video
  Future<void> _initializeVideo(String videoUrl) async {
    try {
      // Limpiar video anterior
      videoController?.dispose();
      videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      
      await videoController!.initialize();
      videoController!.setLooping(true);
      videoController!.play();
      
      isVideoInitialized.value = true;
      
      // ✅ Establecer la duración del video y empezar la animación
      final videoDuration = videoController!.value.duration;
      setStoryDuration(videoDuration);
      
    } catch (e) {
      debugPrint('Error initializing video: $e');
      // Usar duración por defecto si falla
      setStoryDuration(_defaultStoryDuration);
    }
  }

  // ✅ NUEVO: Establecer duración de la historia
  void setStoryDuration(Duration duration) {
    _currentStoryDuration = duration;
    if (progressController != null) {
      progressController!.duration = duration;
      progressController!.reset();
      progressController!.forward();
    }
  }

  // ✅ NUEVO: Limpiar video
  void disposeVideo() {
    videoController?.dispose();
    videoController = null;
    isVideoInitialized.value = false;
  }

  // ✅ NUEVO: Verificar y actualizar video si cambió
  Future<void> checkAndUpdateVideo(StoryEntity newStory) async {
    final isVideo = newStory.tipoContenido.toLowerCase() == 'video';
    
    if (isVideo) {
      if (videoController == null || 
          videoController!.dataSource != newStory.urlContenido) {
        pauseStory();
        isVideoInitialized.value = false;
        await _initializeVideo(newStory.urlContenido);
      }
    } else {
      disposeVideo();
      setStoryDuration(_defaultStoryDuration);
    }
  }List<StoryEntity> _sortStoriesByDate(List<StoryEntity> stories) {
  final sortedStories = List<StoryEntity>.from(stories);

  sortedStories.sort((a, b) {
    try {
      return a.fechaCreacion.compareTo(b.fechaCreacion);
    } catch (e) {
      debugPrint('Error comparing dates: $e');
      return 0;
    }
  });

  return sortedStories;
}

void initializeMyStoryModal(TickerProvider vsync) {
  // ✅ NUEVO: Marcar modal como activo
  isModalActive.value = true;
  
  isViewingMyStory.value = true;
  currentUserIndex.value = -1;
  currentStoryIndex.value = 0;
  currentMyStoryIndex.value = 0;
  _setupProgressController(vsync);
  initializeVideoIfNeeded();
}

  bool hasUnviewedStories(int index) {
    if (index >= allStories.length) return false;
    final stories = allStories[index].historias;
    return stories.any((story) => !story.yaVista);
  }

  String? getUserProfileImage(int index) {
    if (index >= allStories.length) return null;
    return allStories[index].fotoPerfilUrl;
  }

  String? getUserName(int index) {
    if (index >= allStories.length) return null;
    return allStories[index].nombreDoctor;
  }

  String get activeUserName {
    if (isViewingMyStory.value) {
      return "Mi historia";
    }
    return currentUser?.nombreDoctor ?? "";
  }

  String get activeUserImage {
    if (isViewingMyStory.value) {
      return "";
    }
    return currentUser?.fotoPerfilUrl ?? "";
  }
  
  void disposeStoryModal() {
  // ✅ CRÍTICO: Marcar modal como inactivo PRIMERO
  isModalActive.value = false;
  
  // Detener video ANTES de cualquier otra cosa
  if (videoController != null) {
    videoController!.pause();
    videoController!.dispose();
    videoController = null;
  }
  
  isVideoInitialized.value = false;
  
  // Detener y limpiar animaciones
  progressController?.stop();
  progressController?.dispose();
  progressController = null;
  
  progressAnimation = null;
  
  // Resetear el flag de "Mi Historia"
  isViewingMyStory.value = false;
  
  // Resetear índices
  currentStoryIndex.value = 0;
  currentMyStoryIndex.value = 0;
  currentUserIndex.value = 0;
  
  // Resetear duración
  _currentStoryDuration = _defaultStoryDuration;
}
 void closeStoryModal() {
  disposeStoryModal(); // ✅ CAMBIO: Usar el método de limpieza completo
  Get.back();
}


  Future<void> fetchStories() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final stories = await fetchStoriesUsecase.execute();
      
      // ✅ ORDENAR las historias de cada usuario
      final sortedStories = stories.map((userStory) {
        return GetStoriesEntity(
          doctorId: userStory.doctorId,
          nombreDoctor: userStory.nombreDoctor,
          fotoPerfilUrl: userStory.fotoPerfilUrl,
          historias: _sortStoriesByDate(userStory.historias),
        );
      }).toList();
      
      allStories.value = sortedStories;
      
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> createStory(File file, String contentType) async {
    try {
      isCreatingStory.value = true;

      final filePath = file.path;

      final entity = PostStoriesEntity(
        contentType: contentType,
        file: filePath,
      );

      await createStroryUsecase.execute(entity);

      await fetchMyStory();
      await fetchStories();

      isCreatingStory.value = false;
      showSuccessSnackbar('Historia creada exitosamente');
      Get.back();
    } catch (e) {
      isCreatingStory.value = false;
      showErrorSnackbar('No se pudo crear la historia $e');
    }
  }
String getTimeAgo(DateTime fechaCreacion) {
  try {
    final createdDate = fechaCreacion; 
    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  } catch (e) {
    debugPrint('Error parsing date: $e');
    return '';
  }
}

  Future<void> fetchMyStory() async {
    try {
      isLoadingMyStory.value = true;
      final userId = await authService.getUserId();
      
      if (userId == null) {
        isLoadingMyStory.value = false;
        hasMyStory.value = false;
        myStories.clear();
        return;
      }

      final stories = await fetchStoriesByIdUsecase.execute(userId);
      
      // ✅ ORDENAR mis historias por fecha de creación
      myStories.value = _sortStoriesByDate(stories);
      hasMyStory.value = stories.isNotEmpty;
      isLoadingMyStory.value = false;
    } catch (e) {
      myStories.clear();
      hasMyStory.value = false;
      isLoadingMyStory.value = false;
    }
  }

  String getContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 'Foto';
    }
    
    if (['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', 'webm', '3gp'].contains(extension)) {
      return 'Video';
    }
    
    return 'Foto';
  }

  Future<void> deleteMyStory() async {
    if (currentMyStory == null) return;

    try {
      await removeStoryUsecase.execute(currentMyStory!.id);
      
      myStories.removeAt(currentMyStoryIndex.value);
      
      if (myStories.isEmpty) {
        hasMyStory.value = false;
        disposeVideo(); // ✅ NUEVO: Limpiar video
        Get.back();
      } else {
        if (currentMyStoryIndex.value >= myStories.length) {
          currentMyStoryIndex.value = myStories.length - 1;
        }
        // ✅ NUEVO: Verificar y actualizar video para la nueva historia
        await checkAndUpdateVideo(currentMyStory!);
      }
      
      showSuccessSnackbar('Historia eliminada correctamente');
      await fetchStories();
    } catch (e) {
      showErrorSnackbar('No se pudo eliminar la historia');
    }
  }

void initializeStoryModal(int userIndex, TickerProvider vsync) {
  // ✅ NUEVO: Marcar modal como activo
  isModalActive.value = true;
  
  isViewingMyStory.value = false;
  currentUserIndex.value = userIndex;
  currentStoryIndex.value = 0;
  _setupProgressController(vsync);
  initializeVideoIfNeeded();
  _markCurrentStoryAsSeen();
}


  void _setupProgressController(TickerProvider vsync) {
    progressController?.dispose();
    
    progressController = AnimationController(
      duration: _currentStoryDuration, // ✅ CAMBIO: Usar duración configurable
      vsync: vsync,
    );

    progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: progressController!,
      curve: Curves.linear,
    ));

    // ✅ CAMBIO: No iniciar automáticamente, esperar a que el video cargue
    // progressController!.forward();

    progressController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isViewingMyStory.value) {
          nextMyStory();
        } else {
          nextStory();
        }
      }
    });
  }

  void nextMyStory() async {
    if (currentMyStoryIndex.value + 1 < myStories.length) {
      currentMyStoryIndex.value++;
      // ✅ NUEVO: Verificar y actualizar video
      await checkAndUpdateVideo(currentMyStory!);
    } else {
      goToFirstUserStory();
    }
  }

  void previousMyStory() async {
    if (currentMyStoryIndex.value > 0) {
      currentMyStoryIndex.value--;
      // ✅ NUEVO: Verificar y actualizar video
      await checkAndUpdateVideo(currentMyStory!);
    }
  }

  void goToFirstUserStory() {
    if (allStories.isNotEmpty) {
      isViewingMyStory.value = false;
      currentUserIndex.value = 0;
      currentStoryIndex.value = 0;
      disposeVideo(); // ✅ NUEVO: Limpiar video de mis historias
      initializeVideoIfNeeded(); // ✅ NUEVO: Inicializar video del primer usuario
      _markCurrentStoryAsSeen();
    } else {
      disposeVideo();
      Get.back();
    }
  }

  void nextStory() async {
    if (currentStoryIndex.value + 1 < currentUserStories.length) {
      currentStoryIndex.value++;
      // ✅ NUEVO: Verificar y actualizar video
      await checkAndUpdateVideo(currentStory!);
      _markCurrentStoryAsSeen();
    } else {
      if (currentUserIndex.value + 1 < allStories.length) {
        currentUserIndex.value++;
        currentStoryIndex.value = 0;
        // ✅ NUEVO: Verificar y actualizar video
        await checkAndUpdateVideo(currentStory!);
        _markCurrentStoryAsSeen();
      } else {
        disposeVideo();
        Get.back();
      }
    }
  }

  void previousStory() async {
    if (isViewingMyStory.value) {
      if (currentMyStoryIndex.value == 0) {
        return;
      }
      previousMyStory();
    } else if (currentUserIndex.value == 0 && currentStoryIndex.value == 0 && hasMyStory.value) {
      isViewingMyStory.value = true;
      currentUserIndex.value = -1;
      currentStoryIndex.value = 0;
      currentMyStoryIndex.value = myStories.length - 1;
      // ✅ NUEVO: Verificar y actualizar video
      await checkAndUpdateVideo(currentMyStory!);
    } else if (currentStoryIndex.value > 0) {
      currentStoryIndex.value--;
      // ✅ NUEVO: Verificar y actualizar video
      await checkAndUpdateVideo(currentStory!);
    } else if (currentUserIndex.value > 0) {
      currentUserIndex.value--;
      final previousUserStories = allStories[currentUserIndex.value].historias;
      currentStoryIndex.value = previousUserStories.length - 1;
      // ✅ NUEVO: Verificar y actualizar video
      await checkAndUpdateVideo(currentStory!);
    }
  }

  Future<void> _markCurrentStoryAsSeen() async {
    if (isViewingMyStory.value) return;
    if (currentStory == null) return;
    if (currentStory!.yaVista) return;

    try {
      await setStoryAsSeenUsecase.execute(currentStory!.id);
      
      final userIndex = currentUserIndex.value;
      final storyIndex = currentStoryIndex.value;
      
      final updatedStory = StoryEntity(
        id: currentStory!.id,
        tipoContenido: currentStory!.tipoContenido,
        urlContenido: currentStory!.urlContenido,
        fechaCreacion: currentStory!.fechaCreacion,
        fechaExpiracion: currentStory!.fechaExpiracion,
        vistas: currentStory!.vistas + 1,
        likes: currentStory!.likes,
        yaVista: true,
        yaLikeada: currentStory!.yaLikeada,
      );

      final updatedStories = List<StoryEntity>.from(currentUserStories);
      updatedStories[storyIndex] = updatedStory;

      final updatedUser = GetStoriesEntity(
        doctorId: currentUser!.doctorId,
        nombreDoctor: currentUser!.nombreDoctor,
        fotoPerfilUrl: currentUser!.fotoPerfilUrl,
        historias: updatedStories,
      );

      final updatedAllStories = List<GetStoriesEntity>.from(allStories);
      updatedAllStories[userIndex] = updatedUser;
      allStories.value = updatedAllStories;
    } catch (e) {
      debugPrint('Error marking story as seen: $e');
    }
  }

  void pauseStory() {
    progressController?.stop();
    videoController?.pause();
  }

  void resumeStory() {
    progressController?.forward();
    videoController?.play();
  }

  double getMyStoryProgress() {
    if (isViewingMyStory.value) {
      return progressAnimation?.value ?? 0.0;
    }
    return 0.0;
  }

  double getMyStoryProgressAt(int index) {
    if (!isViewingMyStory.value) return 0.0;
    
    if (index < currentMyStoryIndex.value) {
      return 1.0;
    } else if (index == currentMyStoryIndex.value) {
      return progressAnimation?.value ?? 0.0;
    } else {
      return 0.0;
    }
  }

  Future<void> likeStory() async {
    if (currentStory == null) return;

    try {
      await addLikeToStoryUsecase.execute(currentStory!.id);
      
      final userIndex = currentUserIndex.value;
      final storyIndex = currentStoryIndex.value;
      
      final updatedStory = StoryEntity(
        id: currentStory!.id,
        tipoContenido: currentStory!.tipoContenido,
        urlContenido: currentStory!.urlContenido,
        fechaCreacion: currentStory!.fechaCreacion,
        fechaExpiracion: currentStory!.fechaExpiracion,
        vistas: currentStory!.vistas,
        likes: currentStory!.likes + 1,
        yaVista: currentStory!.yaVista,
        yaLikeada: true,
      );
      final updatedStories = List<StoryEntity>.from(currentUserStories);
      updatedStories[storyIndex] = updatedStory;

      final updatedUser = GetStoriesEntity(
        doctorId: currentUser!.doctorId,
        nombreDoctor: currentUser!.nombreDoctor,
        fotoPerfilUrl: currentUser!.fotoPerfilUrl,
        historias: updatedStories,
      );

      final updatedAllStories = List<GetStoriesEntity>.from(allStories);
      updatedAllStories[userIndex] = updatedUser;
      allStories.value = updatedAllStories;
     // showSuccessSnackbar('Te gusta la historia de ${currentUser!.nombreDoctor} ❤️');
    
    } catch (e) {
      showErrorSnackbar('No se pudo dar like a la historia');
    }
  }

  double getStoryProgress(int index) {
    if (index < currentStoryIndex.value) {
      return 1.0;
    } else if (index == currentStoryIndex.value) {
      return progressAnimation?.value ?? 0.0;
    } else {
      return 0.0;
    }
  }

  bool hasStories(int index) {
    return index < allStories.length && allStories[index].historias.isNotEmpty;
  }

  bool hasViewedAllStories(int index) {
    if (index >= allStories.length) return false;
    final stories = allStories[index].historias;
    return stories.every((story) => story.yaVista);
  }
  
}