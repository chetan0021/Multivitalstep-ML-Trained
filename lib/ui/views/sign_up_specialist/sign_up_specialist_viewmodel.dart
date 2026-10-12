import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/spcialist_profile.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/services/specialist_service.dart';
import 'package:vital_step/ui/common/FormValidators.dart';
import 'package:vital_step/ui/views/sign_up_specialist/sign_up_specialist_view.form.dart';

class SignUpSpecialistViewModel extends FormViewModel {
  final formKey = GlobalKey<FormState>();
  bool passwordVisible = true;
  TextEditingController viewDobController = TextEditingController();
  final _logger = getLogger("SignUpSpecialistViewModel");
  void setDOB(BuildContext context) async {
    await selectDob(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 75)),
        initialDate: DateTime.now(),
        lastDate: DateTime.now());
    try {
      String dateOfBirth = DateFormat("dd-MM-yyyy").format(dobValue!);
      viewDobController.text = dateOfBirth;
      rebuildUi();
    } catch (e) {
      _logger.e(e);
    }
  }

  final _dialogService = locator<DialogService>();
  final _specialistService = locator<SpecialistService>();
  Future<void> saveData({required bool update}) async {
    setBusy(true);
    if (!formKey.currentState!.validate()) {
      _logger.e("Form Fields are not valid");
      Fluttertoast.showToast(msg: "Please check the form once again");
    } else if (FormValidators.nameValidator(nameValue) != null) {
      final message = FormValidators.nameValidator(nameValue);
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Invalid name',
          description: message);
    } else if (FormValidators.mobileNumberValidator(mobileNumberValue) !=
        null) {
      final message = FormValidators.mobileNumberValidator(mobileNumberValue);
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Invalid mobile Number',
          description: message);
    } else if (FormValidators.emailValidator(emailValue) != null) {
      final message = FormValidators.emailValidator(emailValue);
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Invalid name',
          description: message);
    } else if (update == false &&
        FormValidators.passwordValidator(passwordValue) != null) {
      final message = FormValidators.passwordValidator(passwordValue);
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Invalid name',
          description: message);
    } else if (viewDobController.text.isEmpty ||
        FormValidators.dobValidator(
                DateFormat("dd-MM-yyyy").parse(viewDobController.text)) !=
            null) {
      final message = viewDobController.text.isEmpty
          ? "Date of birth can not be empty"
          : FormValidators.dobValidator(
              DateFormat("dd-MM-yyyy").parse(viewDobController.text));
      _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Invalid Date of Birth',
          description: message);
    } else if (FormValidators.mobileNumberValidator(mobileNumberValue) !=
        null) {
      final message = FormValidators.mobileNumberValidator(mobileNumberValue);
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Something wrong with phone number',
        description: message,
      );
    } else {
      try {
        ProfileSpecialist signUpInfo = ProfileSpecialist(
            name: nameValue!,
            phone: int.parse(mobileNumberValue!),
            email: emailValue!,
            password: passwordValue!,
            dob: viewDobController.text,
            city: cityValue,
            country: countryValue,
            pincode: int.tryParse(pincodeValue!),
            countryCode: countryCodeDropDownValue ?? "+91");

        _logger.i("SignUpInfo to json ${signUpInfo.toJson()}");
        _logger.i("Form is valid");
        if (update) {
          await _specialistService.updateProfile(signUpInfo);
        } else {
          await _specialistService.signUp(
            signUpInfo,
          );
        }
      } catch (e) {
        _logger.e(e);
        _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Something went wrong',
          description: e.toString(),
        );
      }
    }
    setBusy(false);
  }

  void setProfile(ProfileSpecialist profile) {
    nameValue = profile.name;
    setCountryCodeDropDown(profile.countryCode);
    mobileNumberValue = profile.phone.toString();
    emailValue = profile.email;
    cityValue = profile.city;
    pincodeValue = profile.pincode == null ? "" : profile.pincode.toString();
    countryValue = profile.country;
    viewDobController.text =
        DateFormat("dd-MM-yyyy").format(DateTime.parse(profile.dob));
  }
}
