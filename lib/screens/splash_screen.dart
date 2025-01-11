import 'package:flutter/material.dart';
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
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Update progress
    setState(() {
      _progress = 0.2; // Start progress
    });

    // Perform Firestore updates (only if user is logged in)
    FirestoreUpdater updater = FirestoreUpdater();

    bool isLogged = await SharedPreferenceService.getBool("isLogged") ?? false;

    if (isLogged) {
      await updater.updateFirestoreDocument();
      setState(() {
        _progress = 0.8; // Firestore updates complete
      });
    } else {
      setState(() {
        _progress = 0.5; // Indicate that the user is not logged in
      });
    }

    // Simulate a delay to handle UI smoothness
    await Future.delayed(const Duration(seconds: 1));

    // Navigate to the appropriate screen
    if (isLogged) {
      await FirestoreService().getCurrentUserInfo(); // Fetch user info if logged in
      moveToNextScreen(context, const HomeScreen());
    } else {
      moveToNextScreen(context, const LoginScreen()); // Redirect to Login screen
    }
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
            SizedBox(
              width: 200,
              child: Image.asset('assets/images/logo_white.png'),
            ),
            const SizedBox(height: 20), // Add some spacing
            SizedBox(
              width: 200, // Match the width of the logo container
              child: LinearPercentIndicator(
                lineHeight: 5.0,
                percent: _progress,
                center: Text(
                  "${(_progress * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 12.0, color: Colors.white),
                ),
                barRadius: const Radius.circular(20),
                backgroundColor: Colors.grey.withOpacity(0.4),
                progressColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
