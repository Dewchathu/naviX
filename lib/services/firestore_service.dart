import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class FirestoreService{
  Future addUser(String userId, Map<String, dynamic> userInfoMap){
    return FirebaseFirestore.instance.collection("User").doc(userId).set(userInfoMap);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserInfo() async{
    try{
      return FirebaseFirestore.instance.collection('User').doc(await getCurrentUserId()).get();
    } catch(e){

      //showToast('Request Denied');
      return null;
    }
  }
  getCurrentUserId() async{
    return await AuthService().getCurrentUserId();
  }
}