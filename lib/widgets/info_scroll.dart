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
    double width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: 150,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                //color: const Color(0xFF0F75BC),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F75BC), Color.fromARGB(
                        255, 87, 186, 255)],
                  ),
                  borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hey ${widget.user?.name} 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        '"Take a small step today, and it will definitely be the beginning of a great journey."',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontStyle: FontStyle.italic
                      ),
                    )
                  ],
                )
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 10),
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
        color: Colors.black,
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
                      color: Color(0xFF0F75BC),
                    ),
                  ),
                ),
              if (semester["courses"] != null)
                ...List.generate(
                  (semester["courses"] as List).length,
                      (index) {
                    var course = semester["courses"][index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              color: const Color(0xFFE3F2FD),
                              padding: const EdgeInsets.all(8.0),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Color(0xFFFF7400),
                                size: 24.0,
                              ),
                            ),
                            Text(
                              course["code"] ?? "No Code",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 50),
                            Text(
                              course["name"] ?? "No Name",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                      ],
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
    if (info.isEmpty) {
      return _buildInfoCard("No information available.");
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: items.map((item) {
        return Chip(
          label: Text(_capitalizeWords(item),),
          backgroundColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.grey),
          side: const BorderSide(
            color: Colors.white,
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        );
      }).toList(),
    );
  }

  String _capitalizeWords(String text) {
    return text
        .split(" ")
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : word)
        .join(" ");
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
