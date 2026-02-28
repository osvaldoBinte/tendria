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
    required this.setStoryAsSeenUsecase,
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

  // ── Historias de usuario específico (para preview de otros usuarios) ──
  final RxList<StoryEntity> targetUserStories = <StoryEntity>[].obs;
  final RxBool isLoadingTargetStories = false.obs;
  final RxBool isViewingTargetUserStory = false.obs;
  final RxInt currentTargetStoryIndex = 0.obs;

  VideoPlayerController? videoController;
  final RxBool isVideoInitialized = false.obs;

  AnimationController? progressController;
  Animation<double>? progressAnimation;

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

  /// Historia activa del usuario objetivo (preview desde NearbyUsers)
  StoryEntity? get currentTargetStory {
    if (!isModalActive.value) return null;
    if (targetUserStories.isEmpty) return null;
    if (currentTargetStoryIndex.value >= targetUserStories.length) return null;
    return targetUserStories[currentTargetStoryIndex.value];
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
    if (isViewingTargetUserStory.value) return currentTargetStory;
    if (isViewingMyStory.value) return currentMyStory;
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

  // ─────────────────────────────────────────────
  //  NUEVO: Cargar historias de un usuario por ID
  // ─────────────────────────────────────────────

  /// Obtiene las historias de un usuario específico (que NO es el propio).
  /// Retorna `true` si ese usuario tiene al menos una historia.
  Future<bool> fetchStoriesForUser(int userId) async {
    try {
      isLoadingTargetStories.value = true;
      final stories = await fetchStoriesByIdUsecase.execute(userId);
      targetUserStories.value = _sortStoriesByDate(stories);
      isLoadingTargetStories.value = false;
      return stories.isNotEmpty;
    } catch (e) {
      debugPrint('Error fetching stories for user $userId: $e');
      targetUserStories.clear();
      isLoadingTargetStories.value = false;
      return false;
    }
  }

  /// Inicializa el modal apuntando a las historias del usuario objetivo.
  void initializeTargetUserStoryModal(TickerProvider vsync) {
    isModalActive.value = true;
    isViewingTargetUserStory.value = true;
    isViewingMyStory.value = false;
    currentTargetStoryIndex.value = 0;
    _setupProgressController(vsync);
    _initializeVideoForTargetStory();
  }

  Future<void> _initializeVideoForTargetStory() async {
    final story = currentTargetStory;
    if (story == null) return;

    if (story.tipoContenido.toLowerCase() == 'video') {
      pauseStory();
      await _initializeVideo(story.urlContenido);
    } else {
      setStoryDuration(_defaultStoryDuration);
    }
  }

  void nextTargetStory() async {
    if (currentTargetStoryIndex.value + 1 < targetUserStories.length) {
      currentTargetStoryIndex.value++;
      await checkAndUpdateVideoForTarget(currentTargetStory!);
    } else {
      disposeVideo();
      Get.back();
    }
  }

  void previousTargetStory() async {
    if (currentTargetStoryIndex.value > 0) {
      currentTargetStoryIndex.value--;
      await checkAndUpdateVideoForTarget(currentTargetStory!);
    }
  }

  Future<void> checkAndUpdateVideoForTarget(StoryEntity story) async {
    final isVideo = story.tipoContenido.toLowerCase() == 'video';
    if (isVideo) {
      if (videoController == null ||
          videoController!.dataSource != story.urlContenido) {
        pauseStory();
        isVideoInitialized.value = false;
        await _initializeVideo(story.urlContenido);
      }
    } else {
      disposeVideo();
      setStoryDuration(_defaultStoryDuration);
    }
  }

  double getTargetStoryProgressAt(int index) {
    if (!isViewingTargetUserStory.value) return 0.0;
    if (index < currentTargetStoryIndex.value) return 1.0;
    if (index == currentTargetStoryIndex.value) {
      return progressAnimation?.value ?? 0.0;
    }
    return 0.0;
  }

  // ─────────────────────────────────────────────
  //  VIDEO
  // ─────────────────────────────────────────────

  Future<void> initializeVideoIfNeeded() async {
    final story = isViewingTargetUserStory.value
        ? currentTargetStory
        : isViewingMyStory.value
            ? currentMyStory
            : currentStory;

    if (story == null) return;

    if (story.tipoContenido.toLowerCase() == 'video') {
      pauseStory();
      await _initializeVideo(story.urlContenido);
    } else {
      setStoryDuration(_defaultStoryDuration);
    }
  }

  Future<void> _initializeVideo(String videoUrl) async {
    try {
      videoController?.dispose();
      videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await videoController!.initialize();
      videoController!.setLooping(true);
      videoController!.play();

      isVideoInitialized.value = true;

      final videoDuration = videoController!.value.duration;
      setStoryDuration(videoDuration);
    } catch (e) {
      debugPrint('Error initializing video: $e');
      setStoryDuration(_defaultStoryDuration);
    }
  }

  void setStoryDuration(Duration duration) {
    _currentStoryDuration = duration;
    if (progressController != null) {
      progressController!.duration = duration;
      progressController!.reset();
      progressController!.forward();
    }
  }

  void disposeVideo() {
    videoController?.dispose();
    videoController = null;
    isVideoInitialized.value = false;
  }

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
  }

  // ─────────────────────────────────────────────
  //  SORTING / HELPERS
  // ─────────────────────────────────────────────

  List<StoryEntity> _sortStoriesByDate(List<StoryEntity> stories) {
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

  // ─────────────────────────────────────────────
  //  MODAL – MI HISTORIA
  // ─────────────────────────────────────────────

  void initializeMyStoryModal(TickerProvider vsync) {
    isModalActive.value = true;
    isViewingMyStory.value = true;
    isViewingTargetUserStory.value = false;
    currentUserIndex.value = -1;
    currentStoryIndex.value = 0;
    currentMyStoryIndex.value = 0;
    _setupProgressController(vsync);
    initializeVideoIfNeeded();
  }

  // ─────────────────────────────────────────────
  //  MODAL – HISTORIA DE OTROS (lista general)
  // ─────────────────────────────────────────────

  void initializeStoryModal(int userIndex, TickerProvider vsync) {
    isModalActive.value = true;
    isViewingMyStory.value = false;
    isViewingTargetUserStory.value = false;
    currentUserIndex.value = userIndex;
    currentStoryIndex.value = 0;
    _setupProgressController(vsync);
    initializeVideoIfNeeded();
    _markCurrentStoryAsSeen();
  }

  // ─────────────────────────────────────────────
  //  DISPOSE MODAL
  // ─────────────────────────────────────────────

  void disposeStoryModal() {
    isModalActive.value = false;

    if (videoController != null) {
      videoController!.pause();
      videoController!.dispose();
      videoController = null;
    }

    isVideoInitialized.value = false;

    progressController?.stop();
    progressController?.dispose();
    progressController = null;
    progressAnimation = null;

    isViewingMyStory.value = false;
    isViewingTargetUserStory.value = false;

    currentStoryIndex.value = 0;
    currentMyStoryIndex.value = 0;
    currentTargetStoryIndex.value = 0;
    currentUserIndex.value = 0;

    _currentStoryDuration = _defaultStoryDuration;
  }

  void closeStoryModal() {
    disposeStoryModal();
    Get.back();
  }

  // ─────────────────────────────────────────────
  //  FETCH
  // ─────────────────────────────────────────────

  Future<void> fetchStories() async {
    try {
      isLoading.value = true;
      error.value = '';

      final stories = await fetchStoriesUsecase.execute();

      final sortedStories = stories.map((userStory) {
        return GetStoriesEntity(
          usuarioId: userStory.usuarioId,
          nombreUsuario: userStory.nombreUsuario,
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
      myStories.value = _sortStoriesByDate(stories);
      hasMyStory.value = stories.isNotEmpty;
      isLoadingMyStory.value = false;
    } catch (e) {
      myStories.clear();
      hasMyStory.value = false;
      isLoadingMyStory.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  CREATE / DELETE
  // ─────────────────────────────────────────────

  Future<void> createStory(File file, String contentType) async {
    try {
      isCreatingStory.value = true;

      final entity = PostStoriesEntity(
        contentType: contentType,
        file: file.path,
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

  Future<void> deleteMyStory() async {
    if (currentMyStory == null) return;

    try {
      await removeStoryUsecase.execute(currentMyStory!.id);

      myStories.removeAt(currentMyStoryIndex.value);

      if (myStories.isEmpty) {
        hasMyStory.value = false;
        disposeVideo();
        Get.back();
      } else {
        if (currentMyStoryIndex.value >= myStories.length) {
          currentMyStoryIndex.value = myStories.length - 1;
        }
        await checkAndUpdateVideo(currentMyStory!);
      }

      showSuccessSnackbar('Historia eliminada correctamente');
      await fetchStories();
    } catch (e) {
      showErrorSnackbar('No se pudo eliminar la historia');
    }
  }

  // ─────────────────────────────────────────────
  //  NAVIGATION – MIS HISTORIAS
  // ─────────────────────────────────────────────

  void nextMyStory() async {
    if (currentMyStoryIndex.value + 1 < myStories.length) {
      currentMyStoryIndex.value++;
      await checkAndUpdateVideo(currentMyStory!);
    } else {
      goToFirstUserStory();
    }
  }

  void previousMyStory() async {
    if (currentMyStoryIndex.value > 0) {
      currentMyStoryIndex.value--;
      await checkAndUpdateVideo(currentMyStory!);
    }
  }

  void goToFirstUserStory() {
    if (allStories.isNotEmpty) {
      isViewingMyStory.value = false;
      isViewingTargetUserStory.value = false;
      currentUserIndex.value = 0;
      currentStoryIndex.value = 0;
      disposeVideo();
      initializeVideoIfNeeded();
      _markCurrentStoryAsSeen();
    } else {
      disposeVideo();
      Get.back();
    }
  }

  // ─────────────────────────────────────────────
  //  NAVIGATION – HISTORIAS GENERALES
  // ─────────────────────────────────────────────

  void nextStory() async {
    if (currentStoryIndex.value + 1 < currentUserStories.length) {
      currentStoryIndex.value++;
      await checkAndUpdateVideo(currentStory!);
      _markCurrentStoryAsSeen();
    } else {
      if (currentUserIndex.value + 1 < allStories.length) {
        currentUserIndex.value++;
        currentStoryIndex.value = 0;
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
      if (currentMyStoryIndex.value == 0) return;
      previousMyStory();
    } else if (currentUserIndex.value == 0 &&
        currentStoryIndex.value == 0 &&
        hasMyStory.value) {
      isViewingMyStory.value = true;
      currentUserIndex.value = -1;
      currentStoryIndex.value = 0;
      currentMyStoryIndex.value = myStories.length - 1;
      await checkAndUpdateVideo(currentMyStory!);
    } else if (currentStoryIndex.value > 0) {
      currentStoryIndex.value--;
      await checkAndUpdateVideo(currentStory!);
    } else if (currentUserIndex.value > 0) {
      currentUserIndex.value--;
      final previousUserStories = allStories[currentUserIndex.value].historias;
      currentStoryIndex.value = previousUserStories.length - 1;
      await checkAndUpdateVideo(currentStory!);
    }
  }

  // ─────────────────────────────────────────────
  //  PROGRESS
  // ─────────────────────────────────────────────

  void _setupProgressController(TickerProvider vsync) {
    progressController?.dispose();

    progressController = AnimationController(
      duration: _currentStoryDuration,
      vsync: vsync,
    );

    progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: progressController!,
      curve: Curves.linear,
    ));

    progressController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isViewingTargetUserStory.value) {
          nextTargetStory();
        } else if (isViewingMyStory.value) {
          nextMyStory();
        } else {
          nextStory();
        }
      }
    });
  }

  double getMyStoryProgressAt(int index) {
    if (!isViewingMyStory.value) return 0.0;
    if (index < currentMyStoryIndex.value) return 1.0;
    if (index == currentMyStoryIndex.value) {
      return progressAnimation?.value ?? 0.0;
    }
    return 0.0;
  }

  double getStoryProgress(int index) {
    if (index < currentStoryIndex.value) return 1.0;
    if (index == currentStoryIndex.value) {
      return progressAnimation?.value ?? 0.0;
    }
    return 0.0;
  }

  double getMyStoryProgress() {
    if (isViewingMyStory.value) {
      return progressAnimation?.value ?? 0.0;
    }
    return 0.0;
  }

  // ─────────────────────────────────────────────
  //  PAUSE / RESUME
  // ─────────────────────────────────────────────

  void pauseStory() {
    progressController?.stop();
    videoController?.pause();
  }

  void resumeStory() {
    progressController?.forward();
    videoController?.play();
  }

  // ─────────────────────────────────────────────
  //  LIKE / SEEN
  // ─────────────────────────────────────────────

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
        usuarioId: currentUser!.usuarioId,
        nombreUsuario: currentUser!.nombreUsuario,
        fotoPerfilUrl: currentUser!.fotoPerfilUrl,
        historias: updatedStories,
      );

      final updatedAllStories = List<GetStoriesEntity>.from(allStories);
      updatedAllStories[userIndex] = updatedUser;
      allStories.value = updatedAllStories;
    } catch (e) {
      showErrorSnackbar('No se pudo dar like a la historia');
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
        usuarioId: currentUser!.usuarioId,
        nombreUsuario: currentUser!.nombreUsuario,
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

  // ─────────────────────────────────────────────
  //  UTILS
  // ─────────────────────────────────────────────

  String getContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 'Foto';
    }

    if (['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', 'webm', '3gp']
        .contains(extension)) {
      return 'Video';
    }

    return 'Foto';
  }

  String getTimeAgo(DateTime fechaCreacion) {
    try {
      final now = DateTime.now();
      final difference = now.difference(fechaCreacion);

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
    return allStories[index].nombreUsuario;
  }

  String get activeUserName {
    if (isViewingTargetUserStory.value) return '';
    if (isViewingMyStory.value) return 'Mi historia';
    return currentUser?.nombreUsuario ?? '';
  }

  String get activeUserImage {
    if (isViewingMyStory.value) return '';
    return currentUser?.fotoPerfilUrl ?? '';
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