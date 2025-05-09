import 'package:flutter/material.dart';
import 'package:navix/models/user_info.dart';
import 'package:navix/widgets/video_tile.dart';

class HomeScroll extends StatefulWidget {
  final UserInfo? user;
  const HomeScroll({super.key, this.user});

  @override
  State<HomeScroll> createState() => _HomeScrollState();
}

class _HomeScrollState extends State<HomeScroll> {
  List<String> dailyVideoList = [];
  String weekTopic = '';
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    dailyVideoList = widget.user?.dailyVideoList ?? [];
    weekTopic = (widget.user?.oneWeekList[now.weekday - 1]) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F75BC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    weekTopic.isNotEmpty ? weekTopic : 'No Topic',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: dailyVideoList.isNotEmpty
              ? ListView.builder(
                  itemCount: dailyVideoList.length,
                  itemBuilder: (context, index) {
                    return VideoTile(
                      videoUrl: dailyVideoList[index],
                      score: widget.user!.score,
                    );
                  },
                )
              : const Center(
                  child: Text('No videos available'),
                ),
        ),
      ],
    );
  }
}
