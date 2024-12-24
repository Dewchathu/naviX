import 'package:flutter/material.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/gemini_test_page.dart';
import 'package:navix/screens/onboard_screen.dart';
import 'package:navix/widgets/custom_button.dart';
import '../models/user_info.dart';

class IntroScroll extends StatefulWidget {
  final UserInfo? user;
  const IntroScroll({super.key, required this.user});

  @override
  State<IntroScroll> createState() => _IntroScrollState();
}

class _IntroScrollState extends State<IntroScroll> {
  String skills = "";
  String preferences = "";
  String jobList = "";
  String reqSkills = "";

  @override
  void initState() {
    super.initState();
    skills = (widget.user?.skills as List<dynamic>?)?.join(", ") ?? "";
    preferences =
        (widget.user?.preferences as List<dynamic>?)?.join(", ") ?? "";
    jobList = (widget.user?.jobList as List<dynamic>?)?.join(", ") ?? "";
  }

  List<TableRow> _buildCourseRows() {
    if (widget.user?.courseDetails == null ||
        widget.user!.courseDetails.isEmpty) {
      return [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No Course Details Available',
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ];
    }

    return widget.user!.courseDetails.map<TableRow>((course) {
      // Ensure default values are provided if any field is missing
      String semester = course['semester'] ?? 'N/A';
      String courseName = course['courseName'] ?? 'N/A';
      String courseCode = course['courseCode'] ?? 'N/A';

      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(semester),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(courseName),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(courseCode),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16), // Add padding for cleaner look
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Skills'),
            _buildInfoCard(skills),
            const SizedBox(height: 20),
            _buildSectionTitle('Preferences'),
            _buildInfoCard(preferences),
            const SizedBox(height: 20),
            _buildSectionTitle('Job List'),
            _buildInfoCard(jobList),
            const SizedBox(height: 20),
            _buildSectionTitle('Elective Subjects'),
            _buildTable(),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Get Started',
              onPressed: () {
                moveToNextScreen(context, const ElectiveSelectorPage());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F75BC),
      ),
    );
  }

  Widget _buildInfoCard(String info) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        info.isNotEmpty ? info : 'No Information Available',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      border: TableBorder.all(color: Colors.black12),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
      },
      children: [
        const TableRow(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Semester',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Course Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Course Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
        ..._buildCourseRows(),
      ],
    );
  }
}
