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
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
            ),
            child: const LoadingIndicator(
              indicatorType: Indicator.lineSpinFadeLoader,
              colors: [Colors.blue],
              strokeWidth: 1,
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
