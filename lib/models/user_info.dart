class UserInfo {
  final String name;
  final String email;
  final String academicYear;
  final String graduationYear;
  final List<String> skills;
  final List<String> preferences;
  final List<String> jobList;
  final List<String> reqSkills;
  final List<Map<String, dynamic>> courseDetails;
  final String profileUrl;

  UserInfo({
    required this.name,
    required this.email,
    required this.academicYear,
    required this.graduationYear,
    required this.skills,
    required this.preferences,
    required this.jobList,
    required this.reqSkills,
    required this.courseDetails,
    required this.profileUrl,
  });
}
