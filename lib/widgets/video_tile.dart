import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_indicator/loading_indicator.dart';
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
      final url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/videos?part=snippet&id=$videoId&key=$apiKey');

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
            // Initialize the YoutubePlayerController
            _controller = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
            );
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
    if (_controller != null) {
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
      child: isLoading
          ? Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container()
      )
          : Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(3, 3)
              ),
            ],
          ),
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    videoThumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      videoTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F75BC),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      videoAuthor,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
