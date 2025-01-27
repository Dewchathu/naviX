import 'dart:async';
import 'package:flutter/material.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/home.dart';
import 'package:navix/screens/login_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../services/firestore_service.dart';
import '../services/firestore_updater.dart';
import '../services/shared_preference_service.dart';
import '../services/internet_service.dart';
import '../services/snackbar_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0;
  bool _isConnected = false;
  late StreamSubscription<bool> _internetStatusSubscription;
  String message = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _listenToInternetStatus();
    InternetService().startListening();
  }

  @override
  void dispose() {
    _internetStatusSubscription.cancel();
    super.dispose();
  }

  void updateProgressAndMessage(double progressValue, String newMessage) {
    setState(() {
      progress = progressValue;
      message = newMessage;
    });
  }

  Future<void> _initializeApp() async {
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
        InternetService().connectionStatusStream.listen((isConnected) {
          setState(() {
            _isConnected = isConnected;
            message = isConnected ? 'Internet connected!' : 'No internet connection.';
          });
          SnackbarService().showConnectivitySnackBar(context, isConnected);

          if (isConnected && progress < 1.0) {
            _initializeApp();
          }
        });
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
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
