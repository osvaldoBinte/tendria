import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PanicButton extends StatefulWidget {
  final String phoneNumber;
  final int holdDurationSeconds;

  const PanicButton({
    super.key,
    this.phoneNumber = '911',
    this.holdDurationSeconds = 3,
  });

  @override
  State<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends State<PanicButton>
    with SingleTickerProviderStateMixin {
  bool _holding = false;
  double _progress = 0.0;
  int _secondsLeft = 0;
  Timer? _progressTimer;
  OverlayEntry? _overlayEntry;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pulseController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (_) => _CountdownOverlay(
        holdDurationSeconds: widget.holdDurationSeconds,
        progressGetter: () => _progress,
        secondsLeftGetter: () => _secondsLeft,
        onCancel: _cancelHold,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _startHold() {
    HapticFeedback.mediumImpact();
    setState(() {
      _holding = true;
      _progress = 0.0;
      _secondsLeft = widget.holdDurationSeconds;
    });
    _showOverlay();

    const step = 50;
    final total = widget.holdDurationSeconds * 1000;
    int elapsed = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: step), (timer) {
      elapsed += step;
      setState(() {
        _progress = elapsed / total;
        _secondsLeft = ((total - elapsed) / 1000).ceil();
      });
      _overlayEntry?.markNeedsBuild();

      if (elapsed >= total) {
        timer.cancel();
        _triggerCall();
      }
    });
  }

  void _cancelHold() {
    if (!_holding) return;
    _progressTimer?.cancel();
    _removeOverlay();
    HapticFeedback.lightImpact();
    setState(() {
      _holding = false;
      _progress = 0.0;
      _secondsLeft = 0;
    });
  }

  Future<void> _triggerCall() async {
    HapticFeedback.heavyImpact();
    _removeOverlay();
    setState(() {
      _holding = false;
      _progress = 0.0;
      _secondsLeft = 0;
    });

    final uri = Uri.parse('tel:${widget.phoneNumber}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: _holding ? 1.0 : _pulseAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_holding)
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B2C4B), Color(0xFF4A141E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 

class _CountdownOverlay extends StatelessWidget {
  final int holdDurationSeconds;
  final double Function() progressGetter;
  final int Function() secondsLeftGetter;
  final VoidCallback onCancel;

  const _CountdownOverlay({
    required this.holdDurationSeconds,
    required this.progressGetter,
    required this.secondsLeftGetter,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = progressGetter();
    final secondsLeft = secondsLeftGetter();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [ 
          GestureDetector(
            onTap: onCancel,
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
 
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [ 
                const Text(
                  '¡LLAMADA DE EMERGENCIA!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
 
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [ 
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: 1.0 - progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            secondsLeft <= 1
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                        ),
                      ),
 
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$secondsLeft',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          const Text(
                            'seg',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
 
                const Text(
                  'Suelta para cancelar',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),

                const SizedBox(height: 24),
 
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, color: Colors.white70),
                  label: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}