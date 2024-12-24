import 'package:flutter/material.dart';
import 'package:navix/widgets/loading_indicator.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ElectiveSelectorPage extends StatefulWidget {
  const ElectiveSelectorPage({super.key});

  @override
  State<ElectiveSelectorPage> createState() => _ElectiveSelectorPageState();
}

class _ElectiveSelectorPageState extends State<ElectiveSelectorPage> {
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _selectedJobsController = TextEditingController();

  List<String> recommendedCourses = [];
  Map<String, dynamic> jobSkillMapping = {};
  Map<String, dynamic> courseData = {};

  @override
  void initState() {
    super.initState();
    _loadJsonFiles();
  }

  Future<void> _loadJsonFiles() async {
    try {
      final jobSkillJson = await rootBundle.loadString('assets/job_skill_mapping.json');
      final courseJson = await rootBundle.loadString('assets/courses.json');

      setState(() {
        jobSkillMapping = json.decode(jobSkillJson);
        courseData = json.decode(courseJson);
      });
    } catch (e) {
      debugPrint('Error loading JSON files: $e');
    }
  }

  Future<void> _runElectiveSelector() async {
    loadingIndicator.show(context);
    try {
      // Get selected jobs and preferences
      List<String> selectedJobs =
      _selectedJobsController.text.split(',').map((e) => e.trim()).toList();
      List<String> preferences =
      _preferencesController.text.split(',').map((e) => e.trim()).toList();

      // Generate recommended courses based on jobs and preferences
      Set<String> skills = {};
      for (var job in selectedJobs) {
        if (jobSkillMapping.containsKey(job)) {
          skills.addAll(jobSkillMapping[job]);
        }
      }

      Set<String> matchingCourses = {};
      for (var course in courseData.keys) {
        List<dynamic> requiredSkills = courseData[course]['skills'];
        if (preferences.any((pref) => courseData[course]['tags'].contains(pref)) &&
            requiredSkills.every((skill) => skills.contains(skill))) {
          matchingCourses.add(course);
        }
      }

      setState(() {
        recommendedCourses = matchingCourses.toList();
      });

      debugPrint('Recommended Courses: $recommendedCourses');
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      loadingIndicator.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elective Selector Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Preferences and Selected Jobs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _preferencesController,
              decoration: const InputDecoration(
                labelText: 'Preferences',
                hintText: 'Enter preferences, e.g., AI, Data Science',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _selectedJobsController,
              decoration: const InputDecoration(
                labelText: 'Selected Jobs',
                hintText: 'Enter selected jobs, separated by commas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _runElectiveSelector,
                child: const Text('Get Recommended Courses'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recommended Courses:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            recommendedCourses.isNotEmpty
                ? Column(
                children: recommendedCourses
                    .map((course) => Text('- $course'))
                    .toList())
                : const Text('No data available'),
          ],
        ),
      ),
    );
  }
}
