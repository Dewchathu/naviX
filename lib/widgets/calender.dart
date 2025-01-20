import 'package:flutter/material.dart';
import 'package:navix/models/user_info.dart';
import 'package:navix/services/notification_service.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
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
    if (widget.user != null) {
      initDate = widget.user!.initDate;
      oneWeekList = widget.user!.oneWeekList;
      notificationService.init();
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
          .copyWith(hour: 19, minute: 0 , second: 0);

      // Add the task as an appointment
      Appointment appointment = Appointment(
        startTime: taskTime,
        endTime: taskTime.add(const Duration(minutes: 60)),
        subject: oneWeekList[i],
        color: _randomColor.randomColor(
          colorBrightness: ColorBrightness.random,
        ),
      );
      appointments.add(appointment);

      // Only schedule notifications for today's task
      if (taskTime.day == now.day && taskTime.month == now.month && taskTime.year == now.year) {
        tz.TZDateTime scheduledTime =
        _convertToTZDateTime(taskTime.subtract(const Duration(minutes: 2)));

        notificationService.scheduleNotification(
          taskTime.hashCode,
          oneWeekList[i],
          'Your task "${oneWeekList[i]}" is scheduled for ${taskTime.hour}:${taskTime.minute}',
          scheduledTime,
        );
      }
    }

    setState(() {});
  }


  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.getLocation('Asia/Colombo'); // Set your desired timezone
    return tz.TZDateTime.from(dateTime, location);
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
