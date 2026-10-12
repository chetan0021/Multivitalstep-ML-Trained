// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedFormGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, constant_identifier_names, non_constant_identifier_names,unnecessary_this

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

const bool _autoTextFieldValidation = true;

const String DeviceNameValueKey = 'deviceName';
const String DeviceCodeValueKey = 'deviceCode';

final Map<String, TextEditingController> _DeviceViewTextEditingControllers = {};

final Map<String, FocusNode> _DeviceViewFocusNodes = {};

final Map<String, String? Function(String?)?> _DeviceViewTextValidations = {
  DeviceNameValueKey: null,
  DeviceCodeValueKey: null,
};

mixin $DeviceView {
  TextEditingController get deviceNameController =>
      _getFormTextEditingController(DeviceNameValueKey);
  TextEditingController get deviceCodeController =>
      _getFormTextEditingController(DeviceCodeValueKey);

  FocusNode get deviceNameFocusNode => _getFormFocusNode(DeviceNameValueKey);
  FocusNode get deviceCodeFocusNode => _getFormFocusNode(DeviceCodeValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_DeviceViewTextEditingControllers.containsKey(key)) {
      return _DeviceViewTextEditingControllers[key]!;
    }

    _DeviceViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _DeviceViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_DeviceViewFocusNodes.containsKey(key)) {
      return _DeviceViewFocusNodes[key]!;
    }
    _DeviceViewFocusNodes[key] = FocusNode();
    return _DeviceViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    deviceNameController.addListener(() => _updateFormData(model));
    deviceCodeController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  @Deprecated(
    'Use syncFormWithViewModel instead.'
    'This feature was deprecated after 3.1.0.',
  )
  void listenToFormUpdated(FormViewModel model) {
    deviceNameController.addListener(() => _updateFormData(model));
    deviceCodeController.addListener(() => _updateFormData(model));

    _updateFormData(model, forceValidate: _autoTextFieldValidation);
  }

  /// Updates the formData on the FormViewModel
  void _updateFormData(FormStateHelper model, {bool forceValidate = false}) {
    model.setData(
      model.formValueMap
        ..addAll({
          DeviceNameValueKey: deviceNameController.text,
          DeviceCodeValueKey: deviceCodeController.text,
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

    for (var controller in _DeviceViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _DeviceViewFocusNodes.values) {
      focusNode.dispose();
    }

    _DeviceViewTextEditingControllers.clear();
    _DeviceViewFocusNodes.clear();
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

  String? get deviceNameValue =>
      this.formValueMap[DeviceNameValueKey] as String?;
  String? get deviceCodeValue =>
      this.formValueMap[DeviceCodeValueKey] as String?;

  set deviceNameValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DeviceNameValueKey: value}),
    );

    if (_DeviceViewTextEditingControllers.containsKey(DeviceNameValueKey)) {
      _DeviceViewTextEditingControllers[DeviceNameValueKey]?.text = value ?? '';
    }
  }

  set deviceCodeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({DeviceCodeValueKey: value}),
    );

    if (_DeviceViewTextEditingControllers.containsKey(DeviceCodeValueKey)) {
      _DeviceViewTextEditingControllers[DeviceCodeValueKey]?.text = value ?? '';
    }
  }

  bool get hasDeviceName =>
      this.formValueMap.containsKey(DeviceNameValueKey) &&
      (deviceNameValue?.isNotEmpty ?? false);
  bool get hasDeviceCode =>
      this.formValueMap.containsKey(DeviceCodeValueKey) &&
      (deviceCodeValue?.isNotEmpty ?? false);

  bool get hasDeviceNameValidationMessage =>
      this.fieldsValidationMessages[DeviceNameValueKey]?.isNotEmpty ?? false;
  bool get hasDeviceCodeValidationMessage =>
      this.fieldsValidationMessages[DeviceCodeValueKey]?.isNotEmpty ?? false;

  String? get deviceNameValidationMessage =>
      this.fieldsValidationMessages[DeviceNameValueKey];
  String? get deviceCodeValidationMessage =>
      this.fieldsValidationMessages[DeviceCodeValueKey];
}

extension Methods on FormStateHelper {
  setDeviceNameValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DeviceNameValueKey] = validationMessage;
  setDeviceCodeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DeviceCodeValueKey] = validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    deviceNameValue = '';
    deviceCodeValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      DeviceNameValueKey: getValidationMessage(DeviceNameValueKey),
      DeviceCodeValueKey: getValidationMessage(DeviceCodeValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _DeviceViewTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _DeviceViewTextEditingControllers[key]!.text,
  );

  return validationMessageForKey;
}

/// Updates the fieldsValidationMessages on the FormViewModel
void updateValidationData(FormStateHelper model) =>
    model.setValidationMessages({
      DeviceNameValueKey: getValidationMessage(DeviceNameValueKey),
      DeviceCodeValueKey: getValidationMessage(DeviceCodeValueKey),
    });
