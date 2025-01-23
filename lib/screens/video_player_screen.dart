import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:navix/services/youtube_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String videoScript;
  final int score;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
    required this.videoScript,
    required this.score,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int scoreUp = 0;
  List<int> _checkpoints = [];
  int _currentCheckpointIndex = 0;
  String youtubeApiKey = '';
  bool _isInitialized = false;
  DateTime? lastScoreUpdateDate;
  int dailyScore = 0;


  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    await _loadApi();

    String videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? "";
    scoreUp = widget.score;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(_listener);

    // Fetch video duration and set checkpoints
    try {
      final durationInSeconds = await YouTubeService().fetchVideoDuration(videoId, youtubeApiKey);
      _checkpoints = [
        (durationInSeconds * 0.25).toInt(),
        (durationInSeconds * 0.50).toInt(),
        (durationInSeconds * 0.75).toInt(),
        durationInSeconds,
      ];
      debugPrint('Checkpoints: $_checkpoints');
    } catch (e) {
      debugPrint('Failed to fetch video duration: $e');
      showToast('Failed to load video duration');
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadApi() async{
    await dotenv.load(fileName: ".env");
    youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  }

  // Listener to track video position
  void _listener() {
    if (_isPlayerReady && mounted) {
      final currentPosition = _controller.value.position.inSeconds;

      if (_currentCheckpointIndex < _checkpoints.length &&
          currentPosition >= _checkpoints[_currentCheckpointIndex]) {
        final today = DateTime.now();

        if (lastScoreUpdateDate == null ||
            today.difference(lastScoreUpdateDate!).inDays > 0) {
          dailyScore = 0; // Reset daily score
          lastScoreUpdateDate = today;
        }

        setState(() {
          scoreUp += 5;
          dailyScore += 5;
          updateUserScore(scoreUp);
        });
        if (dailyScore >= 15) {
          updateLastActiveDate();
        }

        _currentCheckpointIndex++;
      }

      setState(() {});
    }
  }



  Future<void> updateLastActiveDate() async {
    try {
      String? userId = await FirestoreService().getCurrentUserId();
      if (userId != null) {
        final userDoc = await _firestore.collection('User').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          final lastActiveDate = data['lastActiveDate']?.toDate();
          final currentStreak = data['dailyStreak'] ?? 0;
          final today = DateTime.now();
          int newStreak = 1; // Default to 1 if no streak exists

          if (lastActiveDate != null) {
            final difference = today.difference(lastActiveDate).inDays;

            if (difference == 1) {
              // Continue streak
              newStreak = currentStreak + 1;
            } else if (difference > 1) {
              // Reset streak if missed a day
              newStreak = 1;
            }
          }

          // Update Firestore
          await _firestore.collection('User').doc(userId).set({
            'lastActiveDate': Timestamp.fromDate(today),
            'dailyStreak': newStreak,
          }, SetOptions(merge: true));

          showToast('Streak updated successfully! Current streak: $newStreak');
        } else {
          // Initialize user data if document doesn't exist
          await _firestore.collection('User').doc(userId).set({
            'lastActiveDate': Timestamp.now(),
            'dailyStreak': 1,
          });

          showToast('Streak started! Current streak: 1');
        }
      } else {
        showToast('User ID not found');
      }
    } catch (e) {
      showToast('Failed to update streak: $e');
    }
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> updateUserScore(int newScore) async {
    try {
      String? userId = await FirestoreService().getCurrentUserId();
      if (userId != null) {
        Map<String, dynamic> updatedInfoJson = {
          'score': newScore,
        };
        // Update the user's profile in Firestore with the new score
        await _firestore.collection('User').doc(userId).set(updatedInfoJson, SetOptions(merge: true));

        // Notify the user that the score was updated
        showToast('5 Points Collected');
      } else {
        showToast('User ID not found');
      }
    } catch (e) {
      showToast('Request Denied: $e');
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_isInitialized)
            IconButton(
              icon: Icon(
                _controller.value.isFullScreen
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen,
              ),
              onPressed: () {
                _controller.toggleFullScreenMode();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _isInitialized
            ? YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blue,
            progressColors: const ProgressBarColors(
              playedColor: Colors.blue,
              handleColor: Colors.blueAccent,
            ),
            onReady: () {
              _isPlayerReady = true;
            },
          ),
          builder: (context, player) {
            return Column(
              children: [
                // Youtube Player
                player,

                // Video Script Section
                if (widget.videoScript.isNotEmpty && !_controller.value.isFullScreen)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            "Video Description",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.videoScript,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        )
            : const Center(child: CircularProgressIndicator()), // Show loading indicator
      ),
    );
  }
}
