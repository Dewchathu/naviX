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
    required this.score
  });
}
