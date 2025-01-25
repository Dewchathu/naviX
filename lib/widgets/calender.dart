import 'package:flutter/material.dart';
import 'package:navix/models/user_info.dart';
import 'package:navix/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../providers/streak_provider.dart';

class Calendar extends StatefulWidget {
  final UserInfo? user;
  const Calendar({super.key, required this.user});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime initDate = DateTime.now();
  final NotificationService notificationService = NotificationService();
  List<Appointment> appointments = [];
  List<String> oneWeekList = [];

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      initDate = widget.user!.initDate;
      oneWeekList = widget.user!.oneWeekList;
      notificationService.init();

      // Use listen: false to avoid rebuilding the widget
      Future.delayed(Duration.zero, () {
        Provider.of<StreakProvider>(context, listen: false).loadStreak();
      });
    }

    _scheduleWeeklyTasks();
  }


  void _scheduleWeeklyTasks() {
    DateTime now = DateTime.now();
    DateTime monday = now
        .subtract(Duration(days: now.weekday - 1))
        .copyWith(hour: 0, minute: 0, second: 0);

    for (int i = 0; i < oneWeekList.length; i++) {
      DateTime taskTime = monday
          .add(Duration(days: i))
          .copyWith(hour: 19, minute: 0, second: 0);

      // Assign color based on streak
      Color taskColor = const Color(0xFF0F75BC);

      // Add the task as an appointment
      Appointment appointment = Appointment(
        startTime: taskTime,
        endTime: taskTime.add(const Duration(minutes: 60)),
        subject: oneWeekList[i],
        color: taskColor,
      );
      appointments.add(appointment);
    }

    setState(() {});
  }

  bool _isDateInStreak(DateTime date) {
    final streakProvider = Provider.of<StreakProvider>(context);

    // Get values from the streak
    int dailyStreak = streakProvider.streak['dailyStreak'] ?? 0;
    DateTime? lastActiveDate = streakProvider.streak['lastActiveDate'];

    // If lastActiveDate is null or dailyStreak is 0, return false
    if (dailyStreak == 0 || lastActiveDate == null) return false;

    // Calculate streak start date
    DateTime streakStartDate = lastActiveDate.subtract(Duration(days: dailyStreak - 1));

    return date.isAfter(streakStartDate.subtract(const Duration(days: 1))) &&
        date.isBefore(lastActiveDate.add(const Duration(days: 0)));
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SfCalendar(
        view: CalendarView.month,
        showNavigationArrow: true,
        showDatePickerButton: true,
        showTodayButton: true,
        monthCellBuilder: (BuildContext context, MonthCellDetails details) {
          bool isInStreak = _isDateInStreak(details.date);

          return Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isInStreak ? Colors.orange : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  details.date.day.toString(),
                  style: TextStyle(
                    fontWeight: isInStreak ? FontWeight.bold : FontWeight.normal,
                    color: isInStreak ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
        monthViewSettings: const MonthViewSettings(showAgenda: true),
        dataSource: _AppointmentDataSource(appointments),
        headerStyle: const CalendarHeaderStyle(
          backgroundColor: Color(0xFF0F75BC),
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

extension DateTimeCopyWith on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}

