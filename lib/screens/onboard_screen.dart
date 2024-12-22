import 'package:flutter/material.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/setup_screen.dart';
import 'package:navix/widgets/custom_button.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to NaviX',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F75BC),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(
                  width: 300,
                  child: Text(
                    """Hi, Dew. As a student of the Department of Physical Science and Technology at Sabaragamuwa University of Sri Lanka, I am here to support you in your academic journey and help shape your future career. 
                    
      Let's begin by getting to know more about your interests, academic goals, and aspirations. Together, we can chart a personalized path to success. I'm excited to be a part of your journey!""",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Get Started',
                  onPressed: () {
                    moveToNextScreen(context, const SetupScreen());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
