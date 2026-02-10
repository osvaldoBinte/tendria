import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:tendria/features/stories/presentation/page/create_story_controller.dart';
import 'package:tendria/features/stories/presentation/page/gallery_picker_screen.dart';
import 'package:tendria/features/stories/presentation/page/story_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class DraggableStoryText extends StatefulWidget {
  final String text;
  final Color color;
  final Offset position;
  final double scale;
  final bool isSelected;
  final Function(Offset) onPositionChanged;
  final Function(double) onScaleChanged;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DraggableStoryText({
    Key? key,
    required this.text,
    required this.color,
    required this.position,
    required this.scale,
    required this.isSelected,
    required this.onPositionChanged,
    required this.onScaleChanged,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  State<DraggableStoryText> createState() => _DraggableStoryTextState();
}

class _DraggableStoryTextState extends State<DraggableStoryText> {
  late Offset position;
  late double scale;
  double baseScale = 1.0;
  Offset basePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    position = widget.position;
    scale = widget.scale;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: position.dx * size.width - 100,
      top: position.dy * size.height - 50,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        // ✅ Usar solo onScaleUpdate para manejar tanto movimiento como zoom
        onScaleStart: (details) {
          baseScale = scale;
          basePosition = position;
        },
        onScaleUpdate: (details) {
          setState(() {
            // Actualizar escala
            if (details.scale != 1.0) {
              scale = (baseScale * details.scale).clamp(0.5, 3.0);
            }

            // Actualizar posición (funciona con 1 dedo para arrastrar)
            final newX =
                (basePosition.dx * size.width + details.focalPointDelta.dx) /
                size.width;
            final newY =
                (basePosition.dy * size.height + details.focalPointDelta.dy) /
                size.height;

            position = Offset(newX.clamp(0.0, 1.0), newY.clamp(0.0, 1.0));

            basePosition = position;
          });
        },
        onScaleEnd: (_) {
          widget.onPositionChanged(position);
          widget.onScaleChanged(scale);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Transform.scale(
            scale: scale,
            child: Text(
              widget.text,
              style: GoogleFonts.rubik(
                color: widget.color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Editor de texto (incluido inline)
class StoryTextEditor extends StatefulWidget {
  final Function(String text, Color color, Offset position, double scale)
  onTextAdded;

  const StoryTextEditor({Key? key, required this.onTextAdded})
    : super(key: key);

  @override
  State<StoryTextEditor> createState() => _StoryTextEditorState();
}

class _StoryTextEditorState extends State<StoryTextEditor> {
  final TextEditingController textController = TextEditingController();
  Color selectedColor = Colors.black;

  final List<Color> availableColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: textController,
            autofocus: true,
            style: GoogleFonts.rubik(
              color: selectedColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Escribe algo...',
              hintStyle: GoogleFonts.rubik(
                color: Colors.grey[400],
                fontSize: 24,
              ),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableColors.length,
              itemBuilder: (context, index) {
                final color = availableColors[index];
                final isSelected = color == selectedColor;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.grey[700]!,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      widget.onTextAdded(
                        textController.text,
                        selectedColor,
                        const Offset(0.5, 0.5),
                        1.0,
                      );
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Agregar',
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({Key? key}) : super(key: key);

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen>
    with WidgetsBindingObserver {
  final CreateStoryController controller = Get.put(CreateStoryController());
  final StoryController storyController = Get.find<StoryController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<CreateStoryController>();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    controller.handleAppLifecycleState(state);
  }

  Future<void> _publishStory() async {
    if (controller.capturedFile.value == null ||
        controller.contentType.value == null) {
      debugPrint('❌ No hay contenido para publicar');
      return;
    }

    debugPrint('📤 Iniciando publicación de historia...');
    debugPrint('📋 Tipo: ${controller.contentType.value}');
    debugPrint('📝 Cantidad de textos: ${controller.storyTexts.length}');

    File? finalFile = controller.capturedFile.value;

    // Si hay textos, procesar el contenido
    if (controller.storyTexts.isNotEmpty) {
      debugPrint('🔄 Procesando contenido con textos...');

      // Mostrar diálogo de procesamiento
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Procesando historia con textos...',
                    style: GoogleFonts.rubik(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esto puede tardar unos segundos',
                    style: GoogleFonts.rubik(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Capturar/procesar
      finalFile = await controller.captureStoryWithTexts();

      // Cerrar diálogo
      Get.back();

      debugPrint('📊 Resultado del procesamiento:');
      debugPrint('   - Archivo: ${finalFile?.path}');
      debugPrint('   - Tipo final: ${controller.contentType.value}');
    }

    if (finalFile == null) {
      debugPrint('❌ Error: archivo final es null');
      showErrorSnackbar('No se pudo procesar la historia');

      return;
    }

    // Verificar que el archivo exista
    if (!await finalFile.exists()) {
      debugPrint('❌ Error: el archivo no existe en ${finalFile.path}');
      showErrorSnackbar('El archivo procesado no existe');
      return;
    }

    debugPrint('✅ Publicando historia con archivo final: ${finalFile.path}');

    // Publicar
    await storyController.createStory(finalFile, controller.contentType.value!);
  }

  // ✅ CORREGIDO: Mostrar editor de texto (PERMITIR EN VIDEOS)
  void _showTextEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoryTextEditor(
        onTextAdded: (text, color, position, scale) {
          debugPrint('📝 Intentando agregar texto: "$text"');
          controller.addText(text, color, position, scale);
          debugPrint(
            '📊 Total de textos ahora: ${controller.storyTexts.length}',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.capturedFile.value != null) {
        return _buildPreviewScreen();
      }
      return _buildCameraScreen();
    });
  }

  Widget _buildCameraScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(() {
            final camController = controller.cameraController.value;

            if (!controller.isCameraInitialized.value ||
                camController == null) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Iniciando cámara...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!camController.value.isInitialized) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            return Center(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height:
                        MediaQuery.of(context).size.width *
                        camController.value.aspectRatio,
                    child: CameraPreview(camController),
                  ),
                ),
              ),
            );
          }),

          Obx(() {
            if (controller.isRecording.value) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 4),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          _buildHeader(),
          _buildGallery(),
          _buildCaptureButton(),
          _buildInstructionText(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),

              Obx(() {
                if (controller.isRecording.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${controller.recordingSeconds.value}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              GestureDetector(
                onTap: () => controller.switchCamera(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery() {
    return Positioned(
      bottom: 140,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 50,
        child: Obx(() {
          if (controller.isLoadingGallery.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.galleryAssets.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                   // Get.to(() => const GalleryPickerScreen());
                  },
                  child: ThemeColor.widgetButton(
                    onPressed: () {
                     Get.to(() => const GalleryPickerScreen());
                    },
                  
                  borderRadius: 50,
                  backgroundColor: ThemeColor.tertiaryColor,
                    text: 'Subir foto de galería',
                  ),
                  
                );
              }
            },
          );
        }),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() {
          return GestureDetector(
            onTap: controller.isRecording.value
                ? null
                : () => controller.takePicture(),
            onLongPressStart: (_) => controller.startRecording(),
            onLongPressEnd: (_) => controller.stopRecording(),
            onLongPressCancel: () => controller.stopRecording(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (controller.isRecording.value)
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value:
                          controller.recordingSeconds.value /
                          CreateStoryController.maxRecordingSeconds,
                      strokeWidth: 4,
                      color: Colors.red,
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  ),

                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: controller.isRecording.value
                        ? Colors.red
                        : Colors.white.withOpacity(0.3),
                  ),
                  child: controller.isRecording.value
                      ? const Center(
                          child: Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInstructionText() {
    return Obx(() {
      if (!controller.isRecording.value) {
        return Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Toca para foto • Mantén para video',
              style: GoogleFonts.rubik(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildPreviewScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () =>
            controller.selectText(null), // Deseleccionar al tocar fondo
        child: Stack(
          children: [
            RepaintBoundary(
              key: controller.repaintBoundaryKey,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Obx(() {
                      if (controller.contentType.value == 'Video') {
                        if (!controller.isVideoReady.value) {
                          return Container(
                            color: Colors.black,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Preparando video...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final videoCtrl = controller.videoController;
                        if (videoCtrl != null &&
                            videoCtrl.value.isInitialized) {
                          return Center(
                            child: AspectRatio(
                              aspectRatio: videoCtrl.value.aspectRatio,
                              child: VideoPlayer(videoCtrl),
                            ),
                          );
                        }

                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      return _buildImagePreview();
                    }),
                  ),

                  // ✅ Textos draggables
                  ...controller.storyTexts.map((storyText) {
                    return Obx(() {
                      return DraggableStoryText(
                        text: storyText.text,
                        color: storyText.color,
                        position: storyText.position,
                        scale: storyText.scale,
                        isSelected:
                            controller.selectedTextId.value == storyText.id,
                        onPositionChanged: (newPosition) {
                          controller.updateTextPosition(
                            storyText.id,
                            newPosition,
                          );
                        },
                        onScaleChanged: (newScale) {
                          controller.updateTextScale(storyText.id, newScale);
                        },
                        onTap: () {
                          controller.selectText(storyText.id);
                        },
                        onLongPress: () {
                          _showDeleteTextDialog(storyText.id);
                        },
                      );
                    });
                  }).toList(),
                ],
              ),
            ),

            // Header con botones (fuera del RepaintBoundary)
            _buildPreviewHeader(),

            // ✅ Botón de agregar texto (fuera del RepaintBoundary)
            _buildAddTextButton(),
          ],
        ),
      ),
    );
  }

 Widget _buildPreviewHeader() {
  return Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => controller.clearCapture(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // ✅ MOVIDO: Botón de texto aquí arriba
            Obx(() {
              if (controller.isVideoReady.value ||
                  controller.contentType.value == 'Foto') {
                return GestureDetector(
                  onTap: () {
                    debugPrint('👆 Botón de texto presionado');
                    debugPrint('📹 Tipo: ${controller.contentType.value}');
                    _showTextEditor();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.text_fields,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    ),
  );
}

// ✅ MODIFICADO: Botón de publicar abajo
Widget _buildAddTextButton() {
  return Positioned(
    bottom: 30,
    left: 0,
    right: 0,
    child: Obx(() {
      return Column(
        children: [
          // Botón eliminar texto seleccionado (arriba del botón publicar)
          if (controller.selectedTextId.value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  debugPrint(
                    '🗑️ Eliminando texto: ${controller.selectedTextId.value}',
                  );
                  controller.removeText(controller.selectedTextId.value!);
                  controller.selectText(null);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          
          // ✅ Botón de publicar (abajo)
          if (controller.isVideoReady.value ||
              controller.contentType.value == 'Foto')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: storyController.isCreatingStory.value
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : GestureDetector(
                      onTap: _publishStory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColor.tertiaryColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColor.tertiaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Publicar Historia',
                              style: GoogleFonts.rubik(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
const SizedBox(width: 12),
                            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                      
                          ],
                        ),
                      ),
                    ),
            ),
        ],
      );
    }),
  );
}

  Widget _buildImagePreview() {
    if (controller.capturedFile.value == null) return const SizedBox.shrink();

    return Center(
      child: Image.file(controller.capturedFile.value!, fit: BoxFit.contain),
    );
  }

  // ✅ NUEVO: Diálogo para confirmar eliminación
  void _showDeleteTextDialog(String textId) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          '¿Eliminar texto?',
          style: GoogleFonts.rubik(color: Colors.white),
        ),
        content: Text(
          'Este texto será eliminado de la historia',
          style: GoogleFonts.rubik(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.rubik(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.removeText(textId);
              controller.selectText(null);
              Get.back();
            },
            child: Text(
              'Eliminar',
              style: GoogleFonts.rubik(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
