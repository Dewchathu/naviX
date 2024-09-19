import 'package:flutter/material.dart';
import 'package:navix/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Name'),
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
                    const CircleAvatar(
                      backgroundImage: NetworkImage('https://picsum.photos/200'),
                      // backgroundImage: profilePictureUrl == "assets/profile.png"
                      //     ? const AssetImage('assets/profile.png')
                      //     : NetworkImage(profilePictureUrl) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: -25,
                      child: RawMaterialButton(
                        onPressed: () {
                         // showImageSourceDialog(context, _selectImage);
                        },
                        elevation: 2.0,
                        fillColor: const Color(0xFFF5F6F9),
                        padding: const EdgeInsets.all(15.0),
                        shape: const CircleBorder(),
                        child: const Icon(Icons.camera_alt_outlined,
                            color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            //_buildEditableField("Surname", surnameController),
            const SizedBox(height: 10),
            //_buildEditableField("Email", emailController),
            const SizedBox(height: 10),
            //_buildEditableField("Date Of Birth", dobController),
            const SizedBox(height: 10),
            //_buildEditableField("Phone", phoneController),
            const SizedBox(height: 10),
            //_buildEditableField("UserName", userNameController),
            const SizedBox(height: 20,),
            CustomButton(
                onPressed: (){},
                text: 'Sign Out'
            )
            // MainCustomButton(
            //     onPressed: (){
            //       FirestoreService().deleteThisUser();
            //       Navigator.pop(context);
            //       updateLogout(context);
            //       moveToNextScreen(context, const CheckingScreen());
            //     },
            //     text: 'Delete Account'
            // )
          ],
        ),
      ),
    );
  }
}
