import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:vital_step/ui/views/password_reset_view/password_reset_view_view.form.dart';

class PasswordResetViewViewModel extends FormViewModel {
  String selectedUserType = 'Patient';
  final key = GlobalKey<FormState>();
  final String resettingPassword = "resetPassword";
  final _apiCallsService = locator<ApiCallsService>();
  Future<void> resetPassword() async {
    setBusyForObject(resettingPassword, true);
    if (emailValue == null || emailValue!.isEmpty) {
      Fluttertoast.showToast(
          msg: "The email can not be null or empty. Please re-enter. ");
    } else {
      await _apiCallsService.sendResetPasswordEmail(
          email: emailValue!, userType: selectedUserType);
    }
    setBusyForObject(resettingPassword, false);
  }
}
