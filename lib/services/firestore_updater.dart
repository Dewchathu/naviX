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
    await dotenv.load(fileName: ".env");
    youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    Map<String, dynamic>? userInfo = await FirestoreService().getCurrentUserInfo();
    userId = (await FirestoreService().getCurrentUserId())!;

    threeMonthList = (userInfo?['threeMonthList'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    oneMonthList = (userInfo?['oneMonthList'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    oneWeekList = (userInfo?['oneWeekList'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    dailyVideoList = (userInfo?['dailyVideoList'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    // Fetch timestamps from Firestore
    DocumentSnapshot userDoc = await _firestore.collection('User').doc(userId).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    DateTime? lastDailyUpdate = (userData?['lastDailyUpdate'] as Timestamp?)?.toDate();
    DateTime? lastWeeklyUpdate = (userData?['lastWeeklyUpdate'] as Timestamp?)?.toDate();
    DateTime? lastMonthlyUpdate = (userData?['lastMonthlyUpdate'] as Timestamp?)?.toDate();

    DateTime now = DateTime.now();

    // Initialize timestamps if missing
    if (lastDailyUpdate == null) lastDailyUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    if (lastWeeklyUpdate == null) lastWeeklyUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    if (lastMonthlyUpdate == null) lastMonthlyUpdate = DateTime.fromMillisecondsSinceEpoch(0);

    bool isSameDay = lastDailyUpdate.year == now.year &&
        lastDailyUpdate.month == now.month &&
        lastDailyUpdate.day == now.day;

    bool isSameWeek = lastWeeklyUpdate.year == now.year &&
        now.difference(lastWeeklyUpdate).inDays < 7;

    bool isSameMonth = lastMonthlyUpdate.year == now.year &&
        lastMonthlyUpdate.month == now.month;

    // Update dailyVideoList if not updated today
    if (!isSameDay && oneWeekList.isNotEmpty) {
      dailyVideoList = await fetchYouTubeLinks(oneWeekList[now.weekday - 1], youtubeApiKey);
      await _firestore.collection('User').doc(userId).update({'lastDailyUpdate': Timestamp.fromDate(now)});
    }

    // Update oneWeekList if not updated this week
    if (!isSameWeek && oneMonthList.isNotEmpty) {
      int weekOfMonth = ((now.day - 1) ~/ 7) + 1;
      oneWeekList = await fetchOneWeekList(oneMonthList[weekOfMonth - 1]);
      await _firestore.collection('User').doc(userId).update({'lastWeeklyUpdate': Timestamp.fromDate(now)});
    }

    // Update oneMonthList if not updated this month
    if (!isSameMonth && threeMonthList.isNotEmpty) {
      oneMonthList = await fetchOneMonthList(threeMonthList[(now.month - 1) % 3]);
      await _firestore.collection('User').doc(userId).update({'lastMonthlyUpdate': Timestamp.fromDate(now)});
    }

    // Update Firestore document with lists
    await updateFirestore(oneMonthList, oneWeekList, dailyVideoList);
    print('Firestore updated successfully on app open!');
  }


  //
  // Future<List<String>> fetchThreeMonthList() async {
  //   try {
  //     Candidates? response = await gemini.text(
  //       "What are 3 key areas to learn for this user's jobs? Give the answer in plain text and without description. ex: 1. Bloc, 2. Streamer, 3. Stateful",
  //     );
  //     return extractListFromResponse(response?.output);
  //   } catch (e) {
  //     print('Error fetching Three-Month List: $e');
  //     return [];
  //   }
  // }

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
            .map<String>((
            item) => "https://www.youtube.com/watch?v=${item['id']['videoId']}")
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
      List<String> oneWeekList, List<String> dailyVideoList) async {
    try {
      final DocumentReference userDoc = _firestore.collection('User').doc(
          userId);
      await userDoc.update({
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

}
