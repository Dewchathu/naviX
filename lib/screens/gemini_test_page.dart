import 'package:flutter/material.dart';
import 'package:navix/widgets/loading_indicator.dart';

import '../widgets/setup_process.dart';

class GeminiTestPage extends StatefulWidget {
  const GeminiTestPage({super.key});

  @override
  State<GeminiTestPage> createState() => _GeminiTestPageState();
}

class _GeminiTestPageState extends State<GeminiTestPage> {
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _selectedJobsController = TextEditingController();

  List<String> threeMonthList = [];
  List<String> oneMonthList = [];
  List<String> oneWeekList = [];
  List<String> dailyVideoList = [];

  Future<void> _runTest() async {
    loadingIndicator.show(context);
    try {
      // Get selected jobs and skills
      List<String> selectedJobs =
          _selectedJobsController.text.split(',').map((e) => e.trim()).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Test Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Skills and Selected Jobs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Skills',
                hintText: 'Enter skills, e.g., Dart, Figma',
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
                onPressed: _runTest,
                child: const Text('Run Test'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Three-Month List:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            threeMonthList.isNotEmpty
                ? Column(
                    children:
                        threeMonthList.map((item) => Text('- $item')).toList())
                : const Text('No data available'),
            const SizedBox(height: 16),
            const Text(
              'One-Month List:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            oneMonthList.isNotEmpty
                ? Column(
                    children:
                        oneMonthList.map((item) => Text('- $item')).toList())
                : const Text('No data available'),
            const SizedBox(height: 16),
            const Text(
              'One-Week List:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            oneWeekList.isNotEmpty
                ? Column(
                    children:
                        oneWeekList.map((item) => Text('- $item')).toList())
                : const Text('No data available'),
            const SizedBox(height: 16),
            const Text(
              'Daily Video Links:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            dailyVideoList.isNotEmpty
                ? Column(
                    children:
                        dailyVideoList.map((link) => Text('- $link')).toList())
                : const Text('No data available'),
          ],
        ),
      ),
    );
  }
}
