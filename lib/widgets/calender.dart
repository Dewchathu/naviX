import 'package:flutter/material.dart';
import 'package:navix/models/user_info.dart';
import 'package:navix/services/notification_service.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Calender extends StatefulWidget {
  final UserInfo? user;
  const Calender({super.key, required this.user});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime initDate = DateTime.now();
  final NotificationService notificationService = NotificationService();
  List<Appointment> appointments = [];
  List<String> oneWeekList = [];
  RandomColor _randomColor = RandomColor();

  @override
  void initState() {
    super.initState();
    // Initialize timezone for Colombo
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));
    if (widget.user != null) {
      initDate = widget.user!.initDate;
      oneWeekList = widget.user!.oneWeekList;
      notificationService.init();
    }
    _scheduleWeeklyTasks();
  }

  void _scheduleWeeklyTasks() {
    // Get current time in Colombo timezone
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Ensure the week starts on Monday at midnight
    tz.TZDateTime monday = tz.TZDateTime(tz.local, now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < oneWeekList.length; i++) {
      // Schedule task for each day at 7:00 AM explicitly
      tz.TZDateTime taskTime = tz.TZDateTime(
        tz.local,
        monday.year,
        monday.month,
        monday.day + i, // Add days for each task
        21, // Hour
        10, // Minute
        0, // Second
      );

      Appointment appointment = Appointment(
        startTime: taskTime,
        endTime: taskTime.add(const Duration(minutes: 60)),
        subject: oneWeekList[i],
        color: _randomColor.randomColor(
          colorBrightness: ColorBrightness.random,
        ),
      );

      appointments.add(appointment);

      // Schedule notification for each appointment
      notificationService.scheduleNotification(
        taskTime.hashCode, // Unique ID
        oneWeekList[i],
        'Your task "${oneWeekList[i]}" is scheduled for $taskTime',
        taskTime.subtract(const Duration(minutes: 2)),
      );
    }

    // Update the state to refresh the calendar
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.month,
      showNavigationArrow: true,
      showDatePickerButton: true,
      showTodayButton: true,
      monthViewSettings: const MonthViewSettings(showAgenda: true),
      dataSource: _AppointmentDataSource(appointments),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
