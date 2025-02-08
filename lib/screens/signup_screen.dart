import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:navix/screens/login_screen.dart';
import 'package:navix/screens/onboard_screen.dart';

import '../actions/move_to_next_sceen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/shared_preference_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/custom_password_form_field.dart';
import '../widgets/info_messages.dart';
import '../widgets/show_back_dialog.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return; // If the pop was already handled, exit early
        }
        final bool shouldPop = await showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context); // Pop the current screen if allowed
        }
      },
      child: Scaffold(
          body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 6,
                  child: const Center(
                    child: Text(
                      'NaviX',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 5 / 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                    ),
                  ),
                  child: const SignupForm(),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conPasswordController = TextEditingController();
  final String handBook =
      "https://firebasestorage.googleapis.com/v0/b/navix-dew.appspot.com/o/handBookPdf%2FPST%20Hand%20Book.pdf?alt=media&token=24a70175-d269-4307-9b48-80d595e2bf5a";

  final _formKey = GlobalKey<FormState>();
  bool isValidateMode = false;
  bool isLoading = false;
  String url = '';

  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getRandomImageUrl() {
    String baseUrl =
        "https://firebasestorage.googleapis.com/v0/b/navix-dew.appspot.com/o/Profile%20Pictures%2F";

    final Map<String, String> imgDetails = {
      '01': '781b9714-6321-45b8-98c2-36a2f421b43e',
      '02': '88368338-92a1-4092-a0da-6fdc2288b864',
      '03': '85459d45-9c8c-4297-8889-69590a580899',
      '04': '18b40a4d-c098-4868-bc5e-a1e51350993e',
      '05': 'fbd47f39-ebda-4fd1-94d2-d426bab93819',
      '06': '4be5de27-0c8b-4722-896f-e40ad6c4ae7c',
      '07': 'ec72210f-d9ae-43f3-b728-4a960e42531e',
      '08': 'd5e53b17-5616-4ccf-8d02-2ccd773fd72f',
      '09': 'd5cf61a2-1aa1-4555-a973-3352e98cf210',
    };

    // Generate a random key
    final random = Random();
    final randomKey =
        imgDetails.keys.elementAt(random.nextInt(imgDetails.length));

    // Construct and return the URL
    return "${baseUrl}${randomKey}.jpg?alt=media&token=${imgDetails[randomKey]}";
  }

  _login() async {
    setState(() {
      isLoading = true;
      url = _getRandomImageUrl();
    });

    try {
      final user = await AuthService().createUserWithEmailAndPassword(
          _emailController.text, _passwordController.text);

      if (user != null) {
        await FirestoreService().addUser(user.uid, {
          "name": _nameController.text,
          "email": _emailController.text,
          "academicYear": null,
          "graduationYear": null,
          "preferences": [],
          "skills": [],
          "profileUrl": url,
          "lastDailyUpdate": DateTime.now(),
          "lastWeeklyUpdate": DateTime.now(),
          "lastMonthlyUpdate": DateTime.now(),
          "courseDetails": [],
          "threeMonthList": [],
          "oneMonthList": [],
          "oneWeekList": [],
          "dailyVideoList": [],
          "initDate": DateTime.now(),
          "score": 0,
          "dailyStreak": 0,
          "lastActiveDate": null,
          "rank": 0
        });

        setState(() {
          isLoading = false;
        });

        moveToNextScreen(context, const OnBoardScreen());
        showToast('Successfully Registered!');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      switch (e.code) {
        case 'email-already-in-use':
          showToast("This email is already in use. Try logging in.");
          break;
        case 'invalid-email':
          showToast("Invalid email format. Please enter a valid email.");
          break;
        case 'weak-password':
          showToast("Password is too weak. Use at least 6 characters.");
          break;
        default:
          showToast("Sign-up failed: ${e.message}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showToast("An unexpected error occurred. Please try again.");
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width / 8),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F75BC)),
            ),
            const SizedBox(height: 30),
            CustomFormField(
              controller: _nameController,
              hintText: 'Name',
              validator: MultiValidator([
                RequiredValidator(
                  errorText: "Please enter name",
                ),
              ]).call,
            ),
            const SizedBox(height: 20.0),
            CustomFormField(
              controller: _emailController,
              hintText: 'Email',
              validator: MultiValidator([
                RequiredValidator(
                  errorText: "Please enter email",
                ),
                EmailValidator(
                  errorText: "Not Valid Email",
                ),
              ]).call,
            ),
            const SizedBox(height: 20.0),
            CustomPasswordFormField(
              controller: _passwordController,
              hintText: 'Password',
              showSuffixIcon: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                  return 'Password must contain an uppercase letter';
                } else if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                  return 'Password must contain a lowercase letter';
                } else if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                  return 'Password must contain a number';
                } else if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
                  return 'Password must contain a special character (@, !, %, etc.)';
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            CustomPasswordFormField(
              controller: _conPasswordController,
              hintText: 'Conform Password',
              showSuffixIcon: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please re-enter your password';
                } else if (value != _passwordController.text) {
                  return 'Password does not match';
                }

                return null;
              },
            ),
            const SizedBox(height: 10.0),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Password must contain:\n"
                "• At least 8 characters    "
                "• One uppercase letter\n"
                "• One lowercase letter    "
                "• One number\n"
                "• One special character",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20.0),
            CustomButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process login data
                  _login();
                  //EasyLoading.show();
                } else if (_formKey.currentState!.validate()) {
                  showToast("");
                }
              },
              isLoading: isLoading,
              text: 'Sign Up',
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Already  Have an Account?",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "  Login",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Or"),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                AuthService().signInWithGoogle(context).then((success) async {
                  await SharedPreferenceService.setBool("isLogged", true);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(3, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset('assets/images/google.png'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
