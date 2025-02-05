import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:navix/services/firestore_service.dart';

class Leaderboard extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Leader Board 🏆',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F75BC)),
            ),
            const SizedBox(height: 15),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.fetchAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: LoadingIndicator(
                        indicatorType: Indicator.lineSpinFadeLoader,
                        colors: [Colors.blue],
                        strokeWidth: 1,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading data"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data available"));
                } else {
                  final users = snapshot.data!;
                  if (users.isNotEmpty) {
                    users.sort((a, b) => b['score'].compareTo(a['score']));
                    _firestoreService.updateUserRank(users);
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user["profileUrl"] != null &&
                                    Uri.tryParse(user["profileUrl"])
                                            ?.hasAbsolutePath ==
                                        true
                                ? NetworkImage(user["profileUrl"])
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: user["profileUrl"] == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            user["name"] ?? "Unknown",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            "Points: ${user["score"] ?? 0}, Streak: ${user["dailyStreak"] ?? 0} 🔥",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          trailing: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? Colors.yellow[700] // Gold for 1st
                                  : index == 1
                                      ? Colors.grey[400] // Silver for 2nd
                                      : index == 2
                                          ? Colors.brown[400] // Bronze for 3rd
                                          : Colors
                                              .blueAccent, // Default for others
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "#${index + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
