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
import '../utils/suggestions_lists.dart';
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

  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

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
            padding: const EdgeInsets.all(16.0), // Reduced padding
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F75BC), Color.fromARGB(255, 87, 186, 255)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
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
          suggestions: SuggestionsLists().prefSuggestions,
          newList: preferences,
          controller: _preferencesController,
          hintText: 'Enter your preferences, Ex: Designing, Coding',
        ),
        _buildAutocompleteField(
          title: 'What are your skills?*',
          suggestions: SuggestionsLists().skillsList,
          newList: skillsList,
          controller: _skillsController,
          hintText: 'Enter your skills, Ex: Dart, Figma, Photoshop',
        ),
        const SizedBox(height: 30),
        Center(
          child: CustomButton(
            onPressed: _fetchJobs,
            text: 'Next',
          ),
        ),
      ],
    );
  }

  Future<void> _fetchJobs() async {
    if (selectedAcademicYear == null ||
        selectedGraduationYear == null ||
        preferences.isEmpty ||
        skillsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      isSubmit = false;
    });

    loadingIndicator.show(context);
    try {
      final response = await gemini.text(
        "$preferences are my preferences, and $skillsList are my skills. What are some job titles related to computer science that align with these preferences and skills? Provide the answer as a plain list of job titles, one per line, without markdown, numbers, or bullet points. Example:\nFrontend Developer\nMobile Developer\nDesigner",
      );

      debugPrint('Raw Gemini Response: ${response?.output}');

      if (response?.output != null) {
        jobList = response!.output!
            .split('\n')
            .map((job) => job.trim())
            .where((job) => job.isNotEmpty && RegExp(r'^[A-Za-z\s]+$').hasMatch(job))
            .toList()
            .toSet()
            .toList()
            .take(10)
            .toList();

        debugPrint('Processed Job List: $jobList');

        if (jobList.isEmpty) {
          jobList = ['Frontend Developer', 'Mobile Developer', 'Data Analyst'];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid jobs received, using fallback list')),
          );
        }
      } else {
        jobList = ['Frontend Developer', 'Mobile Developer', 'Data Analyst'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch jobs, using fallback list')),
        );
      }

      setState(() {
        isSubmit = true;
      });
    } catch (e) {
      debugPrint('Gemini Error: $e');
      jobList = ['Frontend Developer', 'Mobile Developer', 'Data Analyst'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching jobs: $e')),
      );
      setState(() {
        isSubmit = true;
      });
    } finally {
      loadingIndicator.dismiss();
    }
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
                borderSide: const BorderSide(color: Color(0xFF0F75BC)),
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
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _jobList() {
    final screenWidth = MediaQuery.of(context).size.width;
    debugPrint('Screen Width: $screenWidth');

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
        const Text('Please select up to 3 jobs that suit you'),
        const SizedBox(height: 20),
        jobList.isEmpty
            ? const Center(
          child: Text(
            'No jobs available. Please try again.',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        )
            : Wrap(
          spacing: 8.0, // Reduced spacing
          runSpacing: 8.0,
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
        const SizedBox(height: 20),
        // Display recommended courses
        const Text(
          'Recommended Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F75BC),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Available Width: ${screenWidth - 32}px', // 16px padding on each side
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        recommendedCourses.isEmpty
            ? const Text(
          'No courses recommended yet.',
          style: TextStyle(color: Colors.red, fontSize: 16),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendedCourses.length,
          itemBuilder: (context, index) {
            final semesterData = recommendedCourses[index];
            final semester = semesterData['semester'] as String;
            final courses = semesterData['courses'] as List<dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semester $semester',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0, // Reduced spacing
                  runSpacing: 8.0,
                  children: courses.map((course) {
                    final name = course['name'] as String;
                    final code = course['code'] as String;
                    return _buildCourseCard(name, code);
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        Center(
          child: CustomButton(
            onPressed: selectedJobs.length < 3 ? null : _submitJobs,
            text: 'Submit',
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(String name, String code) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate card width: 45% of available width after padding
    final cardWidth = (screenWidth - 32 - 8) / 2; // 16px padding each side, 8px spacing

    return Container(
      clipBehavior: Clip.antiAlias,
      width: cardWidth.clamp(120, 160), // Dynamic width, clamped for safety
      padding: const EdgeInsets.all(10.0), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13, // Slightly smaller font
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F75BC),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            code,
            style: const TextStyle(
              fontSize: 11, // Slightly smaller font
              color: Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableCard(String job, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 8) / 2; // Match course card width

    return Container(
      width: cardWidth.clamp(120, 160), // Dynamic width
      padding: const EdgeInsets.all(10.0), // Reduced padding
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0F75BC).withOpacity(0.1) : Colors.white,
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
            fontSize: 13,
            color: isSelected ? const Color(0xFF0F75BC) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  Future<void> _submitJobs() async {
    if (selectedJobs.length < 3) return;

    loadingIndicator.show(context);
    try {
      await _runTest();
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
        "courseDetails": recommendedCourses,
      });
      moveToNextScreen(context, const HomeScreen());
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting data: $e')),
      );
    } finally {
      loadingIndicator.dismiss();
    }
  }

  Widget _buildAutocompleteField({
    required String title,
    required List<String> suggestions,
    required List<String> newList,
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
          TypeAheadField<String>(
            controller: controller,
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: (input) {
                  if (input.isNotEmpty && !suggestions.contains(input)) {
                    setState(() {
                      suggestions.add(input);
                      debugPrint('$suggestions');
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF),
                  contentPadding: const EdgeInsets.all(14.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFF0F75BC)),
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
            suggestionsCallback: (pattern) async {
              if (pattern.isEmpty) {
                return [];
              }
              if (!suggestions.contains(pattern)) {
                suggestions.insert(0, pattern);
              }
              final filteredSuggestions = suggestions
                  .where((suggestion) =>
                  suggestion.toLowerCase().contains(pattern.toLowerCase()))
                  .take(5)
                  .toList();
              return filteredSuggestions;
            },
            itemBuilder: (context, String suggestion) {
              return ListTile(title: Text(suggestion));
            },
            onSelected: (String selection) {
              setState(() {
                if (!newList.contains(selection)) {
                  newList.add(selection);
                  controller.clear();
                }
              });
            },
          ),
          _buildChips(newList),
        ],
      ),
    );
  }

  Widget _buildChips(List<String> newList) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: newList.map((item) {
        return Chip(
          label: Text(item),
          deleteIcon: const Icon(Icons.cancel, size: 16, color: Colors.white),
          onDeleted: () {
            setState(() {
              newList.remove(item);
            });
          },
          side: const BorderSide(color: Color(0xFF0F75BC), width: 1),
          backgroundColor: const Color(0xFF0F75BC),
          labelStyle: const TextStyle(color: Colors.white),
        );
      }).toList(),
    );
  }

  Future<void> _runTest() async {
    loadingIndicator.show(context);
    try {
      await runElectiveSelector();
      await setupProcess(selectedJobs, skillsList, preferences).then((value) => {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing recommendations: $e')),
      );
    } finally {
      loadingIndicator.dismiss();
    }
  }

  Future<void> loadJsonFiles() async {
    try {
      final coursesJson = await rootBundle.loadString('assets/jsons/elective_cources.json');
      final creditsJson = await rootBundle.loadString('assets/jsons/semester_credit.json');

      setState(() {
        electiveCourses = List<Map<String, dynamic>>.from(json.decode(coursesJson));
        semesterCreditRequirements = {
          for (var entry in json.decode(creditsJson))
            "${entry['year']}-${entry['semester']}": entry['requiredCredit']
        };
        debugPrint('Elective Courses: $electiveCourses');
        debugPrint('Semester Credits: $semesterCreditRequirements');
      });

      if (electiveCourses.isEmpty || semesterCreditRequirements.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load course data')),
        );
      }
    } catch (e) {
      debugPrint('Error loading JSON files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading course data: $e')),
      );
    }
  }

  Future<void> runElectiveSelector() async {
    if (electiveCourses.isEmpty || semesterCreditRequirements.isEmpty) {
      debugPrint('No course data available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No course data available for recommendations')),
      );
      // Fallback recommendations
      setState(() {
        recommendedCourses = [
          {
            "semester": "2-2",
            "courses": [
              {"code": "PST 22215", "name": "Mathematical Methods"},
              {"code": "PST 22112", "name": "Leadership and Communication"}
            ]
          }
        ];
      });
      return;
    }

    loadingIndicator.show(context);
    try {
      final response = await gemini.text(
        '''
Given the following data:
- Elective courses: ${json.encode(electiveCourses)}
- Required credits per semester: ${json.encode(semesterCreditRequirements)}
- User preferences: ${preferences}
- Desired future jobs: ${selectedJobs}

Select suitable elective courses for each semester, ensuring:
- The total credits match the required credits for each semester.
- Courses are relevant to the user's preferences and future jobs.

Return the answer as a JSON object where keys are "year-semester" (e.g., "2-2") and values are objects mapping course codes to course names. Example:
{"2-2":{"PST 22215":"Mathematical Methods","PST 22112":"Leadership and Communication"},"3-1":{"PST 31230":"Social and Professional Issues in Computing"}}

Ensure the response is valid JSON without markdown or extra text.
''',
      );

      debugPrint('Raw Gemini Response: ${response?.output}');

      if (response?.output != null) {
        String rawResponse = response!.output!.trim();
        rawResponse = rawResponse.replaceAll(RegExp(r'^```json\s*|\s*```$'), '');
        rawResponse = rawResponse.replaceAll(RegExp(r'^```.*\n|\n```$'), '').trim();

        debugPrint('Cleaned Response: $rawResponse');

        try {
          final responseCourses = json.decode(rawResponse);
          if (responseCourses is Map<String, dynamic>) {
            setState(() {
              recommendedCourses.clear();
              responseCourses.forEach((semester, courses) {
                if (courses is Map<String, dynamic>) {
                  Map<String, dynamic> semesterData = {
                    "semester": semester,
                    "courses": courses.entries
                        .map((entry) => {
                      "code": entry.key,
                      "name": entry.value.toString().length > 50
                          ? '${entry.value.toString().substring(0, 47)}...'
                          : entry.value.toString(),
                    })
                        .toList(),
                  };
                  recommendedCourses.add(semesterData);
                }
              });
              debugPrint('Recommended Courses: $recommendedCourses');
            });

            if (recommendedCourses.isEmpty) {
              debugPrint('No valid courses parsed from response');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No valid course recommendations received')),
              );
              setState(() {
                recommendedCourses = [
                  {
                    "semester": "2-2",
                    "courses": [
                      {"code": "PST 22215", "name": "Mathematical Methods"},
                      {"code": "PST 22112", "name": "Leadership and Communication"}
                    ]
                  }
                ];
              });
            }
          } else {
            debugPrint('Response is not a valid JSON map');
            throw FormatException('Invalid JSON format');
          }
        } catch (e) {
          debugPrint('Error decoding response: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing course recommendations: $e')),
          );
          setState(() {
            recommendedCourses = [
              {
                "semester": "2-2",
                "courses": [
                  {"code": "PST 22215", "name": "Mathematical Methods"},
                  {"code": "PST 22112", "name": "Leadership and Communication"}
                ]
              }
            ];
          });
        }
      } else {
        debugPrint('No recommendations received from the server');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No course recommendations received from server')),
        );
        setState(() {
          recommendedCourses = [
            {
              "semester": "2-2",
              "courses": [
                {"code": "PST 22215", "name": "Mathematical Methods"},
                {"code": "PST 22112", "name": "Leadership and Communication"}
              ]
            }
          ];
        });
      }
    } catch (e) {
      debugPrint('Gemini Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching course recommendations: $e')),
      );
      setState(() {
        recommendedCourses = [
          {
            "semester": "2-2",
            "courses": [
              {"code": "PST 22215", "name": "Mathematical Methods"},
              {"code": "PST 22112", "name": "Leadership and Communication"}
            ]
          }
        ];
      });
    } finally {
      loadingIndicator.dismiss();
    }
  }
}