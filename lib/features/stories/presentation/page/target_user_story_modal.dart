import 'package:flutter/material.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';
import 'package:tendria/features/stories/presentation/page/story_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

/// Muestra el modal de historias para un usuario específico distinto al propio.
/// Llama a [StoryController.fetchStoriesForUser] antes de abrir.
void showTargetUserStoryModal(
  BuildContext context, {
  required int userId,
  required String userName,
  String? userPhoto,
}) async {
  final StoryController controller = Get.find<StoryController>();

  // Carga las historias; si no hay, no abrimos el modal
  final hasStories = await controller.fetchStoriesForUser(userId);
  if (!hasStories) return;

  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return TargetUserStoryModal(
          userName: userName,
          userPhoto: userPhoto,
        );
      },
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class TargetUserStoryModal extends StatefulWidget {
  final String userName;
  final String? userPhoto;

  const TargetUserStoryModal({
    Key? key,
    required this.userName,
    this.userPhoto,
  }) : super(key: key);

  @override
  _TargetUserStoryModalState createState() => _TargetUserStoryModalState();
}

class _TargetUserStoryModalState extends State<TargetUserStoryModal>
    with TickerProviderStateMixin {
  final StoryController controller = Get.find<StoryController>();

  @override
  void initState() {
    super.initState();
    controller.initializeTargetUserStoryModal(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: ThemeColor.textDarkColor,
          elevation: 4,
          shadowColor: ThemeColor.shadowColor,
        ),
      ),
      body: Obx(() {
        if (!controller.isModalActive.value) {
          return const SizedBox.shrink();
        }

        final currentStory = controller.currentTargetStory;

        if (currentStory == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final stories = controller.targetUserStories;

        return Material(
          color: Colors.black,
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                // Contenido de la historia
                Positioned.fill(child: _buildStoryContent(currentStory)),

                // Header con progress y datos del usuario
                Positioned(
                  top: -30,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 8,
                      right: 8,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Barra de progreso
                        Row(
                          children: List.generate(
                            stories.length,
                            (index) => Expanded(
                              child: Container(
                                height: 3,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                child: AnimatedBuilder(
                                  animation: controller.progressAnimation!,
                                  builder: (context, child) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: controller
                                            .getTargetStoryProgressAt(index),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Info del usuario
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: ClipOval(
                                child: widget.userPhoto != null &&
                                        widget.userPhoto!.isNotEmpty
                                    ? Image.network(
                                        widget.userPhoto!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _fallbackAvatar(),
                                      )
                                    : _fallbackAvatar(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userName,
                                    style: GoogleFonts.rubik(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 3,
                                          color:
                                              Colors.black.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    controller
                                        .getTimeAgo(currentStory.fechaCreacion),
                                    style: GoogleFonts.rubik(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Botón cerrar
                            GestureDetector(
                              onTap: () {
                                controller.disposeStoryModal();
                                Get.back();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(Icons.close,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer con like
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: SizedBox(
                      height: 50,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // Like para historias de usuario objetivo
                            // puedes llamar controller.likeTargetStory() si lo implementas
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              currentStory.yaLikeada
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: currentStory.yaLikeada
                                  ? Colors.red
                                  : Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Zona izquierda – historia anterior
                Positioned(
                  top: 110,
                  bottom: 76 + MediaQuery.of(context).padding.bottom,
                  left: 0,
                  width: screenWidth * 0.3,
                  child: GestureDetector(
                    onTap: () => controller.previousTargetStory(),
                    onLongPress: () => controller.pauseStory(),
                    onLongPressEnd: (_) => controller.resumeStory(),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Zona derecha – historia siguiente
                Positioned(
                  top: 110,
                  bottom: 76 + MediaQuery.of(context).padding.bottom,
                  right: 0,
                  width: screenWidth * 0.3,
                  child: GestureDetector(
                    onTap: () => controller.nextTargetStory(),
                    onLongPress: () => controller.pauseStory(),
                    onLongPressEnd: (_) => controller.resumeStory(),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // Zona central – solo pausar
                Positioned(
                  top: 110,
                  bottom: 76 + MediaQuery.of(context).padding.bottom,
                  left: screenWidth * 0.3,
                  right: screenWidth * 0.3,
                  child: GestureDetector(
                    onLongPress: () => controller.pauseStory(),
                    onLongPressEnd: (_) => controller.resumeStory(),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: ThemeColor.primaryColor.withOpacity(0.3),
      child: const Icon(Icons.person, color: Colors.white, size: 24),
    );
  }

  Widget _buildStoryContent(StoryEntity story) {
    final isVideo = story.tipoContenido.toLowerCase() == 'video';

    if (isVideo) {
      return Obx(() {
        if (controller.videoController != null &&
            controller.isVideoInitialized.value) {
          return Center(
            child: AspectRatio(
              aspectRatio: controller.videoController!.value.aspectRatio,
              child: VideoPlayer(controller.videoController!),
            ),
          );
        } else {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Cargando video...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }
      });
    } else {
      return Image.network(
        story.urlContenido,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child:
                  Icon(Icons.error_outline, color: Colors.white, size: 50),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
      );
    }
  }
}