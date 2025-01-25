import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:navix/services/auth_service.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  String? userId;

  Future<void> updateLastActiveDate() async {
    try {
      userId = await _auth.getCurrentUserId();

      final userDoc = await _firestore.collection('User').doc(userId).get();
      final today = DateTime.now();
      int newStreak = 1; // Default to 1 if no streak exists

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final lastActiveDate = data['lastActiveDate']?.toDate();
        final currentStreak = data['dailyStreak'] ?? 0;

        if (lastActiveDate != null) {
          final difference = today.difference(lastActiveDate).inDays;

          if (difference == 1) {
            // Continue streak
            newStreak = currentStreak + 1;
          } else if (difference > 1) {
            // Reset streak if missed a day
            newStreak = 1;
          }
        }
      }

      // Update Firestore
      await _firestore.collection('User').doc(userId).set({
        'lastActiveDate': Timestamp.fromDate(today),
        'dailyStreak': newStreak,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update streak: $e');
    }
  }


  Future<Map<String, dynamic>> getUserStreakInfo() async {
    try {
      userId = await _auth.getCurrentUserId();

      final userDoc = await _firestore.collection('User').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        int dailyStreak = data['dailyStreak'] ?? 0;
        Timestamp lastActiveTimestamp = data['lastActiveDate'] ?? Timestamp.now();
        DateTime lastActiveDate = lastActiveTimestamp.toDate();

        return {
          'dailyStreak': dailyStreak,
          'lastActiveDate': lastActiveDate,
        };
      }
      return {
        'dailyStreak': 0,
        'lastActiveDate': DateTime.now(),
      };
    } catch (e) {
      debugPrint('Failed to fetch streak and last active date: $e');
      return {
        'dailyStreak': 0,
        'lastActiveDate': DateTime.now(),
      };
    }
  }

}
