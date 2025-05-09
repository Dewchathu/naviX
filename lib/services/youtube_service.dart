import 'dart:convert';

import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;

class YouTubeService {
  final Gemini gemini = Gemini.instance;

  Future<int> fetchVideoDuration(String videoId, String apiKey) async {
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=$videoId&key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final duration = data['items'][0]['contentDetails']['duration'];
      return parseDuration(duration);
    } else {
      throw Exception('Failed to load video data: ${response.statusCode}');
    }
  }

  int parseDuration(String iso8601Duration) {
    final regex = RegExp(r'PT(\d+H)?(\d+M)?(\d+S)?');
    final match = regex.firstMatch(iso8601Duration);

    int hours = 0, minutes = 0, seconds = 0;

    if (match != null) {
      final hourMatch = match.group(1);
      if (hourMatch != null) {
        hours = int.parse(hourMatch.replaceAll('H', ''));
      }

      final minuteMatch = match.group(2);
      if (minuteMatch != null) {
        minutes = int.parse(minuteMatch.replaceAll('M', ''));
      }

      final secondMatch = match.group(3);
      if (secondMatch != null) {
        seconds = int.parse(secondMatch.replaceAll('S', ''));
      }
    }

    return (hours * 3600) + (minutes * 60) + seconds;
  }
}
