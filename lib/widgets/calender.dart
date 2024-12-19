import 'package:flutter/material.dart';
import 'package:navix/models/user_info.dart';
import 'package:navix/services/notification_service.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
    if (widget.user != null) {
      initDate = widget.user!.initDate;
      oneWeekList = widget.user!.oneWeekList;
      notificationService.init();
    }
    _scheduleWeeklyTasks();
  }

  void _scheduleWeeklyTasks() {
    // Ensure the week starts on the current week's Monday
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday-1));

    for (int i = 0; i < oneWeekList.length; i++) {
      DateTime taskTime = monday.add(Duration(days: i, hours: 7));

      Appointment appointment = Appointment(
        startTime: taskTime,
        endTime: taskTime.add(const Duration(minutes: 60)),
        subject: oneWeekList[i],
        color: _randomColor.randomColor(
            colorBrightness: ColorBrightness.light
        ),
      );

      appointments.add(appointment);

      // Schedule notification for each appointment
      notificationService.scheduleNotification(
        taskTime.hashCode, // Unique ID
        oneWeekList[i],
        'Your task "${oneWeekList[i]}" is scheduled for $taskTime',
        taskTime.subtract(const Duration(minutes: 30)),
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
