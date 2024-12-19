import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, List<String>>> setupProcess(
    List<String> selectedJobs,
    String skills,
    ) async {
  List<String> threeMonthList = [];
  List<String> oneMonthList = [];
  List<String> oneWeekList = [];
  List<String> dailyVideoList = [];
  final gemini = Gemini.instance;

  // Load .env for YouTube API key
  await dotenv.load(fileName: ".env");
  String youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';

  // Step 1: Process Three-Month List
  Candidates? response = await gemini.text(
    "What are 3 key areas to learn in ${selectedJobs} that complement ${skills}? Give the answer in plain text and without description. ex: 1. Bloc, 2. Streamer, 3. Stateful",
  );

  // Debugging the response
  print('Gemini response for Three-Month List: ${response?.output}');
  String? geminiResponse = response?.output;

  if (geminiResponse != null) {
    RegExp regex = RegExp(r"^\d+\.\s+(.*)$", multiLine: true);
    Iterable<RegExpMatch> matches = regex.allMatches(geminiResponse);
    threeMonthList = matches.map((match) => match.group(1)!.trim()).toList();
  }

  print('Three-Month List: $threeMonthList');

  // Step 2: Process One-Month List for the first topic
  if (threeMonthList.isNotEmpty) {
    String topic = threeMonthList.first;
    Candidates? subtopicsResponse = await gemini.text(
      "Provide 4 subtopics without description under the topic '$topic'. Give the answer in plain text and without description. ex: 1. Bloc, 2. Streamer, 3. Stateful",
    );

    print('Gemini response for One-Month List: ${subtopicsResponse?.output}');
    String? geminiSubtopicsResponse = subtopicsResponse?.output;

    if (geminiSubtopicsResponse != null) {
      RegExp regex = RegExp(r"^\d+\.\s+(.*)$", multiLine: true);
      Iterable<RegExpMatch> matches = regex.allMatches(geminiSubtopicsResponse);
      oneMonthList = matches.map((match) => match.group(1)!.trim()).toList();
    }
  }

  print('One-Month List: $oneMonthList');

  // Step 3: Process One-Week List for the first subtopic
  if (oneMonthList.isNotEmpty) {
    String subtopic = oneMonthList.first;
    Candidates? subSubcategoriesResponse = await gemini.text(
      "Provide 7 subcategories under the subtopic '$subtopic'. Give the answer in plain text and without description. ex: 1. Bloc, 2. Streamer, 3. Stateful",
    );

    print('Gemini response for One-Week List: ${subSubcategoriesResponse?.output}');
    String? geminiSubSubcategoriesResponse = subSubcategoriesResponse?.output;

    if (geminiSubSubcategoriesResponse != null) {
      RegExp regex = RegExp(r"^\d+\.\s+(.*)$", multiLine: true);
      Iterable<RegExpMatch> matches = regex.allMatches(geminiSubSubcategoriesResponse);
      oneWeekList = matches.map((match) => match.group(1)!.trim()).toList();
    }
  }

  print('One-Week List: $oneWeekList');

  // Step 4: Generate Daily Video Links for the first topic of the One-Week List
  if (oneWeekList.isNotEmpty) {
    String dailyTopic = oneWeekList.first;
    dailyVideoList = await fetchYouTubeLinks(dailyTopic, youtubeApiKey);
  }

  print('Daily Video List: $dailyVideoList');

  // Return all lists in a map
  return {
    "threeMonthList": threeMonthList,
    "oneMonthList": oneMonthList,
    "oneWeekList": oneWeekList,
    "dailyVideoList": dailyVideoList,
  };
}

// Function to fetch YouTube links
Future<List<String>> fetchYouTubeLinks(String topic, String apiKey) async {
  final url = Uri.parse(
      "https://www.googleapis.com/youtube/v3/search?part=snippet&q=$topic&type=video&maxResults=5&key=$apiKey");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<String> videoLinks = data['items']
        .map<String>((item) => "https://www.youtube.com/watch?v=${item['id']['videoId']}")
        .toList();
    return videoLinks;
  } else {
    throw Exception('Failed to fetch YouTube links');
  }
}
