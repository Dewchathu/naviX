import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/home.dart';
import 'package:navix/screens/login_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../services/firestore_service.dart';
import '../services/firestore_updater.dart';
import '../services/shared_preference_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0;
  bool _isConnected = false;
  late StreamSubscription<InternetStatus> _internetStatusSubscription;
  String message = '';
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _listenToInternetStatus();
  }

  @override
  void dispose() {
    _internetStatusSubscription.cancel();
    removeCustomSnackBar();
    super.dispose();
  }

  void updateProgressAndMessage(double progressValue, String newMessage) {
    setState(() {
      progress = progressValue;
      message = newMessage;
    });
  }

  Future<void> _initializeApp() async {
    // Prevent re-initialization if already running
    if (!_isConnected) {
      updateProgressAndMessage(0.0, 'Waiting for internet connection...');
      return;
    }

    updateProgressAndMessage(0.4, 'Internet connected! Preparing app...');

    FirestoreUpdater updater = FirestoreUpdater();
    bool isLogged = await SharedPreferenceService.getBool("isLogged") ?? false;

    if (isLogged) {
      updateProgressAndMessage(0.6, 'Updating data from server...');
      await updater.updateFirestoreDocument();
    } else {
      updateProgressAndMessage(0.5, 'Loading default data...');
    }

    await Future.delayed(const Duration(seconds: 1));

    if (isLogged) {
      updateProgressAndMessage(1.0, 'Welcome back!');
      await FirestoreService().getCurrentUserInfo();
      moveToNextScreen(context, const HomeScreen());
    } else {
      updateProgressAndMessage(1.0, 'Welcome to NaviX!');
      moveToNextScreen(context, const LoginScreen());
    }
  }

  void _listenToInternetStatus() {
    _internetStatusSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          if (!_isConnected) {
            showConnectivitySnackBar(context, true);
            setState(() => _isConnected = true);
            _initializeApp();
          }
          break;
        case InternetStatus.disconnected:
          if (_isConnected) {
            showConnectivitySnackBar(context, false);
            setState(() {
              _isConnected = false;
              message = 'No internet connection. Please reconnect.';
            });
          }
          break;
      }
    });
  }

  void showConnectivitySnackBar(BuildContext context, bool isConnected) {
    final IconData iconData = isConnected ? Icons.wifi : Icons.wifi_off;
    final color = isConnected ? Colors.green : const Color(0xFFC6293C);
    final text =
        isConnected ? 'Connected to internet!' : 'No internet connection.';

    removeCustomSnackBar();
    _overlayEntry = _createOverlayEntry(iconData, text, color);
    Overlay.of(context).insert(_overlayEntry!);

    if (isConnected) {
      Future.delayed(const Duration(seconds: 3), () {
        removeCustomSnackBar();
      });
    }
  }

  void removeCustomSnackBar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(IconData icon, String text, Color color) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top +
            kToolbarHeight +
            8, // Adjust as needed
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0F75BC),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              width: 200,
              child: Image.asset('assets/images/logo_white.png'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: LinearPercentIndicator(
                lineHeight: 5.0,
                percent: progress,
                barRadius: const Radius.circular(20),
                backgroundColor: Colors.grey.withOpacity(0.4),
                progressColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            const Text('For Computer Science Undergraduates in PST',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
