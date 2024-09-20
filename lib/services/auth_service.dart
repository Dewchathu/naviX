import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:navix/actions/move_to_next_sceen.dart';
import 'package:navix/screens/home.dart';

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
  Future<User?> createUserWithEmailAndPassword(String email,
      String password) async {
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
  Future<User?> loginUserWithEmailAndPassword(String email,
      String password) async {
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

  // Google Sign-In method
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        final User? userDetails = userCredential.user;

        if (userDetails != null) {
          Map<String, dynamic> userInfoMap = {
            "email": userDetails.email,
            "name": userDetails.displayName,
            "id": userDetails.uid,
            "phone": userDetails.phoneNumber,
            "address": '',
            "profileUrl": userDetails.photoURL,
          };

          // Add user details to Firestore
          await FirestoreService().addUser(userDetails.uid, userInfoMap);

          // Navigate to home screen or initial screen
          moveToNextScreen(context, const HomeScreen());
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
