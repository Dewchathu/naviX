import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/home.dart';
import 'package:navix/services/firestore_service.dart';
import 'package:navix/widgets/custom_button.dart';
import 'package:navix/widgets/loading_indicator.dart';

import '../widgets/custom_form_field.dart';
import '../widgets/setup_process.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _graduationYearController =
  TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final gemini = Gemini.instance;
  bool isSubmit = false;
  List<String> jobList = [];
  List<String> selectedJobs = [];
  List<String> threeMonthList = [];
  List<String> oneMonthList = [];
  List<String> oneWeekList = [];
  List<String> dailyVideoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: !isSubmit ? _aboutUser() : _jobList(),
        ),
      ),
    );
  }

  Widget _aboutUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Center(
          child: Text(
            'About You',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F75BC),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          title: 'What is your current academic year?*',
          controller: _academicYearController,
          hintText: 'Enter your academic year, Ex: 1.2',
        ),
        _buildInputField(
          title: 'What is your graduation year?*',
          controller: _graduationYearController,
          hintText: 'Enter your graduation year',
        ),
        _buildInputField(
          title: 'What are your preferences?*',
          controller: _preferencesController,
          hintText: 'Enter your preferences, Ex: Designing, Coding',
        ),
        _buildInputField(
          title: 'What are your skills?*',
          controller: _skillsController,
          hintText: 'Enter your skills, Ex: Dart, Figma, Photoshop',
        ),
        const SizedBox(height: 30),
        Center(
          child: CustomButton(
            onPressed: () {
              setState(() {
                isSubmit = false;
              });

              loadingIndicator.show(context);
              gemini
                  .text(
                  "${_preferencesController.text} are my preferences, and ${_skillsController.text} are my skills. What are some job titles related to computer science that align with these preferences and skills? Provide the answer as a list."
              )
                  .then((value) {
                if (value?.output != null) {
                  // Split by newline and remove the leading numbers using regex
                  if (value?.output != null) {
                    jobList = value!.output!
                        .split('\n') // Split by newlines
                        .map((job) => job
                        .replaceAll('*', '')
                        .replaceAll('-', '')
                        .trim())
                        .where((job) =>
                    job.isNotEmpty &&
                        !job.contains(
                            ':')) // Remove empty entries and titles with colon
                        .toList();
                  }
                }
                setState(() {
                  isSubmit = true;
                });
                loadingIndicator.dismiss();
                //print(jobList);
              }).catchError((e) {
                loadingIndicator.dismiss();
                debugPrint(e);
              });
            },
            text: 'Submit',
          ),
        ),
      ],
    );

  }





  Widget _jobList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Center(
          child: Text(
            'Job List',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F75BC),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Please select 3 jobs that suit you'),
        const SizedBox(height: 20),

        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: jobList.map((job) {
            final bool isSelected = selectedJobs.contains(job);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedJobs.remove(job);
                  } else if (selectedJobs.length < 3) {
                    selectedJobs.add(job);
                  }
                });
              },
              child: _buildSelectableCard(job, isSelected),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        Center(
          child: CustomButton(
            onPressed: () async {
              loadingIndicator.show(context);

              try {
                // Step 1: Process Three-Month List
                await _runTest();

                // Step 2: Save Data to Firebase
                await FirestoreService().updateUserInfo({
                  "academicYear": _academicYearController.text,
                  "graduationYear": _graduationYearController.text,
                  "skills": _skillsController.text.split(',').map((e) => e.trim()).toList(),
                  "preferences": _preferencesController.text.split(',').map((e) => e.trim()).toList(),
                  "jobList": selectedJobs,
                  "threeMonthList": threeMonthList,
                  "oneMonthList": oneMonthList,
                  "oneWeekList": oneWeekList,
                  "dailyVideoList": dailyVideoList,
                });

                moveToNextScreen(context, const HomeScreen());
              } catch (e) {
                debugPrint('Error: $e');
              } finally {
                loadingIndicator.dismiss();
              }
            },
            text: 'Submit',
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String title,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          CustomFormField(
            controller: controller,
            hintText: hintText,
          )
        ],
      ),
    );
  }


  Widget _buildSelectableCard(String job, bool isSelected) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            job,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.blue : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> _runTest() async {
    loadingIndicator.show(context);
    try {
      // Get selected jobs and skills
      String skills = _skillsController.text;

      // Call the method from `setupProcess.dart`
      await setupProcess(selectedJobs, skills).then((value) => {
        setState(() {
          threeMonthList = value['threeMonthList'] ?? [];
          oneMonthList = value['oneMonthList'] ?? [];
          oneWeekList = value['oneWeekList'] ?? [];
          dailyVideoList = value['dailyVideoList'] ?? [];
        }),
        debugPrint('Results: $value')
      });

      debugPrint('Three-Month List: $threeMonthList');
      debugPrint('One-Month List: $oneMonthList');
      debugPrint('One-Week List: $oneWeekList');
      debugPrint('Daily Video List: $dailyVideoList');
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      loadingIndicator.dismiss();
    }
  }
}

