import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:navix/screens/forgot_password_screen.dart';
import 'package:navix/screens/home.dart';
import 'package:navix/screens/signup_screen.dart';
import 'package:navix/widgets/loading_indicator.dart';

import '../actions/move_to_next_sceen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/shared_preference_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/custom_password_form_field.dart';
import '../widgets/info_messages.dart';
import '../widgets/show_back_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                  height: MediaQuery.of(context).size.height / 3,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('assets/images/logo_blue.png',
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 2 / 3,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                    ),
                  ),
                  child: const LoginForm(),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isValidateMode = false;
  bool isLoading = false;

  @override
  // bool _isLoading = false;

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
      var user = await AuthService().loginUserWithEmailAndPassword(
          _emailController.text, _passwordController.text);

      if (user != null) {
        // Fetch current user info
        var userInfo = await FirestoreService().getCurrentUserInfo();

        // Check if userInfo is null
        if (userInfo == null) {
          setState(() {
            isLoading = false;
          });
          showToast("No account found.");
          return; // Exit the method early if no account is found
        }

        // If userInfo exists, continue
        await SharedPreferenceService.setBool("isLogged", true);
        setState(() {
          isLoading = false;
        });
        moveToNextScreen(context, const HomeScreen());
      } else {
        setState(() {
          isLoading = false;
        });
        showToast("Incorrect email or password. Please try again.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
            const SizedBox(height: 10.0),
            const Text(
              'Login',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F75BC)),
            ),
            const SizedBox(height: 30.0),
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

            // Forget Password link
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    text: "Forgot Password",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        moveToNextScreen(context, const ForgetPasswordScreen());
                      },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            CustomButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _login();
                } else if (_formKey.currentState!.validate()) {
                  showToast("Logging Error");
                }
              },
              isLoading: isLoading,
              text: 'Log In',
            ),
            const SizedBox(height: 20),

            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Don't have an account",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "  Sign Up",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
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
                loadingIndicator.show(context);
                AuthService().signInWithGoogle(context).then((success) async {
                  await SharedPreferenceService.setBool("isLogged", true);
                  loadingIndicator.dismiss();
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
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
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
