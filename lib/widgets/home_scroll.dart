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

  @override
  void initState() {
    super.initState();
    setState(() {
      dailyVideoList = (widget.user?.dailyVideoList as List<String>?) ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dailyVideoList.length,
      itemBuilder: (context, index) {
        // ignore: unnecessary_null_comparison
        if (dailyVideoList != null || dailyVideoList.isEmpty) {
          return VideoTile(
            videoUrl: dailyVideoList[index],
          );
        }
        return const SizedBox
            .shrink(); // Placeholder for unsupported content types
      },
    );
  }
}
