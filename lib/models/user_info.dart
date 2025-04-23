import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final String name;
  final String email;
  final String academicYear;
  final String graduationYear;
  final List<String> skills;
  final List<String> preferences;
  final List<String> jobList;
  final List<Map<String, dynamic>> courseDetails;
  final String profileUrl;
  final List<String> dailyVideoList;
  final DateTime initDate;
  final List<String> oneWeekList;
  final int dailyStreak;
  final int score;
  final DateTime lastActiveDate;
  final String learnerType;

  UserInfo({
    required this.name,
    required this.email,
    required this.academicYear,
    required this.graduationYear,
    required this.skills,
    required this.preferences,
    required this.jobList,
    required this.courseDetails,
    required this.profileUrl,
    required this.dailyVideoList,
    required this.initDate,
    required this.oneWeekList,
    required this.dailyStreak,
    required this.lastActiveDate,
    required this.score,
    required this.learnerType,
  });

  // Convert UserInfo to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'academicYear': academicYear,
      'graduationYear': graduationYear,
      'skills': skills,
      'preferences': preferences,
      'jobList': jobList,
      'courseDetails': courseDetails,
      'profileUrl': profileUrl,
      'dailyVideoList': dailyVideoList,
      'initDate': Timestamp.fromDate(initDate),
      'oneWeekList': oneWeekList,
      'dailyStreak': dailyStreak,
      'score': score,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'learnerType': learnerType,
    };
  }

  // Create UserInfo from Firestore data
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      academicYear: json['academicYear'] ?? '',
      graduationYear: json['graduationYear'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      preferences: List<String>.from(json['preferences'] ?? []),
      jobList: List<String>.from(json['jobList'] ?? []),
      courseDetails:
          List<Map<String, dynamic>>.from(json['courseDetails'] ?? []),
      profileUrl: json['profileUrl'] ?? '',
      dailyVideoList: List<String>.from(json['dailyVideoList'] ?? []),
      initDate: (json['initDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      oneWeekList: List<String>.from(json['oneWeekList'] ?? []),
      dailyStreak: json['dailyStreak'] ?? 0,
      score: json['score'] ?? 0,
      lastActiveDate:
          (json['lastActiveDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      learnerType: json['learnerType'] ?? 'slow',
    );
  }
}
