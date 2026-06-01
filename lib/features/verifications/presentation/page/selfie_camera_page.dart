import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tendria/common/theme/App_Theme.dart';
 
class SelfieCameraResult {
  final File photo;
  SelfieCameraResult(this.photo);
}

class SelfieCameraPage extends StatefulWidget {
  const SelfieCameraPage({super.key});

  @override
  State<SelfieCameraPage> createState() => _SelfieCameraPageState();
}

class _SelfieCameraPageState extends State<SelfieCameraPage>
    with WidgetsBindingObserver { 
  CameraController? _cameraController;
  bool _isCameraReady = false;
 
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableClassification: true,  
    ),
  );
  bool _isProcessingFrame = false;
 
  final RxBool _faceDetected = false.obs;
  final RxBool _isCapturing = false.obs;
  final RxBool _photoTaken = false.obs;
  final RxString _statusMessage = 'Coloca tu rostro en el círculo'.obs;
 
  Timer? _captureTimer;
  final RxInt _countdown = 0.obs; 

  File? _capturedPhoto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureTimer?.cancel();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }
 
  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhereOrNull(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    if (front == null) {
      _statusMessage.value = 'No se encontró cámara frontal';
      return;
    }

    _cameraController = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, 
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraReady = true);
      _startImageStream();
    } catch (e) {
      _statusMessage.value = 'Error al iniciar la cámara';
    }
  }
 
  void _startImageStream() {
    _cameraController?.startImageStream((CameraImage image) async {
      if (_isProcessingFrame || _photoTaken.value) return;
      _isProcessingFrame = true;

      try {
        final inputImage = _buildInputImage(image);
        if (inputImage == null) return;

        final faces = await _faceDetector.processImage(inputImage);
        _onFacesDetected(faces);
      } catch (_) { 
      } finally {
        _isProcessingFrame = false;
      }
    });
  }
 
  InputImage? _buildInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ??
          InputImageRotation.rotation0deg;
    } else { 
      var rotationCompensation = sensorOrientation;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (360 - rotationCompensation) % 360;
      }
      rotation =
          InputImageRotationValue.fromRawValue(rotationCompensation) ??
              InputImageRotation.rotation0deg;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
 
  void _onFacesDetected(List<Face> faces) {
    if (_photoTaken.value || _isCapturing.value) return;

    if (faces.isNotEmpty) { 
      if (!_faceDetected.value) {
        _faceDetected.value = true;
        _startCaptureCountdown();
      }
    } else { 
      _faceDetected.value = false;
      _cancelCountdown();
      _statusMessage.value = 'Coloca tu rostro en el círculo';
    }
  }

  void _startCaptureCountdown() {
    _statusMessage.value = 'Rostro detectado, mantente quieto...';
    _countdown.value = 3;

    _captureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_faceDetected.value) {
        timer.cancel();
        _countdown.value = 0;
        return;
      }
      _countdown.value--;
      if (_countdown.value <= 0) {
        timer.cancel();
        _countdown.value = 0;
        _capturePhoto();
      }
    });
  }

  void _cancelCountdown() {
    _captureTimer?.cancel();
    _countdown.value = 0;
  }
 
  Future<void> _capturePhoto() async {
    if (_isCapturing.value || _photoTaken.value) return;

    try {
      _isCapturing.value = true;
      _statusMessage.value = '📸 Tomando foto...';

      await _cameraController?.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));

      final xFile = await _cameraController?.takePicture();
      if (xFile == null) return;

      _capturedPhoto = File(xFile.path);
      _photoTaken.value = true;
      _statusMessage.value = '¡Selfie tomada!';
    } catch (e) {
      _statusMessage.value = 'Error al tomar la foto, intenta de nuevo';
      _isCapturing.value = false;
      _photoTaken.value = false;
      _startImageStream(); 
    } finally {
      _isCapturing.value = false;
    }
  }
 
  void _retake() {
    _capturedPhoto = null;
    _photoTaken.value = false;
    _faceDetected.value = false;
    _countdown.value = 0;
    _statusMessage.value = 'Coloca tu rostro en el círculo';
    _startImageStream();
  }
 
  void _confirm() {
    if (_capturedPhoto != null) {
      Get.back(result: SelfieCameraResult(_capturedPhoto!));
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [ 
            Obx(() {
              if (_photoTaken.value && _capturedPhoto != null) {
                return Image.file(
                  _capturedPhoto!,
                  fit: BoxFit.cover,
                );
              }
              if (!_isCameraReady || _cameraController == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              return CameraPreview(_cameraController!);
            }),
 
            Obx(() {
              if (_photoTaken.value) return const SizedBox.shrink();
              return CustomPaint(
                painter: _FaceOvalOverlayPainter(
                  faceDetected: _faceDetected.value,
                ),
                child: const SizedBox.expand(),
              );
            }),
 
            Obx(() {
              if (_countdown.value <= 0) return const SizedBox.shrink();
              return Center(
                child: Text(
                  '${_countdown.value}',
                  style: const TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: 20, color: Colors.black54),
                    ],
                  ),
                ),
              );
            }),
 
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.face_retouching_natural,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Detección automática',
                            style: ThemeColor.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
 
            Positioned(
              bottom: 180,
              left: 24,
              right: 24,
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_statusMessage.value),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _faceDetected.value && !_photoTaken.value
                          ? ThemeColor.primaryColor.withOpacity(0.85)
                          : Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _photoTaken.value
                              ? Icons.check_circle
                              : _faceDetected.value
                              ? Icons.face
                              : Icons.face_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _statusMessage.value,
                            style: ThemeColor.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
 
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: Obx(() {
                if (_photoTaken.value) { 
                  return Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _retake,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white38,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Repetir',
                                  style: ThemeColor.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _confirm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: ThemeColor.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [ThemeColor.darkShadow],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Usar esta foto',
                                  style: ThemeColor.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
 
                return Column(
                  children: [
                    GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: Colors.white24,
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'O toca para fotografiar',
                      style: ThemeColor.caption.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _FaceOvalOverlayPainter extends CustomPainter {
  final bool faceDetected;

  _FaceOvalOverlayPainter({required this.faceDetected});

  @override
  void paint(Canvas canvas, Size size) {
    final ovalWidth = size.width * 0.72;
    final ovalHeight = ovalWidth * 1.28;
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: ovalWidth,
      height: ovalHeight,
    );
 
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      bgPath,
      Paint()..color = Colors.black.withOpacity(0.55),
    );
 
    final borderColor = faceDetected
        ? const Color(0xFF4CAF50)
        : Colors.white.withOpacity(0.6);
    final borderWidth = faceDetected ? 3.0 : 2.0;

    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
 
    if (faceDetected) {
      final cornerPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      const arcLen = 0.35;  

       
      canvas.drawArc(
        ovalRect,
        -1.5707 - arcLen / 2,
        arcLen,
        false,
        cornerPaint,
      );
     
      canvas.drawArc(
        ovalRect,
        1.5707 - arcLen / 2,
        arcLen,
        false,
        cornerPaint,
      );
    
      canvas.drawArc(
        ovalRect,
        3.1415 - arcLen / 2,
        arcLen,
        false,
        cornerPaint,
      );
      
      canvas.drawArc(ovalRect, -arcLen / 2, arcLen, false, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(_FaceOvalOverlayPainter old) =>
      old.faceDetected != faceDetected;
}