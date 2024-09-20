import 'package:flutter/material.dart';
import 'package:navix/screens/profile_screen.dart';
import 'package:navix/widgets/home_scroll.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ), // Navigate to ProfileScreen
                  );
                },
                child: const CircleAvatar(
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
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
