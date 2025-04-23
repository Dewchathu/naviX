import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/info_messages.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a user to Firestore
  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) async {
    try {
      // Ensure learnerType is set for new users
      userInfoMap['learnerType'] = userInfoMap['learnerType'] ?? 'slow';
      await _firestore.collection("User").doc(userId).set(userInfoMap);
      showToast('User added successfully');
    } catch (e) {
      showToast('Error adding user: $e');
    }
  }

  // Method to get current user information along with course details
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      String? userId = await getCurrentUserId();
      if (userId != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await _firestore.collection('User').doc(userId).get();

        if (snapshot.exists) {
          return snapshot.data();
        } else {
          showToast('User document not found');
          return null;
        }
      } else {
        showToast('User ID not found');
        return null;
      }
    } catch (e) {
      showToast('Request Denied: $e');
      return null;
    }
  }

  // Method to update user information
  Future<void> updateUserInfo(Map<String, dynamic> updatedInfoJson) async {
    try {
      String? userId = await getCurrentUserId();
      if (userId != null) {
        await _firestore
            .collection('User')
            .doc(userId)
            .set(updatedInfoJson, SetOptions(merge: true));
        showToast('Profile updated successfully');
      } else {
        showToast('User ID not found');
      }
    } catch (e) {
      showToast('Request Denied: $e');
    }
  }

  // Method to get the current user ID
  Future<String?> getCurrentUserId() async {
    return await AuthService().getCurrentUserId();
  }

  // Get all user info
  Stream<List<Map<String, dynamic>>> fetchAllUsers() {
    return FirebaseFirestore.instance
        .collection('User')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "name": doc["name"],
          "score": doc["score"],
          "dailyStreak": doc["dailyStreak"],
          "profileUrl": doc["profileUrl"],
          "learnerType": doc["learnerType"] ?? 'slow',
        };
      }).toList();
    });
  }

  // Update user rank
  Future<void> updateUserRank(List<Map<String, dynamic>> users) async {
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      await FirebaseFirestore.instance
          .collection('User')
          .doc(user['id'])
          .update({
        'rank': i + 1,
      });
    }
  }
}
