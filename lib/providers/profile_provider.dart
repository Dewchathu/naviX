import 'package:flutter/material.dart';

import '../models/user_info.dart';

class ProfileProvider with ChangeNotifier {
  String _profilePictureUrl = "assets/images/profile_image.png";
  UserInfo? user;

  String get profilePictureUrl => _profilePictureUrl;

  void updateProfilePicture(String newUrl) {
    _profilePictureUrl = newUrl;
    notifyListeners();
  }

  void updateUserInfo(UserInfo newUserInfo) {
    user = newUserInfo;
    notifyListeners();
  }
}
