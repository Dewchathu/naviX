import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:navix/screens/login_screen.dart';
import '../actions/move_to_next_sceen.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/loading_indicator.dart';


class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPasswordScreen> {

  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isValidateMode = false;
  bool isLoading = false;

  validate(){
    setState(() {
      isValidateMode = true;
      isLoading = true;
    });
    if(_formKey.currentState!.validate()){
      loadingIndicator.show(context);
      restPassword();
    }
    else{
      loadingIndicator.dismiss();
      setState((){
        isLoading = false;
      });
    }
  }

  restPassword() async{
    await AuthService().sendPasswordResetEmail(_emailController.text).then((value){
      setState((){
        isLoading = false;
      });
      loadingIndicator.dismiss();
      moveToNextScreen(context, const LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
        ),
        body: SafeArea(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width / 8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Image.asset('assets/images/logo_blue.png'),
                    ),
                    const SizedBox(height: 60.0),
                    CustomFormField(
                      hintText: 'Enter Your Email',
                      controller: _emailController,
                      validator: MultiValidator([
                        RequiredValidator(
                          errorText: "Please enter email",
                        ),
                        EmailValidator(
                          errorText: "Not a valid email",
                        ),
                      ]).call,
                    ),
                    const SizedBox(height: 20.0),
                    CustomButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          validate();
                        }
                      },
                      text: 'Send Link',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}