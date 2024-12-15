import 'package:flutter/material.dart';
import 'package:navix/models/user_info.dart';
import 'package:navix/services/notification_service.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      initDate = widget.user!.initDate;
      notificationService.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.month,
      showNavigationArrow: true,
      showDatePickerButton: true,
      showTodayButton: true,
      monthViewSettings: const MonthViewSettings(showAgenda: true),
      dataSource: _getCalendarDataSource(initDate, notificationService),
    );
  }
}

_AppointmentDataSource _getCalendarDataSource(
    DateTime initDate, NotificationService notificationService) {
  List<Appointment> appointments = <Appointment>[];

  // Define appointment details in a list
  List<Map<String, dynamic>> appointmentData = [
    {
      'days': 0,
      'hours': 0,
      'subject': 'Meeting with Team',
      'color': Colors.blue,
      'duration': 30,
    },
    {
      'days': 2,
      'hours': 3,
      'subject': 'Project Discussion',
      'color': Colors.green,
      'duration': 60,
    },
    {
      'days': 3,
      'hours': 5,
      'subject': 'Client Presentation',
      'color': Colors.purple,
      'duration': 60,
    },
    {
      'days': 7,
      'hours': 1,
      'subject': 'Code Review',
      'color': Colors.orange,
      'duration': 60,
    },
    {
      'days': 10,
      'hours': 4,
      'subject': 'Product Launch',
      'color': Colors.red,
      'duration': 60,
    },
  ];

  // Add appointments in a loop
  for (var data in appointmentData) {
    appointments.add(
      Appointment(
        startTime: initDate.add(Duration(days: data['days'], hours: data['hours'])),
        endTime: initDate.add(Duration(days: data['days'], hours: data['hours'], minutes: data['duration'])),
        subject: data['subject'],
        color: data['color'],
      ),
    );
  }

  // Schedule notification for each appointment
  for (var appointment in appointments) {
    notificationService.scheduleNotification(
      appointment.startTime.hashCode, // Unique ID
      appointment.subject,
      'Your appointment is scheduled for ${appointment.startTime}',
      appointment.startTime.subtract(const Duration(minutes: 30)),
    );
  }

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
