import 'package:flutter/widgets.dart';

class KeyboardObserver extends WidgetsBindingObserver {
  final void Function(double bottomInset) onKeyboardChanged;

  KeyboardObserver({required this.onKeyboardChanged});

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding
            .instance.platformDispatcher.views.first.viewInsets.bottom;
    onKeyboardChanged(bottomInset);
  }
}