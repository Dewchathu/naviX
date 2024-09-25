import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/info_messages.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a user to Firestore
  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) async {
    try {
      await _firestore.collection("User").doc(userId).set(userInfoMap);
      showToast('User added successfully');
    } catch (e) {
      showToast('Error adding user: $e');
    }
  }

  // Method to get current user information
  Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserInfo() async {
    try {
      String? userId = await getCurrentUserId();
      if (userId != null) {
        return await _firestore.collection('User').doc(userId).get();
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
        await _firestore.collection('User').doc(userId).set(updatedInfoJson, SetOptions(merge: true));
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
}
