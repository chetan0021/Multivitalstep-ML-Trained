// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String EmailValueKey = 'email';
const String AccessCodeValueKey = 'accessCode';

final Map<String, TextEditingController>
    _AddPatientDialogTextEditingControllers = {};

final Map<String, FocusNode> _AddPatientDialogFocusNodes = {};

final Map<String, String? Function(String?)?> _AddPatientDialogTextValidations =
    {
  EmailValueKey: null,
  AccessCodeValueKey: null,
};

mixin $AddPatientDialog {
  TextEditingController get emailController =>
      _getFormTextEditingController(EmailValueKey);
  TextEditingController get accessCodeController =>
      _getFormTextEditingController(AccessCodeValueKey);

  FocusNode get emailFocusNode => _getFormFocusNode(EmailValueKey);
  FocusNode get accessCodeFocusNode => _getFormFocusNode(AccessCodeValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_AddPatientDialogTextEditingControllers.containsKey(key)) {
      return _AddPatientDialogTextEditingControllers[key]!;
    }

    _AddPatientDialogTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _AddPatientDialogTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_AddPatientDialogFocusNodes.containsKey(key)) {
      return _AddPatientDialogFocusNodes[key]!;
    }
    _AddPatientDialogFocusNodes[key] = FocusNode();
    return _AddPatientDialogFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    emailController.addListener(() => _updateFormData(model));
    accessCodeController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    emailController.addListener(() => _updateFormData(model));
    accessCodeController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          EmailValueKey: emailController.text,
          AccessCodeValueKey: accessCodeController.text,
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

    for (var controller in _AddPatientDialogTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _AddPatientDialogFocusNodes.values) {
      focusNode.dispose();
    }

    _AddPatientDialogTextEditingControllers.clear();
    _AddPatientDialogFocusNodes.clear();
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

  String? get emailValue => this.formValueMap[EmailValueKey] as String?;
  String? get accessCodeValue =>
      this.formValueMap[AccessCodeValueKey] as String?;

  set emailValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmailValueKey: value}),
    );

    if (_AddPatientDialogTextEditingControllers.containsKey(EmailValueKey)) {
      _AddPatientDialogTextEditingControllers[EmailValueKey]?.text =
          value ?? '';
    }
  }

  set accessCodeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({AccessCodeValueKey: value}),
    );

    if (_AddPatientDialogTextEditingControllers.containsKey(
        AccessCodeValueKey)) {
      _AddPatientDialogTextEditingControllers[AccessCodeValueKey]?.text =
          value ?? '';
    }
  }

  bool get hasEmail =>
      this.formValueMap.containsKey(EmailValueKey) &&
      (emailValue?.isNotEmpty ?? false);
  bool get hasAccessCode =>
      this.formValueMap.containsKey(AccessCodeValueKey) &&
      (accessCodeValue?.isNotEmpty ?? false);

  bool get hasEmailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey]?.isNotEmpty ?? false;
  bool get hasAccessCodeValidationMessage =>
      this.fieldsValidationMessages[AccessCodeValueKey]?.isNotEmpty ?? false;

  String? get emailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey];
  String? get accessCodeValidationMessage =>
      this.fieldsValidationMessages[AccessCodeValueKey];
}

extension Methods on FormStateHelper {
  setEmailValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[EmailValueKey] = validationMessage;
  setAccessCodeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[AccessCodeValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    emailValue = '';
    accessCodeValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      EmailValueKey: getValidationMessage(EmailValueKey),
      AccessCodeValueKey: getValidationMessage(AccessCodeValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _AddPatientDialogTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _AddPatientDialogTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      EmailValueKey: getValidationMessage(EmailValueKey),
      AccessCodeValueKey: getValidationMessage(AccessCodeValueKey),
    });
