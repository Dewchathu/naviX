import 'package:flutter/material.dart';
import 'package:navix/widgets/custom_button.dart';

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
  final TextEditingController _prefferencesController = TextEditingController();
  bool isTextFieldEnnabeld = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Name'),
        actions: [
          IconButton(
            icon: Icon(isTextFieldEnnabeld ? Icons.lock_open : Icons.lock),
            onPressed: () {
              setState(() {
                isTextFieldEnnabeld = !isTextFieldEnnabeld; // Toggle edit mode
              });
            },
          )
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
            _buildEditableField("Name", _nameController, isTextFieldEnnabeld),
            const SizedBox(height: 5),
            _buildEditableField("Email", _emailController, isTextFieldEnnabeld),
            const SizedBox(height: 5),
            _buildEditableField("Current Academic Year", _academicYearController, isTextFieldEnnabeld),
            const SizedBox(height: 5),
            _buildEditableField("Graduation Year", _graduationYearController, isTextFieldEnnabeld),
            const SizedBox(height: 5),
            _buildEditableField("Preferences", _prefferencesController, isTextFieldEnnabeld),
            const SizedBox(height: 5),
            _buildEditableField("Skills", _skillsController, isTextFieldEnnabeld),
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

Widget _buildEditableField(String label, TextEditingController controller, bool isTextFieldEnabled) {
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