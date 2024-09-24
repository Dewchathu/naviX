import 'package:flutter/material.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/profile_screen.dart';
import 'package:navix/widgets/home_scroll.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../providers/profile_provider.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String profilePictureUrl = "assets/images/profile_image.png";
  String userName = "UserName";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }


  Future<void> _loadUserInfo() async {
    try {
      var snapshot = await FirestoreService().getCurrentUserInfo();
      setState(() {
        profilePictureUrl = snapshot?.data()?["profileUrl"] ?? "assets/images/profile_image.png";
        Provider.of<ProfileProvider>(context, listen: false)
            .updateProfilePicture(profilePictureUrl);
        userName = snapshot?.data()?["name"] ?? "Username";
      });
    } catch (e) {
      // Handle error fetching user info
      print("Error fetching user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1, // Set this to 1 to open "Home" tab by default (0-based index)
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NaviX'),
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
                      backgroundImage: profileProvider.profilePictureUrl.isNotEmpty &&
                          Uri.tryParse(profileProvider.profilePictureUrl)?.hasAbsolutePath == true
                          ? NetworkImage(profileProvider.profilePictureUrl)
                          : const AssetImage('assets/images/profile_image.png') as ImageProvider,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            const Center(
              child: Text("It's cloudy here"), // Info tab content
            ),
            const HomeScroll(), // Home tab content
            SfCalendar(
              view: CalendarView.month, // Calendar tab content
            ),
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
