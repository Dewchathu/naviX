import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/info_messages.dart';

class SharedPreferenceService{

  static Future<bool> setBool(key, value) async{
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      return preferences.setBool(key, value);
    } catch(e){
      showToast("Oops! something wrong.");
      return false;
    }
  }

  static Future getBool(key) async{
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      return preferences.get(key);
    } catch(e){
      showToast("Oops! something wrong.");
    }
  }
}