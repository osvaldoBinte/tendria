import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
 class PanicButton extends StatefulWidget {
  final String phoneNumber;
  final int holdDurationSeconds;

  const PanicButton({
    super.key,
    this.phoneNumber = '961',
    this.holdDurationSeconds = 3,
  });

  @override
  State<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends State<PanicButton>
    with SingleTickerProviderStateMixin {
  bool _holding = false;
  double _progress = 0.0;
  Timer? _progressTimer;

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
    super.dispose();
  }

  void _startHold() {
    HapticFeedback.mediumImpact();
    setState(() {
      _holding = true;
      _progress = 0.0;
    });

    const step = 50;
    final total = widget.holdDurationSeconds * 1000;
    int elapsed = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: step), (timer) {
      elapsed += step;
      setState(() => _progress = elapsed / total);

      if (elapsed >= total) {
        timer.cancel();
        _triggerCall();
      }
    });
  }

  void _cancelHold() {
    if (!_holding) return;
    _progressTimer?.cancel();
    setState(() {
      _holding = false;
      _progress = 0.0;
    });
  }

void _triggerCall() async {
  HapticFeedback.heavyImpact();
  setState(() {
    _holding = false;
    _progress = 0.0;
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
              // Progress ring
              if (_holding)
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
              // FAB
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
                child: const Icon(Icons.phone, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}