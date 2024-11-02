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
  String videoTitle = 'Loading...';
  String videoAuthor = 'Loading...';

  @override
  void initState() {
    super.initState();
    String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false, // Disable autoplay
        ),
      )..addListener(_checkMetadataReady);
    }
  }

  void _checkMetadataReady() {
    if (_controller.value.isReady && mounted) {
      setState(() {
        videoTitle = _controller.metadata.title.isNotEmpty
            ? _controller.metadata.title
            : "Unknown Title";
        videoAuthor = _controller.metadata.author.isNotEmpty
            ? _controller.metadata.author
            : "Unknown Author";
      });
      _controller.removeListener(_checkMetadataReady); // Remove listener after fetching metadata
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkMetadataReady);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        moveToNextScreen(
          context,
          VideoPlayerScreen(videoUrl: widget.videoUrl, title: videoTitle),
        );
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
