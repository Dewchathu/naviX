import 'package:flutter/material.dart';
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
    preferences = (widget.user?.preferences as List<dynamic>?)?.join(", ") ?? "";
    jobList = (widget.user?.jobList as List<dynamic>?)?.join(", ") ?? "";
    reqSkills = (widget.user?.reqSkills as List<dynamic>?)?.join(", ") ?? "";
  }

  List<TableRow> _buildCourseRows() {
    // Check if courseDetails is available
    if (widget.user?.courseDetails == null || widget.user!.courseDetails.isEmpty) {
      return [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No Course Details Available'),
            ),
          ],
        ),
      ];
    }

    // Generate TableRow for each course
    return widget.user!.courseDetails.map<TableRow>((course) {
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(course['semester']),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(course['courseName']),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(course['courseCode']),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Skills',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(skills),
          const SizedBox(height: 10),
          const Text(
            'Preferences',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(preferences),
          const SizedBox(height: 10),
          const Text(
            'Job List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(jobList),
          const SizedBox(height: 10),
          const Text(
            'Required Skills',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(reqSkills),
          const SizedBox(height: 10),
          const Text(
            'Elective Subjects',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Course Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Course Code',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ..._buildCourseRows(),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
