// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/add_comment/add_comment_dialog.dart';
import '../ui/dialogs/add_patient/add_patient_dialog.dart';
import '../ui/dialogs/create_assessment/create_assessment_dialog.dart';
import '../ui/dialogs/create_test/create_test_dialog.dart';
import '../ui/dialogs/info_alert/info_alert_dialog.dart';
import '../ui/dialogs/reset_password/reset_password_dialog.dart';
import '../ui/dialogs/set_reminder/set_reminder_dialog.dart';

enum DialogType {
  infoAlert,
  createTest,
  setReminder,
  resetPassword,
  addPatient,
  createAssessment,
  addComment,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.infoAlert: (context, request, completer) =>
        InfoAlertDialog(request: request, completer: completer),
    DialogType.createTest: (context, request, completer) =>
        CreateTestDialog(request: request, completer: completer),
    DialogType.setReminder: (context, request, completer) =>
        SetReminderDialog(request: request, completer: completer),
    DialogType.resetPassword: (context, request, completer) =>
        ResetPasswordDialog(request: request, completer: completer),
    DialogType.addPatient: (context, request, completer) =>
        AddPatientDialog(request: request, completer: completer),
    DialogType.createAssessment: (context, request, completer) =>
        CreateAssessmentDialog(request: request, completer: completer),
    DialogType.addComment: (context, request, completer) =>
        AddCommentDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
