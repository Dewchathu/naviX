import 'package:flutter/material.dart';

class IntroScroll extends StatefulWidget {
  const IntroScroll({super.key});

  @override
  State<IntroScroll> createState() => _IntroScrollState();
}

class _IntroScrollState extends State<IntroScroll> {
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
          const Text('Java, Flutter, Dart'),
          const SizedBox(height: 10),
          const Text(
            'Preferences',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Coding, Designing'),
          const SizedBox(height: 10),
          const Text(
            'Job List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Developer, UI/UX Designer'),
          const SizedBox(height: 10),
          const Text(
            'Required Skills',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Coding, Designing'),
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
              0: FlexColumnWidth(
                  2), // Adjust the width of the first column (Semester)
              1: FlexColumnWidth(
                  3), // Adjust the width of the second column (Course Name)
              2: FlexColumnWidth(
                  2), // Adjust the width of the third column (Course Code)
            },
            children: const <TableRow>[
              TableRow(
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
              TableRow(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('1st Year 2nd Semester'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Calculus and Differential Equations'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('PST11211'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
