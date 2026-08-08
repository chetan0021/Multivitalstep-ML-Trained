import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/notifications_service.dart';

class SetReminderDialogModel extends BaseViewModel {
  final NotificationsService _notificationsService =
      locator<NotificationsService>();
  DateTime? selectedDateTime;
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        rebuildUi();
      }
    }
  }

  getDateAndTime(DateTime? selectedDateTime) {
    // return dd - mm - yyyy hh:mm
    return "${selectedDateTime!.day} - ${selectedDateTime.month} - ${selectedDateTime.year} ${selectedDateTime.hour}:${selectedDateTime.minute}";
  }

  Future<void> setReminder(
      {required Assessment assessment,
      required DateTime selectedDateTime}) async {
    final bool hasPermission =
        await _notificationsService.checkNotificationPermission();
    if (hasPermission) {
      // schedule the notification, to be sent periodically.
      await _notificationsService.scheduleNotifications(
          assessment: assessment, startDateTime: selectedDateTime);
    } else {
      await _notificationsService.requestNotificationPermission();
    }
  }
}
