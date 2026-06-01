import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
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
    ),
  );
 
  Timer? _detectionTimer;
  bool _isAnalyzing = false;
 
  final RxString _detectionState = 'idle'.obs;
  final RxBool _faceDetected = false.obs;
  final RxBool _photoTaken = false.obs;
  final RxString _statusMessage = 'Coloca tu rostro en el círculo'.obs;

  int _stableFrames = 0; 
  static const int _requiredStableFrames = 4;
 
  int _failedAttempts = 0;
  static const int _attemptsBeforeManual = 6;
  final RxBool _showManualButton = false.obs;

  Timer? _captureTimer;
  final RxInt _countdown = 0.obs;

  File? _capturedPhoto;
  String? _tempPath;

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
    _detectionTimer?.cancel();
    _captureTimer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close(); 
    if (_tempPath != null) {
      try { File(_tempPath!).deleteSync(); } catch (_) {}
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _stopDetection();
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }
 
  Future<void> _initCamera() async {
    try {
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
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraReady = true);
 
      final dir = await getTemporaryDirectory();
      _tempPath = '${dir.path}/selfie_detect.jpg';

      _startDetectionTimer();
    } catch (e) {
      debugPrint('Error init camera: $e');
      _statusMessage.value = 'Error al iniciar la cámara';
    }
  }
 
  void _startDetectionTimer() {
    _detectionTimer?.cancel();
    _detectionTimer = Timer.periodic(
      const Duration(milliseconds: 600),
      (_) => _analyzeFrame(),
    );
  }

  void _stopDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
  }

  Future<void> _analyzeFrame() async {
    if (_isAnalyzing) return;
    if (_photoTaken.value) return;
    if (_detectionState.value == 'capturing') return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _isAnalyzing = true;
    try { 
      final xFile = await _cameraController!.takePicture();
      final file = File(xFile.path);
 
      await file.copy(_tempPath!);
      await file.delete();
 
      final inputImage = InputImage.fromFilePath(_tempPath!);
      final faces = await _faceDetector.processImage(inputImage);

      if (mounted) _onFacesDetected(faces);
    } catch (e) {
      debugPrint('Analyze error: $e');
    } finally {
      _isAnalyzing = false;
    }
  }
 
  void _onFacesDetected(List<Face> faces) {
    if (_photoTaken.value || _detectionState.value == 'capturing') return;

    final state = _detectionState.value;

    if (faces.isNotEmpty) {
      _faceDetected.value = true;

      if (state == 'idle' || state == 'lost') {
        _stableFrames = 1;
        _detectionState.value = 'stabilizing';
        _statusMessage.value = 'Rostro detectado, mantente quieto...';
      } else if (state == 'stabilizing') {
        _stableFrames++;
        if (_stableFrames >= _requiredStableFrames) {
          _startCaptureCountdown();
        }
      }
    } else {
      _faceDetected.value = false;
      _stableFrames = 0;

      if (state == 'stabilizing') {
        _detectionState.value = 'idle';
        _statusMessage.value = 'Coloca tu rostro en el círculo';
      } else if (state == 'countdown') {
        _cancelCountdown();
        _detectionState.value = 'lost';
        _statusMessage.value = '⚠️ Moviste la cara, vuelve a colocarla';
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _detectionState.value == 'lost') {
            _detectionState.value = 'idle';
            _statusMessage.value = 'Coloca tu rostro en el círculo';
          }
        });
      } else {
        _detectionState.value = 'idle'; 
        _failedAttempts++;
        if (_failedAttempts >= _attemptsBeforeManual &&
            !_showManualButton.value) {
          _showManualButton.value = true;
        }
        _statusMessage.value = 'Coloca tu rostro en el círculo';
      }
    }
  }

  void _startCaptureCountdown() {
    _detectionState.value = 'countdown';
    _countdown.value = 3;
    _statusMessage.value = '¡No te muevas! Tomando foto en 3...';

    _captureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_detectionState.value != 'countdown') {
        timer.cancel();
        _countdown.value = 0;
        return;
      }
      _countdown.value--;
      if (_countdown.value == 2) {
        _statusMessage.value = '¡No te muevas! Tomando foto en 2...';
      } else if (_countdown.value == 1) {
        _statusMessage.value = '¡No te muevas! Tomando foto en 1...';
      } else if (_countdown.value <= 0) {
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
    if (_photoTaken.value) return;
    try {
      _stopDetection();
      _detectionState.value = 'capturing';
      _statusMessage.value = '📸 Tomando foto...';

      final xFile = await _cameraController?.takePicture();
      if (xFile == null) throw Exception('No se pudo capturar');

      _capturedPhoto = File(xFile.path);
      _photoTaken.value = true;
      _detectionState.value = 'done';
      _statusMessage.value = '¡Selfie lista!';
    } catch (e) {
      debugPrint('Capture error: $e');
      _statusMessage.value = 'Error al tomar la foto, intenta de nuevo';
      _photoTaken.value = false;
      _detectionState.value = 'idle';
      _stableFrames = 0;
      _startDetectionTimer();
    }
  }

  void _retake() {
    _capturedPhoto = null;
    _photoTaken.value = false;
    _faceDetected.value = false;
    _countdown.value = 0;
    _stableFrames = 0;
    _failedAttempts = 0;
    _showManualButton.value = false;
    _detectionState.value = 'idle';
    _statusMessage.value = 'Coloca tu rostro en el círculo';
    _startDetectionTimer();
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
                return Image.file(_capturedPhoto!, fit: BoxFit.contain);
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
                  detectionState: _detectionState.value,
                ),
                child: const SizedBox.expand(),
              );
            }),
 
            Obx(() {
              if (_countdown.value <= 0) return const SizedBox.shrink();
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: _countdown.value / 3,
                        strokeWidth: 6,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    ),
                    Text(
                      '${_countdown.value}',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 20, color: Colors.black54)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
 
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.face_retouching_natural,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text('Detección automática',
                              style: ThemeColor.caption
                                  .copyWith(color: Colors.white70)),
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
              child: Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_statusMessage.value),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _detectionState.value == 'lost'
                            ? ThemeColor.errorColor.withOpacity(0.90)
                            : _detectionState.value == 'countdown'
                                ? ThemeColor.successColor.withOpacity(0.90)
                                : _faceDetected.value && !_photoTaken.value
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
                                : _detectionState.value == 'lost'
                                    ? Icons.warning_rounded
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
                  )),
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
                                  color: Colors.white38, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('Repetir',
                                    style: ThemeColor.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
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
                                const Icon(Icons.check,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('Usar esta foto',
                                    style: ThemeColor.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
 
                return Obx(() => _showManualButton.value
                    ? Column(
                        children: [
                          GestureDetector(
                            onTap: _capturePhoto,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
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
                            'No te detectamos, toca para fotografiar',
                            style: ThemeColor.caption
                                .copyWith(color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : const SizedBox.shrink());
              }),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _FaceOvalOverlayPainter extends CustomPainter {
  final String detectionState;
  _FaceOvalOverlayPainter({required this.detectionState});

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
        bgPath, Paint()..color = Colors.black.withOpacity(0.55));

    final Color borderColor;
    final double borderWidth;
    switch (detectionState) {
      case 'countdown':
        borderColor = const Color(0xFF4CAF50);
        borderWidth = 3.5;
        break;
      case 'stabilizing':
        borderColor = const Color(0xFFF7770E);
        borderWidth = 2.5;
        break;
      case 'lost':
        borderColor = const Color(0xFFFF3B3B);
        borderWidth = 3.0;
        break;
      default:
        borderColor = Colors.white.withOpacity(0.7);
        borderWidth = 2.0;
    }

    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    if (detectionState == 'stabilizing' || detectionState == 'countdown') {
      final cornerPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      const arcLen = 0.35;
      canvas.drawArc(
          ovalRect, -1.5707 - arcLen / 2, arcLen, false, cornerPaint);
      canvas.drawArc(
          ovalRect, 1.5707 - arcLen / 2, arcLen, false, cornerPaint);
      canvas.drawArc(
          ovalRect, 3.1415 - arcLen / 2, arcLen, false, cornerPaint);
      canvas.drawArc(ovalRect, -arcLen / 2, arcLen, false, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(_FaceOvalOverlayPainter old) =>
      old.detectionState != detectionState;
}