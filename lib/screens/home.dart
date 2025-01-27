import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/profile_screen.dart';
import 'package:navix/widgets/calender.dart';
import 'package:navix/widgets/home_scroll.dart';
import 'package:navix/widgets/leader_board.dart';
import 'package:provider/provider.dart';

import '../models/user_info.dart';
import '../providers/profile_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/info_scroll.dart';
import '../widgets/show_back_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String profilePictureUrl = "";
  UserInfo? user;
  final gemini = Gemini.instance;
  List<String> threeMonthList = [];

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
            dailyVideoList: List<String>.from(userInfo["dailyVideoList"] ?? []),
            initDate: DateTime.parse(userInfo["initDate"].toDate().toString()),
            oneWeekList: List<String>.from(userInfo["oneWeekList"] ?? []),
            dailyStreak: userInfo["dailyStreak"] ?? 0,
            score: userInfo["score"] ?? 0,
            lastActiveDate: DateTime.parse(userInfo["initDate"].toDate().toString()),

          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching user info: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return PopScope<Object>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return; // If the pop was already handled, exit early
        }
        final bool shouldPop = await showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context); // Pop the current screen if allowed
        }
      },
      child: DefaultTabController(
        length: 4,
        initialIndex:
            1,
        child: Scaffold(
          backgroundColor: const Color(0xFFE0F1FF),
          appBar: AppBar(
            backgroundColor: const Color(0xFFE0F1FF),
            title: Center(
              child: SizedBox(
                height: 35,
                child: Image.asset('assets/images/logo_appbar.png'),
              ),
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
              user != null? HomeScroll(user: user) : const SizedBox.shrink(),
              Calendar(user: user),
              Leaderboard()
            ],
          ),
          bottomNavigationBar: Container(
            width: MediaQuery.of(context).size.width - 40,
            height: 70,
            color: const Color(0xFF0F75BC),
            child: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor:Color(0xFF97D2FF),
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.list_alt_rounded),
                ),
                Tab(
                  icon: Icon(Icons.home),
                ),
                Tab(
                  icon: Icon(Icons.calendar_month_rounded),
                ),
                Tab(
                  icon: Icon(Icons.wine_bar),
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }
}
