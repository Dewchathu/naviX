import 'package:cron/cron.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:navix/services/firestore_service.dart';

class FirestoreUpdater {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Gemini gemini = Gemini.instance;
  List<String> threeMonthList = [];
  List<String> oneMonthList = [];
  List<String> oneWeekList = [];
  List<String> dailyVideoList = [];
  String youtubeApiKey = '';
  String userId = '';
  DateTime now = DateTime.now();

  Future<void> updateFirestoreDocument() async {
    // Load .env for YouTube API key
    await dotenv.load(fileName: ".env");
    youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    Map<String, dynamic>? userInfo =
    await FirestoreService().getCurrentUserInfo();
    userId = (await FirestoreService().getCurrentUserId())!;

    threeMonthList = userInfo?['threeMonthList'];
    oneMonthList = userInfo?['oneMonthList'];
    oneWeekList = userInfo?['oneWeekList'];
    dailyVideoList = userInfo?['dailyVideoList'];


    scheduleUpdates();



    // List<String> threeMonthList = await fetchThreeMonthList();
    // List<String> oneMonthList = threeMonthList.isNotEmpty
    //     ? await fetchOneMonthList(threeMonthList.first)
    //     : [];
    // List<String> oneWeekList = oneMonthList.isNotEmpty
    //     ? await fetchOneWeekList(oneMonthList.first)
    //     : [];
    // List<String> dailyVideoList = oneWeekList.isNotEmpty
    //     ? await fetchYouTubeLinks(oneWeekList.first, youtubeApiKey)
    //     : [];

    // Update Firestore document
    await updateFirestore(threeMonthList, oneMonthList, oneWeekList, dailyVideoList);
  }

  Future<List<String>> fetchThreeMonthList() async {
    try {
      Candidates? response = await gemini.text(
        "What are 3 key areas to learn for this user's jobs? Give the answer in plain text and without description. ex: 1. Bloc, 2. Streamer, 3. Stateful",
      );
      return extractListFromResponse(response?.output);
    } catch (e) {
      print('Error fetching Three-Month List: $e');
      return [];
    }
  }

  Future<List<String>> fetchOneMonthList(String topic) async {
    try {
      Candidates? response = await gemini.text(
        "Provide 4 subtopics under the topic '$topic'. Give the answer in plain text and without description. ex: 1. Bloc, 2. Streamer, 3. Stateful",
      );
      return extractListFromResponse(response?.output);
    } catch (e) {
      print('Error fetching One-Month List: $e');
      return [];
    }
  }

  Future<List<String>> fetchOneWeekList(String subtopic) async {
    try {
      Candidates? response = await gemini.text(
        "Provide 7 subcategories under the subtopic '$subtopic'. Give the answer in plain text and without description. ex: 1. Bloc, 2. Streamer, 3. Stateful",
      );
      return extractListFromResponse(response?.output);
    } catch (e) {
      print('Error fetching One-Week List: $e');
      return [];
    }
  }

  Future<List<String>> fetchYouTubeLinks(String topic, String apiKey) async {
    final url = Uri.parse(
        "https://www.googleapis.com/youtube/v3/search?part=snippet&q=$topic&type=video&maxResults=5&key=$apiKey");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['items']
            .map<String>((item) => "https://www.youtube.com/watch?v=${item['id']['videoId']}")
            .toList();
      } else {
        throw Exception('YouTube API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching YouTube links: $e');
      return [];
    }
  }

  Future<void> updateFirestore(List<String> threeMonthList, List<String> oneMonthList,
      List<String> oneWeekList, List<String> dailyVideoList) async {
    try {
      final DocumentReference userDoc = _firestore.collection('users').doc(userId);
      await userDoc.update({
        "threeMonthList": threeMonthList,
        "oneMonthList": oneMonthList,
        "oneWeekList": oneWeekList,
        "dailyVideoList": dailyVideoList,
      });
      print('Firestore document updated successfully!');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  List<String> extractListFromResponse(String? response) {
    if (response == null) return [];
    RegExp regex = RegExp(r"^\d+\.\s+(.*)$", multiLine: true);
    Iterable<RegExpMatch> matches = regex.allMatches(response);
    return matches.map((match) => match.group(1)!.trim()).toList();
  }

  void scheduleUpdates() {
    final cron = Cron();

    // Schedule update every day at 12 AM
    cron.schedule(Schedule.parse('1 36 * * *'), () async {
      print('Updating Firestore at 12 AM');
      int weekday = now.weekday;
      await fetchYouTubeLinks( oneWeekList[weekday], youtubeApiKey);
      //await fetchYouTubeLinks(topic, apiKey);
    });

    // Schedule update every Monday at 12 AM
    cron.schedule(Schedule.parse('0 0 * * 1'), () async {
      print('Updating Firestore every Monday');
      await updateFirestoreData();
    });

    // Schedule update every 1st of the month at 12 AM
    cron.schedule(Schedule.parse('0 0 1 * *'), () async {
      print('Updating Firestore on the 1st of the month');
      await updateFirestoreData();
    });
  }

// Function to update Firestore
  Future<void> updateFirestoreData() async {
    // Your Firestore update logic here
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc('exampleDocId').update({
      'field': 'new value',
    });
    print("Firestore data updated");
  }

}

