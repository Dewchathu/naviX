import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:navix/services/youtube_service.dart';
import 'package:provider/provider.dart';
import 'package:youtube_caption_scraper/youtube_caption_scraper.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../providers/streak_provider.dart';
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
  final captionScraper = YouTubeCaptionScraper();
  int scoreUp = 0;
  List<int> _checkpoints = [];
  int _currentCheckpointIndex = 0;
  String youtubeApiKey = '';
  bool _isInitialized = false;
  DateTime? lastScoreUpdateDate;
  int dailyScore = 0;
  bool _questionAsked = false;
  String subtitleText = '';
  bool _isQuestionAnswered = false;
  String? _selectedAnswer;
  List<String> _mcqOptions = [];
  String _correctAnswer = '';

  final gemini = Gemini.instance;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    await _loadApi();

    String videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? "";

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

    try {
      final durationInSeconds =
          await YouTubeService().fetchVideoDuration(videoId, youtubeApiKey);
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

  Future<void> _loadApi() async {
    await dotenv.load(fileName: ".env");
    youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  }

  void _listener() {
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);

    if (_isPlayerReady && mounted) {
      final currentPosition = _controller.value.position.inSeconds;

      if (_currentCheckpointIndex < _checkpoints.length &&
          currentPosition >= _checkpoints[_currentCheckpointIndex]) {
        if (_currentCheckpointIndex == 0 && !_questionAsked) {
          _controller.pause();
          _loadSubtitles(_checkpoints[_currentCheckpointIndex]).then((_) {
            _generateQuestion(subtitleText);
          });
          _questionAsked = true;
        } else if (_isQuestionAnswered || _currentCheckpointIndex > 0) {
          final today = DateTime.now();

          if (lastScoreUpdateDate == null ||
              today.difference(lastScoreUpdateDate!).inDays > 0) {
            dailyScore = 0;
            lastScoreUpdateDate = today;
          }

          setState(() {
            scoreUp += 5;
            dailyScore += 5;
            updateUserScore(scoreUp);
          });

          if (dailyScore >= 15) {
            streakProvider.updateStreak();
          }

          _currentCheckpointIndex++;
        }
      }

      setState(() {});
    }
  }

  Future<void> _loadSubtitles(int position) async {
    try {
      final captionTracks =
          await captionScraper.getCaptionTracks(widget.videoUrl);
      if (captionTracks.isNotEmpty) {
        final subtitles = await captionScraper.getSubtitles(captionTracks[0]);

        String closestSubtitle = "";
        int closestTimeDiff = 999999;
        for (final subtitle in subtitles) {
          int timeDiff = (subtitle.start.inSeconds - position).abs();
          if (timeDiff < closestTimeDiff) {
            closestTimeDiff = timeDiff;
            closestSubtitle = subtitle.text;
          }
        }

        setState(() {
          subtitleText = closestSubtitle;
        });

        debugPrint("Extracted subtitle: $subtitleText");
      }
    } catch (e) {
      debugPrint("Error loading subtitles: $e");
    }
  }

  Future<void> _generateQuestion(String caption) async {
    if (caption.isEmpty) {
      debugPrint("No subtitle found, resuming video.");
      setState(() {
        _isQuestionAnswered = true;
      });
      _controller.play();
      return;
    }

    try {
      final response = await gemini.text(
        "Based on this subtitle: '$caption', generate a multiple-choice question with 4 options, where only one is correct. Provide the question, options, and indicate the correct answer. Format the response as follows:\n"
        "Question: [Your question here]\n"
        "A: [Option A]\n"
        "B: [Option B]\n"
        "C: [Option C]\n"
        "D: [Option D]\n"
        "Correct: [A/B/C/D]",
      );

      if (response?.output != null) {
        final lines = response!.output!.split('\n');
        String question = '';
        List<String> options = [];
        String correct = '';

        for (var line in lines) {
          line = line.trim();
          if (line.startsWith('Question:')) {
            question = line.substring(9).trim();
          } else if (line.startsWith('A:') ||
              line.startsWith('B:') ||
              line.startsWith('C:') ||
              line.startsWith('D:')) {
            options.add(line.substring(2).trim());
          } else if (line.startsWith('Correct:')) {
            correct = line.substring(8).trim();
          }
        }

        if (question.isNotEmpty && options.length == 4 && correct.isNotEmpty) {
          setState(() {
            _mcqOptions = [question, ...options];
            _correctAnswer = options[['A', 'B', 'C', 'D'].indexOf(correct)];
          });
          _showQuestionDialog();
        } else {
          debugPrint("Invalid question format, resuming video.");
          setState(() {
            _isQuestionAnswered = true;
          });
          _controller.play();
        }
      } else {
        debugPrint("No response from Gemini, resuming video.");
        setState(() {
          _isQuestionAnswered = true;
        });
        _controller.play();
      }
    } catch (e) {
      debugPrint('Error generating question: $e');
      setState(() {
        _isQuestionAnswered = true;
      });
      _controller.play();
    }
  }

  void _showQuestionDialog() {
    String? localSelectedAnswer; // Local state for dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Question'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_mcqOptions[0]), // Question
                  const SizedBox(height: 10),
                  RadioListTile<String>(
                    title: Text(_mcqOptions[1]),
                    value: _mcqOptions[1],
                    groupValue: localSelectedAnswer,
                    onChanged: (value) {
                      setDialogState(() {
                        localSelectedAnswer = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(_mcqOptions[2]),
                    value: _mcqOptions[2],
                    groupValue: localSelectedAnswer,
                    onChanged: (value) {
                      setDialogState(() {
                        localSelectedAnswer = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(_mcqOptions[3]),
                    value: _mcqOptions[3],
                    groupValue: localSelectedAnswer,
                    onChanged: (value) {
                      setDialogState(() {
                        localSelectedAnswer = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(_mcqOptions[4]),
                    value: _mcqOptions[4],
                    groupValue: localSelectedAnswer,
                    onChanged: (value) {
                      setDialogState(() {
                        localSelectedAnswer = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            StatefulBuilder(
              // Wrap the actions in a separate StatefulBuilder
              builder: (BuildContext context, StateSetter setActionState) {
                return ElevatedButton(
                  onPressed: localSelectedAnswer == null
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswer = localSelectedAnswer;
                            bool isCorrect = _selectedAnswer == _correctAnswer;
                            showToast(isCorrect
                                ? 'Correct! +5 Points'
                                : 'Incorrect. Try again next time!');
                            if (isCorrect) {
                              scoreUp += 5;
                              dailyScore += 5;
                              updateUserScore(scoreUp);
                            }
                            _isQuestionAnswered = true;
                          });
                          Navigator.of(context).pop();
                          _controller.play();
                        },
                  child: const Text('Submit'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserScore(int newScore) async {
    try {
      String? userId = await FirestoreService().getCurrentUserId();
      if (userId != null) {
        Map<String, dynamic> updatedInfoJson = {
          'score': newScore,
        };
        await _firestore
            .collection('User')
            .doc(userId)
            .set(updatedInfoJson, SetOptions(merge: true));
        showToast('Points Updated');
      } else {
        showToast('User ID not found');
      }
    } catch (e) {
      showToast('Request Denied: $e');
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                      player,
                      if (widget.videoScript.isNotEmpty &&
                          !_controller.value.isFullScreen)
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),
                                const Text(
                                  "Video Description",
                                  style: TextStyle(
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
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
