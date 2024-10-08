import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class loadingIndicator {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.3),
        width: double.infinity,
        height: double.infinity,
        child: const Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: LoadingIndicator(
              indicatorType: Indicator.orbit,
              colors: [Colors.blue],
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
