import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:timezone/timezone.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/app/app.router.dart';

class NotificationsService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // ignore: unused_field
  final _logger = getLogger('NotificationsService');

  /// Check if the app has permission to send notifications
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isGranted) return true;
    return false;
  }

  /// Request permission to send notifications
  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: 'Please enable notifications in settings');
      openAppSettings();
    }
    if (await Permission.notification.request().isGranted) {
      Fluttertoast.showToast(msg: "Notification permission granted");
    }
  }

  Future<void> scheduleNotifications(
      {required Assessment assessment, required DateTime startDateTime}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "${assessment.type} Test Completion Reminder",
        "Please complete your ${assessment.type} test",
        scheduleDate(schedule: assessment.type, startDate: startDateTime),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'Schedule Notification ', 'Scheduled notification channel name',
              channelDescription:
                  'This notification is for the user to take test on a fixed schedule set by the user '),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
    Fluttertoast.showToast(msg: "Notification Scheduled Successfully");
  }

  tz.TZDateTime scheduleDate(
      {required String schedule, required DateTime startDate}) {
    ScheduleFrequency frequency;
    // _logger.d('Scheduling notification for $schedule');
    switch (schedule.toLowerCase()) {
      case 'daily':
        frequency = ScheduleFrequency.daily;
        break;
      case 'weekly':
        frequency = ScheduleFrequency.weekly;
        break;
      case 'monthly':
        frequency = ScheduleFrequency.monthly;
        break;
      default:
        throw ArgumentError('Invalid schedule frequency: $schedule');
    }

    initializeDatabase([]);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(startDate, tz.local);

    switch (frequency) {
      case ScheduleFrequency.daily:
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        break;
      case ScheduleFrequency.weekly:
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }
        break;
      case ScheduleFrequency.monthly:
        while (scheduledDate.isBefore(now)) {
          scheduledDate = tz.TZDateTime(
            tz.local,
            scheduledDate.year,
            scheduledDate.month + 1,
            scheduledDate.day,
            scheduledDate.hour,
            scheduledDate.minute,
          );
        }
        break;
    }

    return scheduledDate;
  }

  Future<void> clearAllFutureNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> sendNotificationInSomeTime() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        5,
        'Test Notification Title',
        'Test notification body, this will open the assessment screen',
        notificationDetails,
        payload: 'item x');
  }

  Future<void> handleNotification() async {
    await StackedService.navigatorKey?.currentState
        ?.pushNamed(Routes.assesmentView);
    // NavigationService().navigateToAssesmentView();
  }
}

// define a schedule frequency enum, daily, weekly, monthly type
enum ScheduleFrequency {
  daily,
  weekly,
  monthly,
}
