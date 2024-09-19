import 'package:flutter/material.dart';

class HomeScroll extends StatefulWidget {
  const HomeScroll({super.key});

  @override
  State<HomeScroll> createState() => _HomeScrollState();
}

class _HomeScrollState extends State<HomeScroll> {
  @override
  Widget build(BuildContext context) {
    return ContentList();
  }
}

class ContentList extends StatelessWidget {
  final List<Map<String, String>> content = [
    // YouTube videos
    {
      'type': 'video',
      'title': 'Flutter Tutorial for Beginners',
      'channel': 'Code Academy',
      'thumbnailUrl': 'https://img.youtube.com/vi/fq4N0hgOWzU/maxresdefault.jpg',
    },
    {
      'type': 'video',
      'title': 'Top 10 Flutter Widgets',
      'channel': 'Flutter Community',
      'thumbnailUrl': 'https://img.youtube.com/vi/x0uinJvhNxI/maxresdefault.jpg',
    },
    // Medium blogs
    {
      'type': 'blog',
      'title': 'Understanding State Management in Flutter',
      'author': 'John Doe',
      'thumbnailUrl': 'https://picsum.photos/200/300',
      'link': 'https://medium.com/@johndoe/state-management-flutter',
    },
    {
      'type': 'blog',
      'title': 'Building Responsive UIs in Flutter',
      'author': 'Jane Smith',
      'thumbnailUrl': 'https://picsum.photos/200/300',
      'link': 'https://medium.com/@janesmith/responsive-ui-flutter',
    },
    // More YouTube videos
    {
      'type': 'video',
      'title': 'Building a YouTube Clone with Flutter',
      'channel': 'Tech With Tim',
      'thumbnailUrl': 'https://img.youtube.com/vi/1ukSR1GRtMU/maxresdefault.jpg',
    },
    // More Medium blogs
    {
      'type': 'blog',
      'title': 'Best Practices for Writing Clean Code in Flutter',
      'author': 'Alice Johnson',
      'thumbnailUrl': 'https://picsum.photos/200/300',
      'link': 'https://medium.com/@alicejohnson/clean-code-flutter',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: content.length,
      itemBuilder: (context, index) {
        if (content[index]['type'] == 'video') {
          return VideoTile(
            title: content[index]['title']!,
            channel: content[index]['channel']!,
            thumbnailUrl: content[index]['thumbnailUrl']!,
          );
        } else if (content[index]['type'] == 'blog') {
          return BlogTile(
            title: content[index]['title']!,
            author: content[index]['author']!,
            thumbnailUrl: content[index]['thumbnailUrl']!,
            link: content[index]['link']!,
          );
        }
        return const SizedBox.shrink(); // Placeholder for unsupported content types
      },
    );
  }
}

class VideoTile extends StatelessWidget {
  final String title;
  final String channel;
  final String thumbnailUrl;

  VideoTile({
    required this.title,
    required this.channel,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(thumbnailUrl),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            child: Text(channel[0]), // Placeholder avatar with the first letter of the channel
          ),
          title: Text(title),
          subtitle: Text(channel),
        ),
        Divider(),
      ],
    );
  }
}

class BlogTile extends StatelessWidget {
  final String title;
  final String author;
  final String thumbnailUrl;
  final String link;

  BlogTile({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // You can add URL launcher here to open the Medium link
      },
      child: Column(
        children: [
          Image.network(thumbnailUrl),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(author[0]), // Placeholder avatar with the first letter of the author's name
            ),
            title: Text(title),
            subtitle: Text('by $author'),
          ),
          Divider(),
        ],
      ),
    );
  }
}