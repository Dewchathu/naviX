import 'package:flutter/material.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
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
  List<Map<String, dynamic>> semesters = [];


  @override
  void initState() {
    super.initState();
    skills = (widget.user?.skills as List<dynamic>?)?.join(", ") ?? "";
    preferences =
        (widget.user?.preferences as List<dynamic>?)?.join(", ") ?? "";
    jobList = (widget.user?.jobList as List<dynamic>?)?.join(", ") ?? "";
    semesters = widget.user?.courseDetails ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Skills'),
            _buildChips(skills),
            const SizedBox(height: 20),
            _buildSectionTitle('Preferences'),
            _buildChips(preferences),
            const SizedBox(height: 20),
            _buildSectionTitle('Job List'),
            _buildChips(jobList),
            const SizedBox(height: 20),
            _buildSectionTitle('Elective Subjects'),
            _buildCourseDetails(),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Get Started',
              onPressed: () {
                moveToNextScreen(context, const OnBoardScreen());
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

  Widget _buildCourseDetails() {

    if (semesters.isEmpty) {
      return _buildInfoCard("No course details available.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var semester in semesters)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (semester["semester"] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Semester: ${semester["semester"]}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              if (semester["courses"] != null)
                ...List.generate(
                  (semester["courses"] as List).length,
                      (index) {
                    var course = semester["courses"][index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course["code"] ?? "No Code",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F75BC),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course["name"] ?? "No Name",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }


  Widget _buildChips(String info) {
    List<String> items = info.isNotEmpty ? info.split(", ") : [];
    return Wrap(
      spacing: 8.0, // Horizontal space between chips
      runSpacing: 4.0, // Vertical space between lines of chips
      children: items.map((item) {
        return Chip(
          label: Text(item),
          backgroundColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.grey),
          side: const BorderSide(
            color: Color(0xFF0F75BC),
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard(String info) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF0F75BC),
          width: 1,
        ),
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
}
