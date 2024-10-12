import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/video_player_screen.dart';

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
  String videoTitle = 'Loading...'; // Placeholder until the title is fetched
  String videoAuthor = 'Loading...'; // Placeholder until the author is fetched

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl) ?? "",
    )..addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    setState(() {
        videoTitle = _controller.metadata.title;
        videoAuthor = _controller.metadata.author;
      });
    
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChange);
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        moveToNextScreen(
            context, VideoPlayerScreen(videoUrl: widget.videoUrl, title: videoTitle));
      },
      child: Column(
        children: [
          Image.network(
            'https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(widget.videoUrl)}/hqdefault.jpg',
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                  videoAuthor.isNotEmpty ? videoAuthor[0] : 'A'), // First letter of author or a default
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
