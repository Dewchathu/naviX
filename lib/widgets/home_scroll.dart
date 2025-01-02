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

  @override
  void initState() {
    super.initState();
    dailyVideoList = (widget.user?.dailyVideoList as List<String>?) ?? [];
    weekTopic = (widget.user?.email)!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F75BC),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(weekTopic,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold
                    ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          // Properly constrain the ListView
          child: dailyVideoList.isNotEmpty
              ? ListView.builder(
                  itemCount: dailyVideoList.length,
                  itemBuilder: (context, index) {
                    return VideoTile(
                      videoUrl: dailyVideoList[index],
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
