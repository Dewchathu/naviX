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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 8),
                SizedBox(
                  width: 100,
                  child: Image.asset('assets/images/logo_blue.png'),
                ),
                const SignupForm(),
              ],
            ),
          ),
        ),
      ),
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

  @override
  //bool _isLoading = false;

  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle login button press
  _login() async {
    setState(() {
      isLoading = true;
    });
    try {
      await AuthService()
          .createUserWithEmailAndPassword(
              _emailController.text, _passwordController.text)
          .then((user) async {
        if (user != null) {
          await FirestoreService().addUser(user.uid, {
            "name": _nameController.text,
            "email": _emailController.text,
            "academicYear": null,
            "graduationYear": null,
            "preferences": [],
            "skills": [],
            "profileUrl": "",
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
          }).then((value) {
            setState(() {
              isLoading = true;
            });
            moveToNextScreen(context, const OnBoardScreen());
            showToast('Successfully Registered!');
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // EasyLoading.dismiss();
      showToast("Login failed: $e");
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
            const SizedBox(height: 20.0),
            CustomButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process login data
                  _login();
                  //EasyLoading.show();
                } else if (_formKey.currentState!.validate()) {
                  showToast("This is Center Short Toast");
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
