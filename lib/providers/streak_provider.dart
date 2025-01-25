import 'package:flutter/material.dart';
import 'package:navix/services/streak_service.dart';

class StreakProvider with ChangeNotifier {
  final StreakService _streakService = StreakService();
  Map<String, dynamic> _streak = {};

  Map<String, dynamic> get streak => _streak;

  Future<void> loadStreak() async {
    _streak = await _streakService.getUserStreakInfo();
    notifyListeners();
  }

  Future<void> updateStreak() async {
    await _streakService.updateLastActiveDate();
    await loadStreak();
  }
}
