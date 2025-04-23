import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
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
  String learnerType = 'slow'; // Default to slow learner
  DateTime now = DateTime.now();

  Future<void> updateFirestoreDocument() async {
    await dotenv.load(fileName: ".env");
    youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    Map<String, dynamic>? userInfo =
        await FirestoreService().getCurrentUserInfo();
    userId = (await FirestoreService().getCurrentUserId())!;

    threeMonthList = (userInfo?['threeMonthList'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    oneMonthList = (userInfo?['oneMonthList'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    oneWeekList = (userInfo?['oneWeekList'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    dailyVideoList = (userInfo?['dailyVideoList'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    learnerType = userInfo?['learnerType'] ?? 'slow';

    // Determine learner type based on score
    int score = userInfo?['score'] ?? 0;
    int dailyStreak = userInfo?['dailyStreak'] ?? 0;
    learnerType = _assignLearnerType(score, dailyStreak);

    // Fetch timestamps from Firestore
    DocumentSnapshot userDoc =
        await _firestore.collection('User').doc(userId).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    DateTime? lastDailyUpdate =
        (userData?['lastDailyUpdate'] as Timestamp?)?.toDate();
    DateTime? lastWeeklyUpdate =
        (userData?['lastWeeklyUpdate'] as Timestamp?)?.toDate();
    DateTime? lastMonthlyUpdate =
        (userData?['lastMonthlyUpdate'] as Timestamp?)?.toDate();

    DateTime now = DateTime.now();

    // Initialize timestamps if missing
    if (lastDailyUpdate == null)
      lastDailyUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    if (lastWeeklyUpdate == null)
      lastWeeklyUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    if (lastMonthlyUpdate == null)
      lastMonthlyUpdate = DateTime.fromMillisecondsSinceEpoch(0);

    bool isSameDay = lastDailyUpdate.year == now.year &&
        lastDailyUpdate.month == now.month &&
        lastDailyUpdate.day == now.day;

    bool isSameWeek = lastWeeklyUpdate.year == now.year &&
        now.difference(lastWeeklyUpdate).inDays < 7;

    bool isSameMonth = lastMonthlyUpdate.year == now.year &&
        lastMonthlyUpdate.month == now.month;

    // Update oneMonthList if not updated this month
    if (!isSameMonth && threeMonthList.isNotEmpty) {
      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      int weeksInMonth = (daysInMonth / 7).ceil();

      oneMonthList = await fetchOneMonthList(
          threeMonthList[(now.month - 1) % 3], weeksInMonth);
      await _firestore
          .collection('User')
          .doc(userId)
          .update({'lastMonthlyUpdate': Timestamp.fromDate(now)});
    }

    // Update oneWeekList if not updated this week
    if (!isSameWeek && oneMonthList.isNotEmpty) {
      int weekOfMonth = ((now.day - 1) ~/ 7) + 1;
      oneWeekList = await fetchOneWeekList(
          oneMonthList[weekOfMonth - 1], threeMonthList[(now.month - 1) % 3]);
      await _firestore
          .collection('User')
          .doc(userId)
          .update({'lastWeeklyUpdate': Timestamp.fromDate(now)});
    }

    // Update dailyVideoList if not updated today
    if (!isSameDay && oneWeekList.isNotEmpty) {
      int weekOfMonth = ((now.day - 1) ~/ 7) + 1;
      dailyVideoList = await fetchYouTubeLinks(
        oneWeekList[now.weekday - 1],
        youtubeApiKey,
        oneMonthList[weekOfMonth - 1],
        learnerType,
      );
      await _firestore.collection('User').doc(userId).update({
        'lastDailyUpdate': Timestamp.fromDate(now),
        'dailyVideoList': dailyVideoList,
        'learnerType': learnerType,
      });
    }

    // Update Firestore document with lists
    await updateFirestore(
        oneMonthList, oneWeekList, dailyVideoList, learnerType);
    print('Firestore updated successfully on app open!');
  }

  String _assignLearnerType(int score, int dailyStreak) {
    // Example criterion: Fast learner if score >= 100 or dailyStreak >= 7
    if (score >= 100 || dailyStreak >= 7) {
      return 'fast';
    }
    return 'slow';
  }

  Future<List<String>> fetchOneMonthList(String topic, int weekCount) async {
    try {
      Candidates? response = await gemini.text(
        "Provide $weekCount subtopics under the topic '$topic'. Give the answer in plain text and without description. ex: 1. Bloc, 2. Streamer, 3. Stateful",
      );
      return extractListFromResponse(response?.output);
    } catch (e) {
      print('Error fetching One-Month List: $e');
      return [];
    }
  }

  Future<List<String>> fetchOneWeekList(String subtopic, String topic) async {
    try {
      Candidates? response = await gemini.text(
        "Provide 7 subcategories under the subtopic '$subtopic' with '$subtopic related to '$topic'. Give the answer in plain text and without description. ex: 1. '$topic' '$subtopic' Bloc, 2. '$topic' '$subtopic' Streamer, 3. '$topic' '$subtopic' Stateful",
      );
      return extractListFromResponse(response?.output);
    } catch (e) {
      print('Error fetching One-Week List: $e');
      return [];
    }
  }

  Future<List<String>> fetchYouTubeLinks(
      String topic, String apiKey, String mainTopic, String learnerType) async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year - 1, 1, 1).toUtc().toIso8601String();
    String newTopic = '$mainTopic $topic';
    int maxResults = learnerType == 'fast' ? 10 : 5;

    final url = Uri.parse(
      "https://www.googleapis.com/youtube/v3/search"
      "?part=snippet&q=$newTopic&type=video&maxResults=$maxResults&key=$apiKey&publishedAfter=$startOfYear",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['items']
            .map<String>(
              (item) =>
                  "https://www.youtube.com/watch?v=${item['id']['videoId']}",
            )
            .toList();
      } else {
        throw Exception('YouTube API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching YouTube links: $e');
      return [];
    }
  }

  Future<void> updateFirestore(
    List<String> oneMonthList,
    List<String> oneWeekList,
    List<String> dailyVideoList,
    String learnerType,
  ) async {
    try {
      final DocumentReference userDoc =
          _firestore.collection('User').doc(userId);
      await userDoc.update({
        "oneMonthList": oneMonthList,
        "oneWeekList": oneWeekList,
        "dailyVideoList": dailyVideoList,
        "learnerType": learnerType,
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
}
