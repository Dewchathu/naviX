import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:navix/screens/login_screen.dart';

import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/custom_password_form_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
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

  final _formKey = GlobalKey<FormState>();
  bool isValidateMode = false;
  bool isLoading = false;
  bool _isLegalMember = false;

  @override
  bool _isLoading = false;

  @override

  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  validate() {
    setState(() {
      isValidateMode = true;
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      _login();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to handle login button press
  _login() async {
    setState(() {
      isLoading = true;
    });
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
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),

            CustomButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _isLegalMember == true) {
                  // Process login data
                  _login();
                  //EasyLoading.show();
                } else if (_formKey.currentState!.validate() &&
                    _isLegalMember == false) {
                  Fluttertoast.showToast(
                      msg: "This is Center Short Toast",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
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
                    recognizer: TapGestureRecognizer()..onTap = () {
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
                AuthService().signInWithGoogle(context).then((success) {
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
                    child: Image.asset(
                        'assets/images/google.png'
                    ),
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
