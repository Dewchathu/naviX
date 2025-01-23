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
    
  Select suitable elective courses for each semester considering 
    - **preferences:** ${_preferencesController.text} 
    - **future jobs:** ${_selectedJobsController.text} 
    - **credit requirements** 
  such that the total credits match the required credits for that semester. 
  
  **Prioritize courses that are relevant to the specified preferences and future jobs.** 

  give the only answer as a Map List where keys are "year-semester" and values are lists of selected courses and course codes.
  ex: structure should like this
  {
  "2-2": {
    "PST 22215": "Mathematical Methods",
    "PST 22112": "Leadership and Communication"
  },
  "3-1": {
    "PST 31230": "Social and Professional Issues in Computing",
    "PST 31211": "Mathematical Programming"
  },
  "3-2": {
    "PST 32232": "Bioinformatics",
    "PST 32210": "Statistics in Quality Control"
  },
  "4-1": {
    "PST 41231": "Natural Language Processing",
    "PST 41215": "Industrial Management",
    "PST 41234": "Mobile Computing"
  }
}
  ''',
      );

      String? geminiResponse = response?.output;
      debugPrint('Gemini response: $geminiResponse');

      if (geminiResponse != null) {
        // Decode the response and handle dynamic value types
        Map<String, dynamic> selectedCourses =
        Map<String, dynamic>.from(json.decode(geminiResponse));

        setState(() {
          // Transform the nested map into a displayable list of strings
          recommendedCourses = selectedCourses.entries.map((entry) {
            String yearSemester = entry.key;
            String courses = (entry.value as Map<String, dynamic>)
                .entries
                .map((courseEntry) =>
            "${courseEntry.key}: ${courseEntry.value}")
                .join('\n');
            return "$yearSemester:\n$courses";
          }).toList();
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
                child: Text(
                  course,
                  style: const TextStyle(fontSize: 16),
                ),
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
