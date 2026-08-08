// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/FormValidators.dart';

const bool _autoTextFieldValidation = true;

const String NameValueKey = 'name';
const String MobileNumberValueKey = 'mobileNumber';
const String EmailValueKey = 'email';
const String PasswordValueKey = 'password';
const String DobValueKey = 'dob';
const String CityValueKey = 'city';
const String CountryValueKey = 'country';
const String PincodeValueKey = 'pincode';
const String CountryCodeDropDownValueKey = 'countryCodeDropDown';

final Map<String, String> CountryCodeDropDownValueToTitleMap = {
  '+91': '+91',
  '+1': '+1',
  '+44': '+44',
  '+61': '+61',
  '+86': '+86',
  '+81': '+81',
  '+49': '+49',
  '+33': '+33',
  '+34': '+34',
  '+39': '+39',
  '+7': '+7',
  '+55': '+55',
  '+27': '+27',
  '+64': '+64',
  '+971': '+971',
  '+82': '+82',
  '+52': '+52',
  '+60': '+60',
  '+46': '+46',
  '+45': '+45',
  '+47': '+47',
  '+65': '+65',
  '+66': '+66',
  '+48': '+48',
  '+353': '+353',
  '+358': '+358',
  '+90': '+90',
  '+32': '+32',
  '+351': '+351',
  '+40': '+40',
  '+48': '+48',
  '+31': '+31',
  '+61': '+61',
  '+64': '+64',
  '+30': '+30',
  '+41': '+41',
  '+56': '+56',
  '+47': '+47',
  '+351': '+351',
  '+380': '+380',
  '+354': '+354',
  '+233': '+233',
  '+234': '+234',
  '+237': '+237',
  '+254': '+254',
  '+255': '+255',
  '+256': '+256',
  '+234': '+234',
  '+971': '+971',
};

final Map<String, TextEditingController>
    _SignUpSpecialistViewTextEditingControllers = {};

final Map<String, FocusNode> _SignUpSpecialistViewFocusNodes = {};

final Map<String, String? Function(String?)?>
    _SignUpSpecialistViewTextValidations = {
  NameValueKey: FormValidators.nameValidator,
  MobileNumberValueKey: FormValidators.mobileNumberValidator,
  EmailValueKey: FormValidators.emailValidator,
  PasswordValueKey: FormValidators.passwordValidator,
  CityValueKey: null,
  CountryValueKey: null,
  PincodeValueKey: null,
};

mixin $SignUpSpecialistView {
  TextEditingController get nameController =>
      _getFormTextEditingController(NameValueKey);
  TextEditingController get mobileNumberController =>
      _getFormTextEditingController(MobileNumberValueKey);
  TextEditingController get emailController =>
      _getFormTextEditingController(EmailValueKey);
  TextEditingController get passwordController =>
      _getFormTextEditingController(PasswordValueKey);
  TextEditingController get cityController =>
      _getFormTextEditingController(CityValueKey);
  TextEditingController get countryController =>
      _getFormTextEditingController(CountryValueKey);
  TextEditingController get pincodeController =>
      _getFormTextEditingController(PincodeValueKey);

  FocusNode get nameFocusNode => _getFormFocusNode(NameValueKey);
  FocusNode get mobileNumberFocusNode =>
      _getFormFocusNode(MobileNumberValueKey);
  FocusNode get emailFocusNode => _getFormFocusNode(EmailValueKey);
  FocusNode get passwordFocusNode => _getFormFocusNode(PasswordValueKey);
  FocusNode get cityFocusNode => _getFormFocusNode(CityValueKey);
  FocusNode get countryFocusNode => _getFormFocusNode(CountryValueKey);
  FocusNode get pincodeFocusNode => _getFormFocusNode(PincodeValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_SignUpSpecialistViewTextEditingControllers.containsKey(key)) {
      return _SignUpSpecialistViewTextEditingControllers[key]!;
    }

    _SignUpSpecialistViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _SignUpSpecialistViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_SignUpSpecialistViewFocusNodes.containsKey(key)) {
      return _SignUpSpecialistViewFocusNodes[key]!;
    }
    _SignUpSpecialistViewFocusNodes[key] = FocusNode();
    return _SignUpSpecialistViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    nameController.addListener(() => _updateFormData(model));
    mobileNumberController.addListener(() => _updateFormData(model));
    emailController.addListener(() => _updateFormData(model));
    passwordController.addListener(() => _updateFormData(model));
    cityController.addListener(() => _updateFormData(model));
    countryController.addListener(() => _updateFormData(model));
    pincodeController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    nameController.addListener(() => _updateFormData(model));
    mobileNumberController.addListener(() => _updateFormData(model));
    emailController.addListener(() => _updateFormData(model));
    passwordController.addListener(() => _updateFormData(model));
    cityController.addListener(() => _updateFormData(model));
    countryController.addListener(() => _updateFormData(model));
    pincodeController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          NameValueKey: nameController.text,
          MobileNumberValueKey: mobileNumberController.text,
          EmailValueKey: emailController.text,
          PasswordValueKey: passwordController.text,
          CityValueKey: cityController.text,
          CountryValueKey: countryController.text,
          PincodeValueKey: pincodeController.text,
        }),
    );

    if (_autoTextFieldValidation || forceValidate) {
      updateValidationData(model);
    }
  }

  bool validateFormFields(FormViewModel model) {
    _updateFormData(model, forceValidate: true);
    return model.isFormValid;
  }

  /// Calls dispose on all the generated controllers and focus nodes
  void disposeForm() {
    // The dispose function for a TextEditingController sets all listeners to null

    for (var controller in _SignUpSpecialistViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _SignUpSpecialistViewFocusNodes.values) {
      focusNode.dispose();
    }

    _SignUpSpecialistViewTextEditingControllers.clear();
    _SignUpSpecialistViewFocusNodes.clear();
  }
}

extension ValueProperties on FormStateHelper {
  bool get hasAnyValidationMessage => this
      .fieldsValidationMessages
      .values
      .any((validation) => validation != null);

  bool get isFormValid {
    if (!_autoTextFieldValidation) this.validateForm();

    return !hasAnyValidationMessage;
  }

  String? get nameValue => this.formValueMap[NameValueKey] as String?;
  String? get mobileNumberValue =>
      this.formValueMap[MobileNumberValueKey] as String?;
  String? get emailValue => this.formValueMap[EmailValueKey] as String?;
  String? get passwordValue => this.formValueMap[PasswordValueKey] as String?;
  DateTime? get dobValue => this.formValueMap[DobValueKey] as DateTime?;
  String? get cityValue => this.formValueMap[CityValueKey] as String?;
  String? get countryValue => this.formValueMap[CountryValueKey] as String?;
  String? get pincodeValue => this.formValueMap[PincodeValueKey] as String?;
  String? get countryCodeDropDownValue =>
      this.formValueMap[CountryCodeDropDownValueKey] as String?;

  set nameValue(String? value) {
    this.setData(
      this.formValueMap..addAll({NameValueKey: value}),
    );

    if (_SignUpSpecialistViewTextEditingControllers.containsKey(NameValueKey)) {
      _SignUpSpecialistViewTextEditingControllers[NameValueKey]?.text =
          value ?? '';
    }
  }

  set mobileNumberValue(String? value) {
    this.setData(
      this.formValueMap..addAll({MobileNumberValueKey: value}),
    );

    if (_SignUpSpecialistViewTextEditingControllers.containsKey(
        MobileNumberValueKey)) {
      _SignUpSpecialistViewTextEditingControllers[MobileNumberValueKey]?.text =
          value ?? '';
    }
  }

  set emailValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmailValueKey: value}),
    );

    if (_SignUpSpecialistViewTextEditingControllers.containsKey(
        EmailValueKey)) {
      _SignUpSpecialistViewTextEditingControllers[EmailValueKey]?.text =
          value ?? '';
    }
  }

  set passwordValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PasswordValueKey: value}),
    );

    if (_SignUpSpecialistViewTextEditingControllers.containsKey(
        PasswordValueKey)) {
      _SignUpSpecialistViewTextEditingControllers[PasswordValueKey]?.text =
          value ?? '';
    }
  }

  set cityValue(String? value) {
    this.setData(
      this.formValueMap..addAll({CityValueKey: value}),
    );

    if (_SignUpSpecialistViewTextEditingControllers.containsKey(CityValueKey)) {
      _SignUpSpecialistViewTextEditingControllers[CityValueKey]?.text =
          value ?? '';
    }
  }

  set countryValue(String? value) {
    this.setData(
      this.formValueMap..addAll({CountryValueKey: value}),
    );

    if (_SignUpSpecialistViewTextEditingControllers.containsKey(
        CountryValueKey)) {
      _SignUpSpecialistViewTextEditingControllers[CountryValueKey]?.text =
          value ?? '';
    }
  }

  set pincodeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PincodeValueKey: value}),
    );

    if (_SignUpSpecialistViewTextEditingControllers.containsKey(
        PincodeValueKey)) {
      _SignUpSpecialistViewTextEditingControllers[PincodeValueKey]?.text =
          value ?? '';
    }
  }

  bool get hasName =>
      this.formValueMap.containsKey(NameValueKey) &&
      (nameValue?.isNotEmpty ?? false);
  bool get hasMobileNumber =>
      this.formValueMap.containsKey(MobileNumberValueKey) &&
      (mobileNumberValue?.isNotEmpty ?? false);
  bool get hasEmail =>
      this.formValueMap.containsKey(EmailValueKey) &&
      (emailValue?.isNotEmpty ?? false);
  bool get hasPassword =>
      this.formValueMap.containsKey(PasswordValueKey) &&
      (passwordValue?.isNotEmpty ?? false);
  bool get hasDob => this.formValueMap.containsKey(DobValueKey);
  bool get hasCity =>
      this.formValueMap.containsKey(CityValueKey) &&
      (cityValue?.isNotEmpty ?? false);
  bool get hasCountry =>
      this.formValueMap.containsKey(CountryValueKey) &&
      (countryValue?.isNotEmpty ?? false);
  bool get hasPincode =>
      this.formValueMap.containsKey(PincodeValueKey) &&
      (pincodeValue?.isNotEmpty ?? false);
  bool get hasCountryCodeDropDown =>
      this.formValueMap.containsKey(CountryCodeDropDownValueKey);

  bool get hasNameValidationMessage =>
      this.fieldsValidationMessages[NameValueKey]?.isNotEmpty ?? false;
  bool get hasMobileNumberValidationMessage =>
      this.fieldsValidationMessages[MobileNumberValueKey]?.isNotEmpty ?? false;
  bool get hasEmailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey]?.isNotEmpty ?? false;
  bool get hasPasswordValidationMessage =>
      this.fieldsValidationMessages[PasswordValueKey]?.isNotEmpty ?? false;
  bool get hasDobValidationMessage =>
      this.fieldsValidationMessages[DobValueKey]?.isNotEmpty ?? false;
  bool get hasCityValidationMessage =>
      this.fieldsValidationMessages[CityValueKey]?.isNotEmpty ?? false;
  bool get hasCountryValidationMessage =>
      this.fieldsValidationMessages[CountryValueKey]?.isNotEmpty ?? false;
  bool get hasPincodeValidationMessage =>
      this.fieldsValidationMessages[PincodeValueKey]?.isNotEmpty ?? false;
  bool get hasCountryCodeDropDownValidationMessage =>
      this.fieldsValidationMessages[CountryCodeDropDownValueKey]?.isNotEmpty ??
      false;

  String? get nameValidationMessage =>
      this.fieldsValidationMessages[NameValueKey];
  String? get mobileNumberValidationMessage =>
      this.fieldsValidationMessages[MobileNumberValueKey];
  String? get emailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey];
  String? get passwordValidationMessage =>
      this.fieldsValidationMessages[PasswordValueKey];
  String? get dobValidationMessage =>
      this.fieldsValidationMessages[DobValueKey];
  String? get cityValidationMessage =>
      this.fieldsValidationMessages[CityValueKey];
  String? get countryValidationMessage =>
      this.fieldsValidationMessages[CountryValueKey];
  String? get pincodeValidationMessage =>
      this.fieldsValidationMessages[PincodeValueKey];
  String? get countryCodeDropDownValidationMessage =>
      this.fieldsValidationMessages[CountryCodeDropDownValueKey];
}

extension Methods on FormStateHelper {
  Future<void> selectDob({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      this.setData(
        this.formValueMap..addAll({DobValueKey: selectedDate}),
      );
    }

    if (_autoTextFieldValidation) {
      this.validateForm();
    }
  }

  void setCountryCodeDropDown(String countryCodeDropDown) {
    this.setData(
      this.formValueMap
        ..addAll({CountryCodeDropDownValueKey: countryCodeDropDown}),
    );

    if (_autoTextFieldValidation) {
      this.validateForm();
    }
  }

  setNameValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[NameValueKey] = validationMessage;
  setMobileNumberValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[MobileNumberValueKey] = validationMessage;
  setEmailValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[EmailValueKey] = validationMessage;
  setPasswordValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PasswordValueKey] = validationMessage;
  setDobValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DobValueKey] = validationMessage;
  setCityValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[CityValueKey] = validationMessage;
  setCountryValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[CountryValueKey] = validationMessage;
  setPincodeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PincodeValueKey] = validationMessage;
  setCountryCodeDropDownValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[CountryCodeDropDownValueKey] =
          validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    nameValue = '';
    mobileNumberValue = '';
    emailValue = '';
    passwordValue = '';
    cityValue = '';
    countryValue = '';
    pincodeValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      NameValueKey: getValidationMessage(NameValueKey),
      MobileNumberValueKey: getValidationMessage(MobileNumberValueKey),
      EmailValueKey: getValidationMessage(EmailValueKey),
      PasswordValueKey: getValidationMessage(PasswordValueKey),
      CityValueKey: getValidationMessage(CityValueKey),
      CountryValueKey: getValidationMessage(CountryValueKey),
      PincodeValueKey: getValidationMessage(PincodeValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _SignUpSpecialistViewTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _SignUpSpecialistViewTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      NameValueKey: getValidationMessage(NameValueKey),
      MobileNumberValueKey: getValidationMessage(MobileNumberValueKey),
      EmailValueKey: getValidationMessage(EmailValueKey),
      PasswordValueKey: getValidationMessage(PasswordValueKey),
      CityValueKey: getValidationMessage(CityValueKey),
      CountryValueKey: getValidationMessage(CountryValueKey),
      PincodeValueKey: getValidationMessage(PincodeValueKey),
    });
