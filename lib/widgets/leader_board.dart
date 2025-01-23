import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Leaderboard extends StatelessWidget {
  Stream<List<Map<String, dynamic>>> fetchAllUsers() {
    return FirebaseFirestore.instance.collection('User').snapshots().map(
          (snapshot) =>
          snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Leader Board 🏆',
            style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              color: Color(0xFF0F75BC)
            ),
          ),
          const SizedBox(height: 15),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error loading data"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No data available"));
              } else {
                final users = snapshot.data!;
                if (users.isNotEmpty) {
                  users.sort((a, b) => b['score'].compareTo(a['score']));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user["profileUrl"] != null &&
                              Uri.tryParse(user["profileUrl"])?.hasAbsolutePath == true
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
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
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
                                : Colors.blueAccent, // Default for others
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
    );
  }
}
