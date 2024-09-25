import 'package:flutter/material.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/profile_screen.dart';
import 'package:navix/widgets/calender.dart';
import 'package:navix/widgets/home_scroll.dart';
import 'package:provider/provider.dart';

import '../models/user_info.dart';
import '../providers/profile_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/info_scroll.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String profilePictureUrl = "";
  UserInfo? user;

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
          profilePictureUrl =
              userInfo["profileUrl"] ?? "assets/images/profile_image.png";
          Provider.of<ProfileProvider>(context, listen: false)
              .updateProfilePicture(profilePictureUrl);
          user = UserInfo(
            name: userInfo["name"] ?? "",
            email: userInfo["email"] ?? "",
            academicYear: userInfo["academicYear"] ?? "",
            graduationYear: userInfo["graduationYear"] ?? "",
            skills: (userInfo["skills"] as List<dynamic>?)
                    ?.map((skill) => skill.toString())
                    .toList() ??
                [],
            preferences: (userInfo["preferences"] as List<dynamic>?)
                    ?.map((preference) => preference.toString())
                    .toList() ??
                [],
            courseDetails: List<Map<String, dynamic>>.from(
                userInfo["courseDetails"] ?? []),
            profileUrl:
                userInfo["profileUrl"] ?? "assets/images/profile_image.png",
            jobList: (userInfo["jobList"] as List<dynamic>?)
                    ?.map((skill) => skill.toString())
                    .toList() ??
                [],
            reqSkills: (userInfo["reqSkills"] as List<dynamic>?)
                    ?.map((skill) => skill.toString())
                    .toList() ??
                [],
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex:
          1, // Set this to 1 to open "Home" tab by default (0-based index)
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            height: 35,
            child: Image.asset('assets/images/logo_appbar.png'),
          ),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  moveToNextScreen(context, const ProfileScreen());
                },
                child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return CircleAvatar(
                      radius: 25,
                      backgroundImage: profileProvider
                                  .profilePictureUrl.isNotEmpty &&
                              Uri.tryParse(profileProvider.profilePictureUrl)
                                      ?.hasAbsolutePath ==
                                  true
                          ? NetworkImage(profileProvider.profilePictureUrl)
                          : const AssetImage('assets/images/profile_image.png')
                              as ImageProvider,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            IntroScroll(user: user),
            const HomeScroll(), // Home tab content
            const Calender(),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.list_alt_rounded),
              text: 'Info',
            ),
            Tab(
              icon: Icon(Icons.home),
              text: 'Home',
            ),
            Tab(
              icon: Icon(Icons.calendar_month_rounded),
              text: 'Calendar',
            ),
          ],
        ),
      ),
    );
  }
}
