import 'package:flutter/material.dart';
import 'package:navix/screens/profile_screen.dart';
import 'package:navix/widgets/home_scroll.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NaviX'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ProfileScreen()), // Navigate to ProfileScreen
                  );
                },
                child: const CircleAvatar(
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
              ),
            ),
          ],
        ),
        body: const TabBarView(
          children: <Widget>[
            Center(
              child: Text("It's cloudy here"),
            ),
            HomeScroll(),
            Center(
              child: Text("It's sunny here"),
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
              text: 'Calender',
            ),
          ],
        ),
      ),
    );
  }
}
