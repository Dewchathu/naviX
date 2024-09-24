import 'package:flutter/material.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/home.dart';
import 'package:navix/screens/login_screen.dart';

import '../services/firestore_service.dart';
import '../services/shared_preference_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      SharedPreferenceService.getBool("isLogged").then((isLogged) {
        if(isLogged == true){
          FirestoreService().getCurrentUserInfo().then((snapshot){
            moveToNextScreen(context, const HomeScreen());
          });
        }
        else{
          moveToNextScreen(context, const LoginScreen());
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0F75BC),
        child: Center(
          child:SizedBox(
            width: 200,
              child: Image.asset('assets/images/logo_white.png'
              ),
          ),
        ),
      ),
    );
  }
}
