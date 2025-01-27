import 'package:flutter/material.dart';

class SnackbarService {
  // Singleton pattern to ensure a single instance of SnackbarService
  static final SnackbarService _instance = SnackbarService._internal();

  factory SnackbarService() {
    return _instance;
  }

  SnackbarService._internal();

  // Variable to hold the overlay entry
  OverlayEntry? _overlayEntry;

  // Method to show connectivity snack bar
  void showConnectivitySnackBar(BuildContext context, bool isConnected) {
    final IconData iconData = isConnected ? Icons.wifi : Icons.wifi_off;
    final color = isConnected ? Colors.green : const Color(0xFFC6293C);
    final text = isConnected ? 'Connected to internet!' : 'No internet connection.';

    removeCustomSnackBar(); // Remove existing snack bar if any
    _overlayEntry = _createOverlayEntry(iconData, text, color);
    Overlay.of(context)?.insert(_overlayEntry!); // Insert overlay entry to show snack bar

    if (isConnected) {
      Future.delayed(const Duration(seconds: 3), () {
        removeCustomSnackBar(); // Remove the snack bar after 3 seconds
      });
    }
  }

  // Method to remove the custom snack bar
  void removeCustomSnackBar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Method to create the overlay entry widget for the snack bar
  OverlayEntry _createOverlayEntry(IconData icon, String text, Color color) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(text, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
