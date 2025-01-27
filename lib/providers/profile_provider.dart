import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  String _profilePictureUrl = "assets/images/profile_image.png";

  String get profilePictureUrl => _profilePictureUrl;

  void updateProfilePicture(String newUrl) {
    _profilePictureUrl = newUrl;
    notifyListeners();
  }
}
