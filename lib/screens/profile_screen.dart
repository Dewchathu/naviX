import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../actions/move_to_next_sceen.dart';
import '../actions/update_signout.dart';
import '../providers/profile_provider.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'package:path/path.dart' as path_delegate;

import '../widgets/custom_image_picker.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String profilePictureUrl = "";
  int streak = 0;
  int rank = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      Map<String, dynamic>? userInfo =
      await FirestoreService().getCurrentUserInfo();
      if (userInfo != null) {
        setState(() {
          profilePictureUrl = userInfo["profileUrl"] ??
              "assets/images/profile_image.png";
          Provider.of<ProfileProvider>(context, listen: false)
              .updateProfilePicture(profilePictureUrl);

          _nameController.text = userInfo["name"] ?? "";
          _emailController.text = userInfo["email"] ?? "";
          streak = userInfo["dailyStreak"] ?? 0;
          rank = userInfo["rank"] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<void> _selectImage(ImageSource source, String? imageUrl) async {
    try {
      if (imageUrl != null) {
        // This block will handle the case when a predefined image is selected
        setState(() {
          isLoading = true;
        });

        // Directly update the profile picture with the selected Firebase image URL
        await FirestoreService().updateUserInfo({"profileUrl": imageUrl});

        // Update the profile picture using the provider
        setState(() {
          Provider.of<ProfileProvider>(context, listen: false)
              .updateProfilePicture(imageUrl);
          isLoading = false;
          profilePictureUrl = imageUrl;
        });
      } else {
        // This block will handle the case when a new image is picked from the Camera or Gallery
        final pickedFile = await ImagePicker().pickImage(source: source);

        setState(() {
          isLoading = true;
        });

        if (pickedFile != null) {
          var downloadUrl = await StorageService().uploadFile(
            File(pickedFile.path),
            "Profile Pictures",
            path_delegate.basename(File(pickedFile.path).path),
          );

          await FirestoreService().updateUserInfo({"profileUrl": downloadUrl});

          // Update the profile picture using the provider
          setState(() {
            Provider.of<ProfileProvider>(context, listen: false)
                .updateProfilePicture(downloadUrl!);
            isLoading = false;
            profilePictureUrl = downloadUrl;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error selecting/updating image: $e");
    }
  }


  Future<void> _signOut() async {
    Navigator.of(context)
        .pop(); // Close the dialog before signing out
    updateSignOut(context);
    moveToNextScreen(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F75BC),
        title: const Text('Profile',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
            color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            color: Colors.white,
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                _showProfileImageDialog();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'profileImage',
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : const AssetImage('assets/images/profile_image.png')
                      as ImageProvider,
                    ),
                  ),
                  if (isLoading)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: LoadingIndicator(
                            indicatorType: Indicator.lineSpinFadeLoader,
                            colors: [Colors.blue],
                            strokeWidth: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _nameController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _emailController.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                    streak.toString(), 'Streak', 'assets/svgs/flame.svg'),
                _buildStatCard(rank.toString(), 'Rank', 'assets/svgs/winner.svg'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'A passionate UI/UX designer with a love for crafting meaningful digital experiences. Skilled in various tools including Adobe XD, Sketch, Figma, and more.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, String img) {
    return Column(
      children: [
        SvgPicture.asset(
          img,
          width: 30,
          height: 30,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showProfileImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: AspectRatio(
            aspectRatio: 1,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: 'profileImage',
                    child: profilePictureUrl.isNotEmpty
                        ? Image.network(
                      profilePictureUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                        : Image.asset(
                      'assets/images/profile_image.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.white,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                      showImagePickerBottomSheet(
                          context, _selectImage
                      );
                      // showImageSourceDialog(
                      //     context, _selectImage);
                    },
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    label: const Text(
                      'Change Profile Picture',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
