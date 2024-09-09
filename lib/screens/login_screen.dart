import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/custom_password_form_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                SizedBox(height: MediaQuery.of(context).size.height / 6),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 100,
                  child: Image.asset('assets/images/logo_blue.png'),
                ),
                const LoginForm(),
              ],
            ),
          ),
        ),
      ),
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
            const SizedBox(height: 10.0),
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
            const SizedBox(height: 10.0),
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
            const SizedBox(height: 10.0),

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
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ),
              ],
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
                    recognizer: TapGestureRecognizer()..onTap = () {},
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
