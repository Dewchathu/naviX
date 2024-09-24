import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/actions/update_signout.dart';
import 'package:navix/screens/login_screen.dart';
import 'package:navix/widgets/custom_button.dart';
import 'package:navix/widgets/custom_image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'package:path/path.dart' as path_delegate;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _graduationYearController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  bool isTextFieldEnabled = false;

  String profilePictureUrl = "";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      await FirestoreService().getCurrentUserInfo().then((snapshot) async {
        setState(() {
          profilePictureUrl = snapshot?.data()?["profileUrl"] ??
              "assets/images/profile_image.png";
          Provider.of<ProfileProvider>(context, listen: false)
              .updateProfilePicture(profilePictureUrl);

          _nameController.text = snapshot?.data()?["name"] ?? "";
          _emailController.text = snapshot?.data()?["email"] ?? "";
          _academicYearController.text =
              snapshot?.data()?["academicYear"] ?? "";
          _graduationYearController.text =
              snapshot?.data()?["graduationYear"] ?? "";
          _skillsController.text =
              (snapshot?.data()?["skills"] as List<dynamic>?)
                  ?.join(", ") ?? "";

          _preferencesController.text =
              (snapshot?.data()?["preferences"] as List<dynamic>?)
                  ?.join(", ") ?? "";
        });
      });
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<void> _saveUserInfo() async {
    try {
      await FirestoreService().updateUserInfo({
        "username": _nameController.text,
        "email": _emailController.text,
        "academicYear": _academicYearController.text,
        "graduationYear": _graduationYearController.text,
        "skills": _skillsController.text.split(',')
            .map((e) => e.trim())
            .toList(),
        "preferences": _preferencesController.text.split(',').map((e) =>
            e.trim()).toList(),
      });
    } catch (e) {
      print("Error saving user info: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Section'),
        actions: [
          IconButton(
            icon: Icon(isTextFieldEnabled ? Icons.lock_open : Icons.lock),
            onPressed: () {
              setState(() {
                isTextFieldEnabled = !isTextFieldEnabled;
              });
            },
          ),
          if (isTextFieldEnabled)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveUserInfo, // Save changes
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    Consumer<ProfileProvider>(
                      builder: (context, profileProvider, child) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: profileProvider.profilePictureUrl.isNotEmpty &&
                              Uri.tryParse(profileProvider.profilePictureUrl)?.hasAbsolutePath == true
                              ? NetworkImage(profileProvider.profilePictureUrl)
                              : const AssetImage('assets/images/profile_image.png') as ImageProvider,
                        );
                      },
                    ),

                    Positioned(
                      bottom: 0,
                      right: -25,
                      child: RawMaterialButton(
                        onPressed: () {
                          showImageSourceDialog(context, _selectImage);
                        },
                        elevation: 2.0,
                        fillColor: const Color(0xFFF5F6F9),
                        padding: const EdgeInsets.all(15.0),
                        shape: const CircleBorder(),
                        child: const Icon(
                            Icons.camera_alt_outlined, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildEditableField("Name", _nameController, isTextFieldEnabled),
            const SizedBox(height: 5),
            _buildEditableField("Email", _emailController, isTextFieldEnabled),
            const SizedBox(height: 5),
            _buildEditableField(
                "Current Academic Year", _academicYearController,
                isTextFieldEnabled),
            const SizedBox(height: 5),
            _buildEditableField("Graduation Year", _graduationYearController,
                isTextFieldEnabled),
            const SizedBox(height: 5),
            _buildEditableField(
                "Preferences", _preferencesController, isTextFieldEnabled),
            const SizedBox(height: 5),
            _buildEditableField(
                "Skills", _skillsController, isTextFieldEnabled),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Sign Out'),
                      content: const Text('Are you sure you want to Sign Out?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Close the dialog before signing out
                            updateSignOut(context);
                            moveToNextScreen(context, const LoginScreen());
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    );
                  },
                );
              },
              text: 'Sign Out',
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        var downloadUrl = await StorageService().uploadFile(
          File(pickedFile.path),
          "Profile Pictures",
          path_delegate.basename(File(pickedFile.path).path ?? ""),
        );

        await FirestoreService().updateUserInfo({"profileUrl": downloadUrl});

        // Update the profile picture using the provider
        setState(() {
          Provider.of<ProfileProvider>(context, listen: false)
              .updateProfilePicture(downloadUrl!);
        });
        // Hide loading indicator, etc.
      }
    } catch (e) {
      print("Error selecting/updating image: $e");
    }
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      bool isTextFieldEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        enabled: isTextFieldEnabled,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

}
