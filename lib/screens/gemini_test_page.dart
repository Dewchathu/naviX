import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:navix/widgets/loading_indicator.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ElectiveSelectorPage extends StatefulWidget {
  const ElectiveSelectorPage({Key? key}) : super(key: key);

  @override
  State<ElectiveSelectorPage> createState() => _ElectiveSelectorPageState();
}

class _ElectiveSelectorPageState extends State<ElectiveSelectorPage> {
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _selectedJobsController = TextEditingController();

  List<String> recommendedCourses = [];
  List<Map<String, dynamic>> electiveCourses = [];
  Map<String, int> semesterCreditRequirements = {};

  @override
  void initState() {
    super.initState();
    _loadJsonFiles();
  }

  Future<void> _loadJsonFiles() async {
    try {
      final coursesJson =
      await rootBundle.loadString('assets/jsons/elective_cources.json');
      final creditsJson =
      await rootBundle.loadString('assets/jsons/semester_credit.json');

      setState(() {
        electiveCourses =
        List<Map<String, dynamic>>.from(json.decode(coursesJson));

        semesterCreditRequirements = {
          for (var entry in json.decode(creditsJson))
            "${entry['year']}-${entry['semester']}": entry['requiredCredit']
        };
        //debugPrint('--------------------------: $electiveCourses');
        //debugPrint('-----------------------: $semesterCreditRequirements');

      });
    } catch (e) {
      debugPrint('Error loading JSON files: $e');
    }
  }

  Future<void> _runElectiveSelector() async {
    loadingIndicator.show(context);
    try {
      final gemini = Gemini.instance;
      Candidates? response = await gemini.text(
        '''
        Using the given JSON data:
          - details of elective courses: ${json.encode(electiveCourses)}
          - required credits per semester: ${json.encode(semesterCreditRequirements)}
          
        Select suitable elective courses for each semester such that the total credits match the required credits for that semester. 
        give the only output as a Map List where keys are "year-semester" and values are lists of selected courses and course codes.
        ''',
      );

      String? geminiResponse = response?.output;
      debugPrint('Gemini response: $geminiResponse');

      if (geminiResponse != null) {
        Map<String, List<String>> selectedCourses =
        Map<String, List<String>>.from(json.decode(geminiResponse));

        setState(() {
          recommendedCourses = selectedCourses.entries
              .map((entry) =>
          "${entry.key}: ${entry.value.map((course) => '- $course').join('\n')}")
              .toList();
        });
      } else {
        debugPrint('No recommendations received from the server.');
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      loadingIndicator.dismiss();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elective Selector'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recommendedCourses
                  .map((course) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(course),
              ))
                  .toList(),
            )
                : const Text('No recommendations available.'),
          ],
        ),
      ),
    );
  }
}
