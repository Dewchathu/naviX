import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/video_player_screen.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoTile extends StatefulWidget {
  final String videoUrl;

  const VideoTile({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  _VideoTileState createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  late YoutubePlayerController _controller;
  String videoTitle = 'Loading...';
  String videoAuthor = 'Loading...';
  String videoThumbnailUrl = 'Loading...';
  bool isLoading = true;
  String youtubeApiKey = '';


  @override
  void initState() {
    super.initState();
    _fetchVideoDetails();
  }

  // Fetch YouTube video details using YouTube API
  Future<void> _fetchVideoDetails() async {
    String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    await dotenv.load(fileName: ".env");
    youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';

    if (videoId != null) {
      final apiKey = youtubeApiKey;
      final url =
      Uri.parse('https://www.googleapis.com/youtube/v3/videos?part=snippet&id=$videoId&key=$apiKey');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final snippet = data['items'][0]['snippet'];
          setState(() {
            videoTitle = snippet['title'] ?? 'Unknown Title';
            videoAuthor = snippet['channelTitle'] ?? 'Unknown Author';
            videoThumbnailUrl = snippet['thumbnails']['high']['url'] ?? '';
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load video details');
        }
      } catch (e) {
        setState(() {
          videoTitle = 'Error loading video';
          videoAuthor = 'Error loading author';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (mounted) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isLoading) {
          moveToNextScreen(
            context,
            VideoPlayerScreen(videoUrl: widget.videoUrl, title: videoTitle),
          );
        }
      },
      child: Column(
        children: [
          isLoading
              ? const CircularProgressIndicator() // Show a loading indicator while fetching data
              : Image.network(videoThumbnailUrl),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                videoAuthor.isNotEmpty ? videoAuthor[0] : 'A',
              ), // First letter of author
            ),
            title: Text(videoTitle),
            subtitle: Text(videoAuthor),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
