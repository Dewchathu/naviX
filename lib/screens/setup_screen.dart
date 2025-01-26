import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/home.dart';
import 'package:navix/services/firestore_service.dart';
import 'package:navix/widgets/custom_button.dart';
import 'package:navix/widgets/loading_indicator.dart';
import '../widgets/setup_process.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final gemini = Gemini.instance;
  bool isSubmit = false;
  List<String> jobList = [];
  List<String> selectedJobs = [];
  List<String> threeMonthList = [];
  List<String> oneMonthList = [];
  List<String> oneWeekList = [];
  List<String> dailyVideoList = [];
  List<Map<String, dynamic>> electiveCourses = [];
  Map<String, int> semesterCreditRequirements = {};
  List<Map<String, dynamic>> recommendedCourses = [];
  List<String> preferences = [];
  List<String> skillsList = [];

  String? selectedAcademicYear;
  String? selectedGraduationYear;

  final Map<String, String> academicYearsMap = {
    '1.1': '1 Year 1 Semester',
    '1.2': '1 Year 2 Semester',
    '2.1': '2 Year 1 Semester',
    '2.2': '2 Year 2 Semester',
    '3.1': '3 Year 1 Semester',
    '3.2': '3 Year 2 Semester',
    '4.1': '4 Year 1 Semester',
    '4.2': '4 Year 2 Semester',
  };
  Map<String, String> graduationYears = {};

  @override
  void initState() {
    super.initState();
    loadJsonFiles();
    _generateGraduationYears();
  }

  Map<String, String> _generateGraduationYears() {
    int currentYear = DateTime.now().year;

    for (int i = 0; i < 5; i++) {
      String year = (currentYear + i).toString();
      graduationYears[year] = year;
    }

    return graduationYears;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(60.0),
            child: !isSubmit ? _aboutUser() : _jobList(),
          ),
        ),
      ),
    );
  }

  Widget _aboutUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  //color: const Color(0xFF0F75BC),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F75BC),
                      Color.fromARGB(255, 87, 186, 255)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'About You...',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F75BC),
              ),
            ),
            const Text(
              'Tell us about you',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF636363),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDropdownField(
          title: 'What is your current academic year?*',
          value: selectedAcademicYear,
          itemsMap: academicYearsMap,
          onChanged: (value) {
            setState(() {
              selectedAcademicYear = value;
            });
          },
        ),
        _buildDropdownField(
          title: 'What is your graduation year?*',
          value: selectedGraduationYear,
          itemsMap: graduationYears,
          onChanged: (value) {
            setState(() {
              selectedGraduationYear = value;
            });
          },
        ),
        _buildAutocompleteField(
          title: 'What are your preferences?*',
          suggestions: [
            'Designing',
            'Coding',
            'Testing',
            'UI/UX',
            'Machine Learning'
          ],
          newList: preferences,
          hintText: 'Enter your preferences, Ex: Designing, Coding',
        ),
        _buildAutocompleteField(
          title: 'What are your skills?*',
          suggestions: ['Dart', 'Figma', 'Photoshop', 'Python', 'Flutter'],
          newList: skillsList,
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
                      "$preferences are my preferences, and $skillsList are my skills. What are some job titles related to computer science that align with these preferences and skills? Provide the answer as a list.")
                  .then((value) {
                if (value?.output != null) {
                  // Split by newline and remove the leading numbers using regex
                  if (value?.output != null) {
                    jobList = value!.output!
                        .split('\n') // Split by newlines
                        .map((job) =>
                            job.replaceAll('*', '').replaceAll('-', '').trim())
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
            text: 'Next',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String? value,
    required Map<String, String> itemsMap,
    required ValueChanged<String?> onChanged,
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
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: 'Select your option',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFFFFFFF),
              contentPadding: const EdgeInsets.all(14.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  color: Color(0xFF0F75BC),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF0092FF)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF0F75BC)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: onChanged,
            items: itemsMap.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key, // Internal value
                child: Text(entry.value), // Display value
              );
            }).toList(),
          )
        ],
      ),
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
                  "academicYear": selectedAcademicYear,
                  "graduationYear": selectedGraduationYear,
                  "skills": skillsList,
                  "preferences": preferences,
                  "jobList": selectedJobs,
                  "threeMonthList": threeMonthList,
                  "oneMonthList": oneMonthList,
                  "oneWeekList": oneWeekList,
                  "dailyVideoList": dailyVideoList,
                  "courseDetails": recommendedCourses
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

  Widget _buildAutocompleteField({
    required String title,
    required List<String> suggestions,
    required List<String> newList,
    required String hintText,
  }) {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();

    // Listener to handle user input and add it to suggestions if not present
    controller.addListener(() {
      String input = controller.text.trim();

      // Add the user input to the suggestions if it isn't already present
      if (input.isNotEmpty && !suggestions.contains(input)) {
        setState(() {
          suggestions.add(input);
          debugPrint(input);
        });
      }
    });

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
          TypeAheadField<String>(
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF),
                  contentPadding: const EdgeInsets.all(14.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F75BC),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF0092FF)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF0F75BC)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              );
            },
            emptyBuilder: (context) => const Text(''),
            suggestionsCallback: (pattern) {
              if (pattern.isEmpty) {
                return Future.value([]);
              }
              return Future.value(
                suggestions.where((String suggestion) {
                  return suggestion
                      .toLowerCase()
                      .contains(pattern.toLowerCase());
                }).toList(),
              );
            },
            itemBuilder: (context, String suggestion) {
              return ListTile(title: Text(suggestion));
            },
            onSelected: (String selection) {
              setState(() {
                // Add the selected word if it's not already in the list
                if (!newList.contains(selection)) {
                  newList.add(selection);
                }
              });
            },
          ),
          // Display chips for the list
          _buildChips(newList),
        ],
      ),
    );
  }


  Widget _buildChips(List<String> newList) {
    return Wrap(
      spacing: 8.0, // Horizontal spacing between chips
      runSpacing: 4.0, // Vertical spacing between chips
      children: newList.map((item) {
        return Chip(
          label: Text(item),
          deleteIcon: const Icon(Icons.cancel, size: 16),
          onDeleted: () {
            setState(() {
              newList.remove(item);
            });
          },
          backgroundColor: const Color(0xFF0F75BC),
          labelStyle: const TextStyle(color: Colors.white),
        );
      }).toList(),
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
      await runElectiveSelector();

      // Call the method from `setupProcess.dart`
      await setupProcess(selectedJobs, skillsList, preferences)
          .then((value) => {
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
    }
  }

  Future<void> loadJsonFiles() async {
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
      });
    } catch (e) {
      debugPrint('Error loading JSON files: $e');
    }
  }

  Future<void> runElectiveSelector() async {
    loadingIndicator.show(context);
    try {
      final gemini = Gemini.instance;
      Candidates? response = await gemini.text(
        '''
  Using the given JSON data:
    - details of elective courses: ${json.encode(electiveCourses)}
    - required credits per semester: ${json.encode(semesterCreditRequirements)}
    
  Select suitable elective courses for each semester considering 
    - **preferences:** ${preferences} 
    - **future jobs:** ${selectedJobs} 
    - **credit requirements** 
  such that the total credits match the required credits for that semester. 
  
  **Prioritize courses that are relevant to the specified preferences and future jobs.** 

  give the only answer as a Map List where keys are "year-semester" and values are lists of selected courses and course codes.
  ex: structure should like this
  {"2-2":{"PST 22215":"Mathematical Methods","PST 22112":"Leadership and Communication"},"3-1":{"PST 31230": "Social and Professional Issues in Computing","PST 31211": "Mathematical Programming"},"3-2":{"PST 32232": "Bioinformatics","PST 32210": "Statistics in Quality Control"},"4-1":{"PST 41231": "Natural Language Processing","PST 41215": "Industrial Management","PST 41234": "Mobile Computing"}}
  ''',
      );

      String? geminiResponse = response?.output;
      debugPrint('Gemini response: $geminiResponse');

      if (geminiResponse != null) {
        // Clean the response string
        String cleanedResponse =
            geminiResponse.replaceAll('\n', '').replaceAll('\r', '').trim();

        debugPrint('Cleaned Response: $cleanedResponse');

        setState(() {
          try {
            // Decode the cleaned JSON
            Map<String, dynamic> responseCourses = json.decode(cleanedResponse);

            // Parse the JSON
            responseCourses.forEach((semester, courses) {
              if (courses is Map<String, dynamic>) {
                Map<String, dynamic> semesterData = {
                  "semester": semester,
                  "courses": courses.entries
                      .map((entry) => {
                            "code": entry.key,
                            "name": entry.value.toString(),
                          })
                      .toList(),
                };
                recommendedCourses.add(semesterData);
              }
            });

            debugPrint('Recommended Courses: $recommendedCourses');
          } catch (e) {
            debugPrint('Error decoding response: $e');
          }
        });
      } else {
        debugPrint('No recommendations received from the server.');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
