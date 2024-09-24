import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';
import '../services/shared_preference_service.dart';

updateSignOut(BuildContext context){
  //EasyLoading.show();
  AuthService().signOut().then((noValue){
    //EasyLoading.dismiss();
    SharedPreferenceService.setBool("isLogged", false);
  });
}