import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tendria/common/widgets/alert/snackbar_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';
// Modelo para textos
class StoryText {
  final String text;
  final Color color;
  Offset position;
  double scale;
  final String id;

  StoryText({
    required this.text,
    required this.color,
    required this.position,
    this.scale = 1.0,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  StoryText copyWith({
    String? text,
    Color? color,
    Offset? position,
    double? scale,
  }) {
    return StoryText(
      text: text ?? this.text,
      color: color ?? this.color,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      id: id,
    );
  }
}

class CreateStoryController extends GetxController {
  // Camera
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final RxList<CameraDescription> cameras = <CameraDescription>[].obs;
  final RxBool isCameraInitialized = false.obs;
  final RxBool isFrontCamera = false.obs;

  // Recording
  final RxBool isRecording = false.obs;
  final RxInt recordingSeconds = 0.obs;
  Timer? recordingTimer;
  static const int maxRecordingSeconds = 30;

  // Captured content
  final Rx<File?> capturedFile = Rx<File?>(null);
  final Rx<String?> contentType = Rx<String?>(null);
  VideoPlayerController? videoController;
  
  // Video ready flag
  final RxBool isVideoReady = false.obs;

  // Gallery
  final RxList<AssetEntity> galleryAssets = <AssetEntity>[].obs;
  final RxBool isLoadingGallery = false.obs;

  // Textos sobre la historia
  final RxList<StoryText> storyTexts = <StoryText>[].obs;
  final Rx<String?> selectedTextId = Rx<String?>(null);

  final GlobalKey repaintBoundaryKey = GlobalKey();

  // Flag para indicar si se está procesando el video
  final RxBool isProcessingVideo = false.obs;
// Agregar import al controller

Future<void> selectFromImagePicker() async {
  try {
    final ImagePicker picker = ImagePicker();
    
    // Mostrar opciones: foto o video
    final XFile? file = await picker.pickMedia();
    if (file == null) return;

    final path = file.path.toLowerCase();
    final isVideo = path.endsWith('.mp4') || path.endsWith('.mov') ||
        path.endsWith('.avi') || path.endsWith('.mkv');

    capturedFile.value = File(file.path);
    contentType.value = isVideo ? 'Video' : 'Foto';

    if (contentType.value == 'Video') {
      await initializeVideoController();
    }
  } catch (e) {
    debugPrint('Error seleccionando de galería: $e');
    showErrorSnackbar('No se pudo seleccionar el archivo');
  }
}
  @override
  void onInit() {
    super.onInit();
    initializeCamera();
    loadGalleryAssets();
  }

  @override
  void onClose() {
    cameraController.value?.dispose();
    videoController?.dispose();
    recordingTimer?.cancel();
    super.onClose();
  }

  // Agregar texto
  void addText(String text, Color color, Offset position, double scale) {
    final newText = StoryText(
      text: text,
      color: color,
      position: position,
      scale: scale,
    );
    storyTexts.add(newText);
  }

  // Actualizar posición de texto
  void updateTextPosition(String textId, Offset newPosition) {
    final index = storyTexts.indexWhere((t) => t.id == textId);
    if (index != -1) {
      storyTexts[index].position = newPosition;
      storyTexts.refresh();
    }
  }
Future<File?> convertToPng(File inputFile) async {
  try {
    // Si ya es PNG, no convertir
    final ext = inputFile.path.toLowerCase().split('.').last;
    if (ext == 'png') {
      debugPrint('✅ Ya es PNG, no se convierte');
      return inputFile;
    }

    debugPrint('🔄 Convirtiendo a PNG: ${inputFile.path}');

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/story_$timestamp.png';

    final command = '-i "${inputFile.path}" -y "$outputPath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        debugPrint('✅ Convertido a PNG: $outputPath');
        return outputFile;
      }
    }

    debugPrint('⚠️ No se pudo convertir, usando original');
    return inputFile;
  } catch (e) {
    debugPrint('💥 Error convirtiendo a PNG: $e');
    return inputFile;
  }
}
  // Actualizar escala de texto
  void updateTextScale(String textId, double newScale) {
    final index = storyTexts.indexWhere((t) => t.id == textId);
    if (index != -1) {
      storyTexts[index].scale = newScale;
      storyTexts.refresh();
    }
  }

  // Eliminar texto
  void removeText(String textId) {
    storyTexts.removeWhere((t) => t.id == textId);
  }

  // Seleccionar texto
  void selectText(String? textId) {
    selectedTextId.value = textId;
  }

  Future<File?> captureStoryWithTexts() async {
    try {
      // Si no hay textos, devolver el archivo original
      if (storyTexts.isEmpty) {
        return capturedFile.value;
      }

      // Para videos, usar FFmpeg
if (contentType.value == 'Video') {
        return await processVideoWithTexts();
      }

      // Para imágenes, capturar el RepaintBoundary
      await Future.delayed(const Duration(milliseconds: 100));

      RenderRepaintBoundary? boundary = repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('RepaintBoundary not found');
        return capturedFile.value;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        debugPrint('Failed to convert image to bytes');
        return capturedFile.value;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/story_with_text_$timestamp.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      debugPrint('Story with texts saved: $imagePath');
      return imageFile;
    } catch (e) {
      debugPrint('Error capturing story with texts: $e');
      return capturedFile.value;
    }
  }

  // ✅ SOLUCIÓN FINAL: Procesar video con FUENTE especificada
  Future<File?> processVideoWithTexts() async {
    if (capturedFile.value == null || storyTexts.isEmpty) {
      debugPrint('❌ No file or no texts to process');
      return capturedFile.value;
    }

    try {
      isProcessingVideo.value = true;
      debugPrint('🎬 Starting video processing with ${storyTexts.length} texts');

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/story_video_$timestamp.mp4';

      // Obtener resolución real del video
      double videoWidth = 1080;
      double videoHeight = 1920;
      
      if (videoController != null && videoController!.value.isInitialized) {
        videoWidth = videoController!.value.size.width;
        videoHeight = videoController!.value.size.height;
        debugPrint('📐 Video resolution: ${videoWidth}x$videoHeight');
      }

      // ✅ CLAVE: Especificar fuente de Android
      const fontPath = '/system/fonts/Roboto-Regular.ttf';
      
      // Construir filtros de texto
      List<String> textFilters = [];
      
      for (int i = 0; i < storyTexts.length; i++) {
        final storyText = storyTexts[i];
        
        // Calcular posición en píxeles
        final xPos = (storyText.position.dx * videoWidth).toInt();
        final yPos = (storyText.position.dy * videoHeight).toInt();
        
        // Convertir color a formato FFmpeg (RRGGBB sin alpha)
        final colorHex = storyText.color.value.toRadixString(16).padLeft(8, '0').substring(2);
        
        // Calcular tamaño de fuente
        final baseFontSize = (videoHeight / 1920) * 28;
        final fontSize = (baseFontSize * storyText.scale).toInt();
        
        // Limpiar el texto
        String cleanText = storyText.text
            .replaceAll('\\', '')
            .replaceAll("'", '')
            .replaceAll('"', '')
            .replaceAll(':', ' ')
            .replaceAll('%', ' ')
            .trim();
        
        debugPrint('📝 Text $i: "$cleanText" at ($xPos, $yPos) size:$fontSize color:$colorHex');
        
        // ✅ Filtro CON fuente especificada
        final filter = "drawtext="
    "fontfile=$fontPath:"
    "text='$cleanText':"
    "fontsize=$fontSize:"
    "fontcolor=$colorHex:"
    "x=$xPos:"
    "y=$yPos:"
    "shadowcolor=black@0.8:"      // Sombra más fuerte
    "shadowx=2:"                   // Desplazamiento sombra X
    "shadowy=2:"                   // Desplazamiento sombra Y
    "borderw=3:"                   // Borde grueso
    "bordercolor=black@0.9";
        
        textFilters.add(filter);
      }

      // Unir todos los filtros
      final allFilters = textFilters.join(',');
      
      debugPrint('🔧 Filter chain: $allFilters');

      // Comando FFmpeg
      final inputPath = capturedFile.value!.path;
      
      final command = '-i "$inputPath" '
          '-vf "$allFilters" '
          '-c:v libx264 '
          '-preset ultrafast '
          '-c:a copy '
          '-y "$outputPath"';
      
      debugPrint('🚀 Executing FFmpeg');
      debugPrint('   Input: $inputPath');
      debugPrint('   Output: $outputPath');

      // Ejecutar FFmpeg
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final output = await session.getOutput();

      debugPrint('📊 FFmpeg Return Code: ${returnCode?.getValue()}');
      
      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('✅ Video processing completed');
        
        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          final fileSize = await outputFile.length();
          debugPrint('📦 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
          
          isProcessingVideo.value = false;
          return outputFile;
        } else {
          debugPrint('❌ Output file not found');
          debugPrint('📋 Output: $output');
          isProcessingVideo.value = false;
          return capturedFile.value;
        }
      } else {
        debugPrint('❌ FFmpeg failed: ${returnCode?.getValue()}');
        debugPrint('📋 Output: $output');
        
        isProcessingVideo.value = false;
        return capturedFile.value;
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error: $e');
      debugPrint('📚 Stack: $stackTrace');
      isProcessingVideo.value = false;
      return capturedFile.value;
    }
  }

  // Inicializar cámara
  Future<void> initializeCamera() async {
  try {
    isCameraInitialized.value = false;
    
    final availableCamerasList = await availableCameras();
    if (availableCamerasList.isEmpty) return;

    cameras.value = availableCamerasList;
    
    // ✅ Buscar por lensDirection en vez de asumir índice
    final camera = _getCamera();

    final newController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await newController.initialize();
    await newController.lockCaptureOrientation(DeviceOrientation.portraitUp);
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (newController.value.isInitialized) {
      cameraController.value = newController;
      await Future.delayed(const Duration(milliseconds: 50));
      isCameraInitialized.value = true;
    }
  } catch (e) {
    debugPrint('Error initializing camera: $e');
    isCameraInitialized.value = false;
  }
}

// ✅ Busca la cámara correcta por dirección, no por índice
CameraDescription _getCamera() {
  final direction = isFrontCamera.value 
      ? CameraLensDirection.front 
      : CameraLensDirection.back;
  
  // Buscar por lensDirection
  final match = cameras.firstWhereOrNull((c) => c.lensDirection == direction);
  
  // Si no encontró la dirección deseada, usar la primera disponible
  if (match == null) {
    debugPrint('⚠️ No se encontró cámara $direction, usando primera disponible');
    isFrontCamera.value = !isFrontCamera.value; // revertir el toggle
    return cameras.first;
  }
  
  debugPrint('📷 Usando cámara: ${match.name} - ${match.lensDirection}');
  return match;
}

Future<void> switchCamera() async {
  if (cameras.length < 2) {
    debugPrint('⚠️ Solo hay ${cameras.length} cámara(s)');
    return;
  }

  isFrontCamera.value = !isFrontCamera.value;
  
  final controller = cameraController.value;
  cameraController.value = null;
  await controller?.dispose();
  
  await initializeCamera();
}
  // Cargar assets de galería
  Future<void> loadGalleryAssets() async {
    isLoadingGallery.value = true;

    final PermissionState permission = await PhotoManager.requestPermissionExtend();

    if (permission.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
      );

      if (albums.isNotEmpty) {
        final List<AssetEntity> media = await albums[0].getAssetListRange(
          start: 0,
          end: 20,
        );
        galleryAssets.value = media;
      }
    }

    isLoadingGallery.value = false;
  }

  // Iniciar grabación
  Future<void> startRecording() async {
    if (cameraController.value == null || !cameraController.value!.value.isInitialized) return;
    if (isRecording.value) return;

    try {
      await cameraController.value!.startVideoRecording();

      isRecording.value = true;
      recordingSeconds.value = 0;

      recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (recordingSeconds.value >= maxRecordingSeconds) {
          stopRecording();
        } else {
          recordingSeconds.value++;
        }
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }
// Convertir video temporal a MP4
Future<File?> convertToMp4(File inputFile) async {
  try {
    debugPrint('🔄 Convirtiendo video a MP4...');
    debugPrint('📥 Input: ${inputFile.path}');

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/video_$timestamp.mp4';

    debugPrint('📤 Output: $outputPath');

    // Comando FFmpeg para convertir a MP4
    final command = '-i "${inputFile.path}" '
        '-c:v libx264 '          // Codec de video H.264
        '-preset ultrafast '      // Velocidad de conversión
        '-c:a aac '              // Codec de audio AAC
        '-strict experimental '   // Permitir codecs experimentales
        '-y "$outputPath"';      // Sobrescribir si existe

    debugPrint('🚀 Ejecutando conversión FFmpeg');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final output = await session.getOutput();

    debugPrint('📊 FFmpeg Return Code: ${returnCode?.getValue()}');

    if (ReturnCode.isSuccess(returnCode)) {
      final outputFile = File(outputPath);
      
      if (await outputFile.exists()) {
        final fileSize = await outputFile.length();
        debugPrint('✅ Conversión exitosa');
        debugPrint('📦 Tamaño: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
        
        return outputFile;
      } else {
        debugPrint('❌ Archivo de salida no encontrado');
        debugPrint('📋 Output: $output');
        return null;
      }
    } else {
      debugPrint('❌ FFmpeg falló: ${returnCode?.getValue()}');
      debugPrint('📋 Output: $output');
      return null;
    }
  } catch (e, stackTrace) {
    debugPrint('💥 Error convirtiendo a MP4: $e');
    debugPrint('📚 Stack: $stackTrace');
    return null;
  }
}

// Detener grabación - ACTUALIZADO para convertir a MP4
Future<void> stopRecording() async {
  if (!isRecording.value) return;

  try {
    recordingTimer?.cancel();
    final XFile video = await cameraController.value!.stopVideoRecording();

    debugPrint('📹 Video grabado: ${video.path}');
    
    // ✅ Convertir a MP4
    final File tempFile = File(video.path);
    final fileSize = await tempFile.length();
    debugPrint('📦 Tamaño original: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

    // Mostrar indicador de conversión
    showInfoSnackbar('Procesando video...');

    final File? mp4File = await convertToMp4(tempFile);

    if (mp4File != null) {
      debugPrint('✅ Video convertido a MP4: ${mp4File.path}');
      
      isRecording.value = false;
      recordingSeconds.value = 0;
      capturedFile.value = mp4File;
      contentType.value = 'Video';

      await initializeVideoController();
    } else {
      debugPrint('⚠️ No se pudo convertir, usando archivo original');
      
      isRecording.value = false;
      recordingSeconds.value = 0;
      capturedFile.value = tempFile;
      contentType.value = 'Video';

      await initializeVideoController();
    }
  } catch (e) {
    debugPrint('❌ Error deteniendo grabación: $e');
    isRecording.value = false;
    showErrorSnackbar('Error al procesar el video');
  }
}
// Inicializar video controller - MEJORADO
Future<void> initializeVideoController() async {
if (capturedFile.value == null || contentType.value != 'Video') return; // antes: 'video'

  try {
    isVideoReady.value = false;
    
    videoController?.dispose();
    videoController = null;

    debugPrint('🎬 Inicializando video: ${capturedFile.value!.path}');
    
    // Verificar que el archivo existe
    if (!await capturedFile.value!.exists()) {
      debugPrint('❌ El archivo de video no existe');
      return;
    }

    final fileSize = await capturedFile.value!.length();
    debugPrint('📦 Tamaño del archivo: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

    // Crear controller
    videoController = VideoPlayerController.file(capturedFile.value!);

    // Inicializar con timeout
    await videoController!.initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⏱️ Timeout inicializando video');
        throw TimeoutException('Video initialization timeout');
      },
    );
    
    if (videoController!.value.isInitialized) {
      videoController!.setLooping(true);
      await videoController!.play();
      
      isVideoReady.value = true;
      
      debugPrint('✅ Video inicializado correctamente');
      debugPrint('   Duración: ${videoController!.value.duration}');
      debugPrint('   Tamaño: ${videoController!.value.size}');
      debugPrint('   Aspect Ratio: ${videoController!.value.aspectRatio}');
    } else {
      debugPrint('❌ Video no se pudo inicializar');
    }
  } catch (e, stackTrace) {
    debugPrint('💥 Error inicializando video: $e');
    debugPrint('📚 Stack trace: $stackTrace');
    
    videoController?.dispose();
    videoController = null;
    isVideoReady.value = false;
    showErrorSnackbar('No se pudo cargar el video. Intenta de nuevo.');
  }
}

Future<void> selectFromGallery(AssetEntity asset) async {
  try {
    final File? file = await asset.file;
    if (file == null) return;

    capturedFile.value = file;
contentType.value = asset.type == AssetType.image ? 'Foto' : 'Video'; // antes: 'image'/'video'

if (contentType.value == 'Video') {
      await initializeVideoController();
    }
  } catch (e) {
    debugPrint('Error selecting from gallery: $e');
  }
}

// Tomar foto
Future<void> takePicture() async {
  if (cameraController.value == null || !cameraController.value!.value.isInitialized) return;

  try {
    final XFile photo = await cameraController.value!.takePicture();

    capturedFile.value = File(photo.path);
    contentType.value = 'Foto'; 
  } catch (e) {
    debugPrint('Error taking picture: $e');
  }
}

  // Limpiar captura
  void clearCapture() {
    capturedFile.value = null;
    contentType.value = null;
    videoController?.dispose();
    videoController = null;
    isVideoReady.value = false;
    storyTexts.clear();
    selectedTextId.value = null;
  }

  // Manejar ciclo de vida
  void handleAppLifecycleState(AppLifecycleState state) {
    if (cameraController.value == null || !cameraController.value!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.value?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCamera();
    }
  }
}