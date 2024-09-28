import 'package:flutter/material.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/home.dart';
import 'package:navix/widgets/custom_button.dart';
import 'package:navix/widgets/custom_form_field.dart';

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
  bool isSubmit = false;
  List<String> jobList = [
    "Front end Developer",
    "UI/UX Designer",
    "Data Analyst",
    "Software Engineer",
    "Product Manager",
    "Digital Marketing Specialist",
  ];
  List<String> selectedJobs = [];

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
                isSubmit = true;
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

        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: jobList.map((job) {
            final bool isSelected = selectedJobs.contains(job);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    // Deselect the job if it's already selected
                    selectedJobs.remove(job);
                  } else if (selectedJobs.length < 3) {
                    // Select the job if less than 3 jobs are selected
                    selectedJobs.add(job);
                  }
                });
              },
              child: _buildSelectableCard(job, isSelected),
            );
          }).toList(),
        ),

        const SizedBox(height: 30),

        // Display selected jobs
        Center(
          child: Text(
            'Selected Jobs: ${selectedJobs.join(", ")}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: CustomButton(
            onPressed:
                // selectedJobs.isNotEmpty ? () {
                //   // Move to the next screen or save selected jobs
                //   moveToNextScreen(context, const HomeScreen());
                // } : null,
                () {
              moveToNextScreen(context, const HomeScreen());
            },
            text: 'Submit',
          ),
        ),
      ],
    );
  }

  // Function to build selectable job cards
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

}
