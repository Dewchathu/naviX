import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:navix/providers/profile_provider.dart';
import 'package:navix/providers/streak_provider.dart';
import 'package:navix/screens/splash_screen.dart';
import 'package:navix/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    String apiKey = dotenv.env['API_KEY'] ?? '';
    Gemini.init(apiKey: apiKey, enableDebugging: true);

    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize Notification Service
    final NotificationService notificationService = NotificationService();
    await notificationService.init();

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
      ],
      child: const MyApp(),
    ));
  } catch (e) {
    print('Error during app initialization: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaviX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F75BC)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
