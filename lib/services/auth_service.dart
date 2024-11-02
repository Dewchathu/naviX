import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navix/screens/home.dart';

import '../screens/onboard_screen.dart';
import '../widgets/info_messages.dart'; // Assuming you have this widget
import 'firestore_service.dart'; // Firestore service to handle Firestore operations

class AuthService {
  final _auth = FirebaseAuth.instance;

  // Get current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Get current user ID
  String? getCurrentUserId() {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      showToast("Oops! Something went wrong.");
      return null;
    }
  }

  // Create a new user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      showToast("Failed to create account.");
      debugPrint("Error: $e");
    }
    return null;
  }

  // Login with email and password
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      showToast("Login failed.");
      debugPrint("Error: $e");
    }
    return null;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? userDetails = userCredential.user;

        if (userDetails != null) {
          // Check if the user already exists in Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userDetails.uid)
              .get();

          if (!userDoc.exists) {
            // If user is new, initialize fields with default values
            Map<String, dynamic> userInfoMap = {
              "name": userDetails.displayName ?? "",
              "email": userDetails.email ?? "",
              "academicYear": null,
              "graduationYear": null,
              "preferences": [],
              "skills": [],
              "profileUrl": userDetails.photoURL ?? "",
              "courseDetails": [
                {
                  "courseCode": "PHY11211",
                  "courseName": "Physics",
                  "semester": "1st Year 2nd Semester"
                },
                {
                  "courseCode": "CHE11210",
                  "courseName": "Chemistry",
                  "semester": "1st Year 2nd Semester"
                }
              ],
              "reqSkills": [],
              "jobList": [],
              "dailyVideoList": [],
              "initDate": DateTime.now(),
            };

            // Add user details to Firestore for the first time
            await FirestoreService().addUser(userDetails.uid, userInfoMap);

            // Navigate to OnBoardScreen for new users
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnBoardScreen()),
            );
          } else {
            // If user already exists, navigate to HomeScreen
            debugPrint('User already exists, not overwriting existing data.');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          showToast('User authentication failed.');
        }
      } else {
        showToast('Google sign-in was canceled.');
      }
    } catch (e) {
      showToast('Error signing in with Google.');
      debugPrint('Error signing in with Google: $e');
    }
  }


  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showToast('Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast("User not found!");
      } else {
        showToast("Oops! Something went wrong.");
      }
    } catch (e) {
      showToast("Oops! Something went wrong.");
      debugPrint('Error: $e');
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      showToast('Signed out successfully.');
    } catch (e) {
      showToast('Error signing out.');
      debugPrint("Error: $e");
    }
  }
}
