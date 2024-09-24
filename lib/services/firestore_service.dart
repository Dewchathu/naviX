import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/info_messages.dart';
import 'auth_service.dart';

class FirestoreService{

  Future addUser(String userId, Map<String, dynamic> userInfoMap){
    return FirebaseFirestore.instance.collection("User").doc(userId).set(userInfoMap);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserInfo() async{
    try{
      return FirebaseFirestore.instance.collection('User').doc(await getCurrentUserId()).get();
    } catch(e){
      showToast('Request Denied');
      return null;
    }
  }

  Future<void> updateUserInfo(Map<String, dynamic> updatedInfoJson) async {
    try {
      String userId = await getCurrentUserId(); // Get the user ID first
      await FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .set(updatedInfoJson, SetOptions(merge: true)); // Await the set() call
      showToast('Profile updated successfully'); // Optional success message
    } catch (e) {
      showToast('Request Denied: $e'); // Display error message with reason
    }
  }


  getCurrentUserId() async{
    return await AuthService().getCurrentUserId();
  }

}