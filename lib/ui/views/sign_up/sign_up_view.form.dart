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
const String MobileNumberValueKey = 'mobile number';
const String EmailValueKey = 'email';
const String PasswordValueKey = 'password';
const String HeightValueKey = 'height';
const String AccessCodeValueKey = 'accessCode';
const String CityValueKey = 'city';
const String CountryValueKey = 'country';
const String PincodeValueKey = 'pincode';
const String AddressValueKey = 'address';
const String PalmLengthValueKey = 'palmLength';
const String PalmWidthValueKey = 'palmWidth';
const String CountryCodeValueKey = 'countryCode';
const String KnucklesLengthValueKey = 'knucklesLength';
const String WeightValueKey = 'weight';
const String DobValueKey = 'dob';
const String DominantHandValueKey = 'dominant hand';
const String GenderValueKey = 'gender';
const String CountryCodesDropDownValueKey = 'countryCodesDropDown';

final Map<String, String> DominantHandValueToTitleMap = {
  'Right': 'Right',
  'Left': 'Left',
};
final Map<String, String> GenderValueToTitleMap = {
  'Male': 'Male',
  'Female': 'Female',
  'Prefer not to say': 'prefer not to say',
  'Other': 'Other',
};
final Map<String, String> CountryCodesDropDownValueToTitleMap = {
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

final Map<String, TextEditingController> _SignUpViewTextEditingControllers = {};

final Map<String, FocusNode> _SignUpViewFocusNodes = {};

final Map<String, String? Function(String?)?> _SignUpViewTextValidations = {
  NameValueKey: FormValidators.nameValidator,
  MobileNumberValueKey: FormValidators.mobileNumberValidator,
  EmailValueKey: FormValidators.emailValidator,
  PasswordValueKey: FormValidators.passwordValidator,
  HeightValueKey: FormValidators.heightInCentiMetersValidator,
  AccessCodeValueKey: null,
  CityValueKey: null,
  CountryValueKey: null,
  PincodeValueKey: null,
  AddressValueKey: null,
  PalmLengthValueKey: null,
  PalmWidthValueKey: null,
  CountryCodeValueKey: null,
  KnucklesLengthValueKey: null,
  WeightValueKey: FormValidators.weightInKgValidator,
};

mixin $SignUpView {
  TextEditingController get nameController =>
      _getFormTextEditingController(NameValueKey);
  TextEditingController get mobileNumberController =>
      _getFormTextEditingController(MobileNumberValueKey);
  TextEditingController get emailController =>
      _getFormTextEditingController(EmailValueKey);
  TextEditingController get passwordController =>
      _getFormTextEditingController(PasswordValueKey);
  TextEditingController get heightController =>
      _getFormTextEditingController(HeightValueKey);
  TextEditingController get accessCodeController =>
      _getFormTextEditingController(AccessCodeValueKey);
  TextEditingController get cityController =>
      _getFormTextEditingController(CityValueKey);
  TextEditingController get countryController =>
      _getFormTextEditingController(CountryValueKey);
  TextEditingController get pincodeController =>
      _getFormTextEditingController(PincodeValueKey);
  TextEditingController get addressController =>
      _getFormTextEditingController(AddressValueKey);
  TextEditingController get palmLengthController =>
      _getFormTextEditingController(PalmLengthValueKey);
  TextEditingController get palmWidthController =>
      _getFormTextEditingController(PalmWidthValueKey);
  TextEditingController get countryCodeController =>
      _getFormTextEditingController(CountryCodeValueKey);
  TextEditingController get knucklesLengthController =>
      _getFormTextEditingController(KnucklesLengthValueKey);
  TextEditingController get weightController =>
      _getFormTextEditingController(WeightValueKey);

  FocusNode get nameFocusNode => _getFormFocusNode(NameValueKey);
  FocusNode get mobileNumberFocusNode =>
      _getFormFocusNode(MobileNumberValueKey);
  FocusNode get emailFocusNode => _getFormFocusNode(EmailValueKey);
  FocusNode get passwordFocusNode => _getFormFocusNode(PasswordValueKey);
  FocusNode get heightFocusNode => _getFormFocusNode(HeightValueKey);
  FocusNode get accessCodeFocusNode => _getFormFocusNode(AccessCodeValueKey);
  FocusNode get cityFocusNode => _getFormFocusNode(CityValueKey);
  FocusNode get countryFocusNode => _getFormFocusNode(CountryValueKey);
  FocusNode get pincodeFocusNode => _getFormFocusNode(PincodeValueKey);
  FocusNode get addressFocusNode => _getFormFocusNode(AddressValueKey);
  FocusNode get palmLengthFocusNode => _getFormFocusNode(PalmLengthValueKey);
  FocusNode get palmWidthFocusNode => _getFormFocusNode(PalmWidthValueKey);
  FocusNode get countryCodeFocusNode => _getFormFocusNode(CountryCodeValueKey);
  FocusNode get knucklesLengthFocusNode =>
      _getFormFocusNode(KnucklesLengthValueKey);
  FocusNode get weightFocusNode => _getFormFocusNode(WeightValueKey);

  TextEditingController _getFormTextEditingController(
    String key, {
    String? initialValue,
  }) {
    if (_SignUpViewTextEditingControllers.containsKey(key)) {
      return _SignUpViewTextEditingControllers[key]!;
    }

    _SignUpViewTextEditingControllers[key] =
        TextEditingController(text: initialValue);
    return _SignUpViewTextEditingControllers[key]!;
  }

  FocusNode _getFormFocusNode(String key) {
    if (_SignUpViewFocusNodes.containsKey(key)) {
      return _SignUpViewFocusNodes[key]!;
    }
    _SignUpViewFocusNodes[key] = FocusNode();
    return _SignUpViewFocusNodes[key]!;
  }

  /// Registers a listener on every generated controller that calls [model.setData()]
  /// with the latest textController values
  void syncFormWithViewModel(FormStateHelper model) {
    nameController.addListener(() => _updateFormData(model));
    mobileNumberController.addListener(() => _updateFormData(model));
    emailController.addListener(() => _updateFormData(model));
    passwordController.addListener(() => _updateFormData(model));
    heightController.addListener(() => _updateFormData(model));
    accessCodeController.addListener(() => _updateFormData(model));
    cityController.addListener(() => _updateFormData(model));
    countryController.addListener(() => _updateFormData(model));
    pincodeController.addListener(() => _updateFormData(model));
    addressController.addListener(() => _updateFormData(model));
    palmLengthController.addListener(() => _updateFormData(model));
    palmWidthController.addListener(() => _updateFormData(model));
    countryCodeController.addListener(() => _updateFormData(model));
    knucklesLengthController.addListener(() => _updateFormData(model));
    weightController.addListener(() => _updateFormData(model));

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
    heightController.addListener(() => _updateFormData(model));
    accessCodeController.addListener(() => _updateFormData(model));
    cityController.addListener(() => _updateFormData(model));
    countryController.addListener(() => _updateFormData(model));
    pincodeController.addListener(() => _updateFormData(model));
    addressController.addListener(() => _updateFormData(model));
    palmLengthController.addListener(() => _updateFormData(model));
    palmWidthController.addListener(() => _updateFormData(model));
    countryCodeController.addListener(() => _updateFormData(model));
    knucklesLengthController.addListener(() => _updateFormData(model));
    weightController.addListener(() => _updateFormData(model));

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
          HeightValueKey: heightController.text,
          AccessCodeValueKey: accessCodeController.text,
          CityValueKey: cityController.text,
          CountryValueKey: countryController.text,
          PincodeValueKey: pincodeController.text,
          AddressValueKey: addressController.text,
          PalmLengthValueKey: palmLengthController.text,
          PalmWidthValueKey: palmWidthController.text,
          CountryCodeValueKey: countryCodeController.text,
          KnucklesLengthValueKey: knucklesLengthController.text,
          WeightValueKey: weightController.text,
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

    for (var controller in _SignUpViewTextEditingControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _SignUpViewFocusNodes.values) {
      focusNode.dispose();
    }

    _SignUpViewTextEditingControllers.clear();
    _SignUpViewFocusNodes.clear();
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
  String? get heightValue => this.formValueMap[HeightValueKey] as String?;
  String? get accessCodeValue =>
      this.formValueMap[AccessCodeValueKey] as String?;
  String? get cityValue => this.formValueMap[CityValueKey] as String?;
  String? get countryValue => this.formValueMap[CountryValueKey] as String?;
  String? get pincodeValue => this.formValueMap[PincodeValueKey] as String?;
  String? get addressValue => this.formValueMap[AddressValueKey] as String?;
  String? get palmLengthValue =>
      this.formValueMap[PalmLengthValueKey] as String?;
  String? get palmWidthValue => this.formValueMap[PalmWidthValueKey] as String?;
  String? get countryCodeValue =>
      this.formValueMap[CountryCodeValueKey] as String?;
  String? get knucklesLengthValue =>
      this.formValueMap[KnucklesLengthValueKey] as String?;
  String? get weightValue => this.formValueMap[WeightValueKey] as String?;
  DateTime? get dobValue => this.formValueMap[DobValueKey] as DateTime?;
  String? get dominantHandValue =>
      this.formValueMap[DominantHandValueKey] as String?;
  String? get genderValue => this.formValueMap[GenderValueKey] as String?;
  String? get countryCodesDropDownValue =>
      this.formValueMap[CountryCodesDropDownValueKey] as String?;

  set nameValue(String? value) {
    this.setData(
      this.formValueMap..addAll({NameValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(NameValueKey)) {
      _SignUpViewTextEditingControllers[NameValueKey]?.text = value ?? '';
    }
  }

  set mobileNumberValue(String? value) {
    this.setData(
      this.formValueMap..addAll({MobileNumberValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(MobileNumberValueKey)) {
      _SignUpViewTextEditingControllers[MobileNumberValueKey]?.text =
          value ?? '';
    }
  }

  set emailValue(String? value) {
    this.setData(
      this.formValueMap..addAll({EmailValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(EmailValueKey)) {
      _SignUpViewTextEditingControllers[EmailValueKey]?.text = value ?? '';
    }
  }

  set passwordValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PasswordValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(PasswordValueKey)) {
      _SignUpViewTextEditingControllers[PasswordValueKey]?.text = value ?? '';
    }
  }

  set heightValue(String? value) {
    this.setData(
      this.formValueMap..addAll({HeightValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(HeightValueKey)) {
      _SignUpViewTextEditingControllers[HeightValueKey]?.text = value ?? '';
    }
  }

  set accessCodeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({AccessCodeValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(AccessCodeValueKey)) {
      _SignUpViewTextEditingControllers[AccessCodeValueKey]?.text = value ?? '';
    }
  }

  set cityValue(String? value) {
    this.setData(
      this.formValueMap..addAll({CityValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(CityValueKey)) {
      _SignUpViewTextEditingControllers[CityValueKey]?.text = value ?? '';
    }
  }

  set countryValue(String? value) {
    this.setData(
      this.formValueMap..addAll({CountryValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(CountryValueKey)) {
      _SignUpViewTextEditingControllers[CountryValueKey]?.text = value ?? '';
    }
  }

  set pincodeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PincodeValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(PincodeValueKey)) {
      _SignUpViewTextEditingControllers[PincodeValueKey]?.text = value ?? '';
    }
  }

  set addressValue(String? value) {
    this.setData(
      this.formValueMap..addAll({AddressValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(AddressValueKey)) {
      _SignUpViewTextEditingControllers[AddressValueKey]?.text = value ?? '';
    }
  }

  set palmLengthValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PalmLengthValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(PalmLengthValueKey)) {
      _SignUpViewTextEditingControllers[PalmLengthValueKey]?.text = value ?? '';
    }
  }

  set palmWidthValue(String? value) {
    this.setData(
      this.formValueMap..addAll({PalmWidthValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(PalmWidthValueKey)) {
      _SignUpViewTextEditingControllers[PalmWidthValueKey]?.text = value ?? '';
    }
  }

  set countryCodeValue(String? value) {
    this.setData(
      this.formValueMap..addAll({CountryCodeValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(CountryCodeValueKey)) {
      _SignUpViewTextEditingControllers[CountryCodeValueKey]?.text =
          value ?? '';
    }
  }

  set knucklesLengthValue(String? value) {
    this.setData(
      this.formValueMap..addAll({KnucklesLengthValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(KnucklesLengthValueKey)) {
      _SignUpViewTextEditingControllers[KnucklesLengthValueKey]?.text =
          value ?? '';
    }
  }

  set weightValue(String? value) {
    this.setData(
      this.formValueMap..addAll({WeightValueKey: value}),
    );

    if (_SignUpViewTextEditingControllers.containsKey(WeightValueKey)) {
      _SignUpViewTextEditingControllers[WeightValueKey]?.text = value ?? '';
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
  bool get hasHeight =>
      this.formValueMap.containsKey(HeightValueKey) &&
      (heightValue?.isNotEmpty ?? false);
  bool get hasAccessCode =>
      this.formValueMap.containsKey(AccessCodeValueKey) &&
      (accessCodeValue?.isNotEmpty ?? false);
  bool get hasCity =>
      this.formValueMap.containsKey(CityValueKey) &&
      (cityValue?.isNotEmpty ?? false);
  bool get hasCountry =>
      this.formValueMap.containsKey(CountryValueKey) &&
      (countryValue?.isNotEmpty ?? false);
  bool get hasPincode =>
      this.formValueMap.containsKey(PincodeValueKey) &&
      (pincodeValue?.isNotEmpty ?? false);
  bool get hasAddress =>
      this.formValueMap.containsKey(AddressValueKey) &&
      (addressValue?.isNotEmpty ?? false);
  bool get hasPalmLength =>
      this.formValueMap.containsKey(PalmLengthValueKey) &&
      (palmLengthValue?.isNotEmpty ?? false);
  bool get hasPalmWidth =>
      this.formValueMap.containsKey(PalmWidthValueKey) &&
      (palmWidthValue?.isNotEmpty ?? false);
  bool get hasCountryCode =>
      this.formValueMap.containsKey(CountryCodeValueKey) &&
      (countryCodeValue?.isNotEmpty ?? false);
  bool get hasKnucklesLength =>
      this.formValueMap.containsKey(KnucklesLengthValueKey) &&
      (knucklesLengthValue?.isNotEmpty ?? false);
  bool get hasWeight =>
      this.formValueMap.containsKey(WeightValueKey) &&
      (weightValue?.isNotEmpty ?? false);
  bool get hasDob => this.formValueMap.containsKey(DobValueKey);
  bool get hasDominantHand =>
      this.formValueMap.containsKey(DominantHandValueKey);
  bool get hasGender => this.formValueMap.containsKey(GenderValueKey);
  bool get hasCountryCodesDropDown =>
      this.formValueMap.containsKey(CountryCodesDropDownValueKey);

  bool get hasNameValidationMessage =>
      this.fieldsValidationMessages[NameValueKey]?.isNotEmpty ?? false;
  bool get hasMobileNumberValidationMessage =>
      this.fieldsValidationMessages[MobileNumberValueKey]?.isNotEmpty ?? false;
  bool get hasEmailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey]?.isNotEmpty ?? false;
  bool get hasPasswordValidationMessage =>
      this.fieldsValidationMessages[PasswordValueKey]?.isNotEmpty ?? false;
  bool get hasHeightValidationMessage =>
      this.fieldsValidationMessages[HeightValueKey]?.isNotEmpty ?? false;
  bool get hasAccessCodeValidationMessage =>
      this.fieldsValidationMessages[AccessCodeValueKey]?.isNotEmpty ?? false;
  bool get hasCityValidationMessage =>
      this.fieldsValidationMessages[CityValueKey]?.isNotEmpty ?? false;
  bool get hasCountryValidationMessage =>
      this.fieldsValidationMessages[CountryValueKey]?.isNotEmpty ?? false;
  bool get hasPincodeValidationMessage =>
      this.fieldsValidationMessages[PincodeValueKey]?.isNotEmpty ?? false;
  bool get hasAddressValidationMessage =>
      this.fieldsValidationMessages[AddressValueKey]?.isNotEmpty ?? false;
  bool get hasPalmLengthValidationMessage =>
      this.fieldsValidationMessages[PalmLengthValueKey]?.isNotEmpty ?? false;
  bool get hasPalmWidthValidationMessage =>
      this.fieldsValidationMessages[PalmWidthValueKey]?.isNotEmpty ?? false;
  bool get hasCountryCodeValidationMessage =>
      this.fieldsValidationMessages[CountryCodeValueKey]?.isNotEmpty ?? false;
  bool get hasKnucklesLengthValidationMessage =>
      this.fieldsValidationMessages[KnucklesLengthValueKey]?.isNotEmpty ??
      false;
  bool get hasWeightValidationMessage =>
      this.fieldsValidationMessages[WeightValueKey]?.isNotEmpty ?? false;
  bool get hasDobValidationMessage =>
      this.fieldsValidationMessages[DobValueKey]?.isNotEmpty ?? false;
  bool get hasDominantHandValidationMessage =>
      this.fieldsValidationMessages[DominantHandValueKey]?.isNotEmpty ?? false;
  bool get hasGenderValidationMessage =>
      this.fieldsValidationMessages[GenderValueKey]?.isNotEmpty ?? false;
  bool get hasCountryCodesDropDownValidationMessage =>
      this.fieldsValidationMessages[CountryCodesDropDownValueKey]?.isNotEmpty ??
      false;

  String? get nameValidationMessage =>
      this.fieldsValidationMessages[NameValueKey];
  String? get mobileNumberValidationMessage =>
      this.fieldsValidationMessages[MobileNumberValueKey];
  String? get emailValidationMessage =>
      this.fieldsValidationMessages[EmailValueKey];
  String? get passwordValidationMessage =>
      this.fieldsValidationMessages[PasswordValueKey];
  String? get heightValidationMessage =>
      this.fieldsValidationMessages[HeightValueKey];
  String? get accessCodeValidationMessage =>
      this.fieldsValidationMessages[AccessCodeValueKey];
  String? get cityValidationMessage =>
      this.fieldsValidationMessages[CityValueKey];
  String? get countryValidationMessage =>
      this.fieldsValidationMessages[CountryValueKey];
  String? get pincodeValidationMessage =>
      this.fieldsValidationMessages[PincodeValueKey];
  String? get addressValidationMessage =>
      this.fieldsValidationMessages[AddressValueKey];
  String? get palmLengthValidationMessage =>
      this.fieldsValidationMessages[PalmLengthValueKey];
  String? get palmWidthValidationMessage =>
      this.fieldsValidationMessages[PalmWidthValueKey];
  String? get countryCodeValidationMessage =>
      this.fieldsValidationMessages[CountryCodeValueKey];
  String? get knucklesLengthValidationMessage =>
      this.fieldsValidationMessages[KnucklesLengthValueKey];
  String? get weightValidationMessage =>
      this.fieldsValidationMessages[WeightValueKey];
  String? get dobValidationMessage =>
      this.fieldsValidationMessages[DobValueKey];
  String? get dominantHandValidationMessage =>
      this.fieldsValidationMessages[DominantHandValueKey];
  String? get genderValidationMessage =>
      this.fieldsValidationMessages[GenderValueKey];
  String? get countryCodesDropDownValidationMessage =>
      this.fieldsValidationMessages[CountryCodesDropDownValueKey];
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

  void setDominantHand(String dominantHand) {
    this.setData(
      this.formValueMap..addAll({DominantHandValueKey: dominantHand}),
    );

    if (_autoTextFieldValidation) {
      this.validateForm();
    }
  }

  void setGender(String gender) {
    this.setData(
      this.formValueMap..addAll({GenderValueKey: gender}),
    );

    if (_autoTextFieldValidation) {
      this.validateForm();
    }
  }

  void setCountryCodesDropDown(String countryCodesDropDown) {
    this.setData(
      this.formValueMap
        ..addAll({CountryCodesDropDownValueKey: countryCodesDropDown}),
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
  setHeightValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[HeightValueKey] = validationMessage;
  setAccessCodeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[AccessCodeValueKey] = validationMessage;
  setCityValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[CityValueKey] = validationMessage;
  setCountryValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[CountryValueKey] = validationMessage;
  setPincodeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PincodeValueKey] = validationMessage;
  setAddressValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[AddressValueKey] = validationMessage;
  setPalmLengthValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PalmLengthValueKey] = validationMessage;
  setPalmWidthValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[PalmWidthValueKey] = validationMessage;
  setCountryCodeValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[CountryCodeValueKey] = validationMessage;
  setKnucklesLengthValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[KnucklesLengthValueKey] = validationMessage;
  setWeightValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[WeightValueKey] = validationMessage;
  setDobValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DobValueKey] = validationMessage;
  setDominantHandValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[DominantHandValueKey] = validationMessage;
  setGenderValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[GenderValueKey] = validationMessage;
  setCountryCodesDropDownValidationMessage(String? validationMessage) =>
      this.fieldsValidationMessages[CountryCodesDropDownValueKey] =
          validationMessage;

  /// Clears text input fields on the Form
  void clearForm() {
    nameValue = '';
    mobileNumberValue = '';
    emailValue = '';
    passwordValue = '';
    heightValue = '';
    accessCodeValue = '';
    cityValue = '';
    countryValue = '';
    pincodeValue = '';
    addressValue = '';
    palmLengthValue = '';
    palmWidthValue = '';
    countryCodeValue = '';
    knucklesLengthValue = '';
    weightValue = '';
  }

  /// Validates text input fields on the Form
  void validateForm() {
    this.setValidationMessages({
      NameValueKey: getValidationMessage(NameValueKey),
      MobileNumberValueKey: getValidationMessage(MobileNumberValueKey),
      EmailValueKey: getValidationMessage(EmailValueKey),
      PasswordValueKey: getValidationMessage(PasswordValueKey),
      HeightValueKey: getValidationMessage(HeightValueKey),
      AccessCodeValueKey: getValidationMessage(AccessCodeValueKey),
      CityValueKey: getValidationMessage(CityValueKey),
      CountryValueKey: getValidationMessage(CountryValueKey),
      PincodeValueKey: getValidationMessage(PincodeValueKey),
      AddressValueKey: getValidationMessage(AddressValueKey),
      PalmLengthValueKey: getValidationMessage(PalmLengthValueKey),
      PalmWidthValueKey: getValidationMessage(PalmWidthValueKey),
      CountryCodeValueKey: getValidationMessage(CountryCodeValueKey),
      KnucklesLengthValueKey: getValidationMessage(KnucklesLengthValueKey),
      WeightValueKey: getValidationMessage(WeightValueKey),
    });
  }
}

/// Returns the validation message for the given key
String? getValidationMessage(String key) {
  final validatorForKey = _SignUpViewTextValidations[key];
  if (validatorForKey == null) return null;

  String? validationMessageForKey = validatorForKey(
    _SignUpViewTextEditingControllers[key]!.text,
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
      HeightValueKey: getValidationMessage(HeightValueKey),
      AccessCodeValueKey: getValidationMessage(AccessCodeValueKey),
      CityValueKey: getValidationMessage(CityValueKey),
      CountryValueKey: getValidationMessage(CountryValueKey),
      PincodeValueKey: getValidationMessage(PincodeValueKey),
      AddressValueKey: getValidationMessage(AddressValueKey),
      PalmLengthValueKey: getValidationMessage(PalmLengthValueKey),
      PalmWidthValueKey: getValidationMessage(PalmWidthValueKey),
      CountryCodeValueKey: getValidationMessage(CountryCodeValueKey),
      KnucklesLengthValueKey: getValidationMessage(KnucklesLengthValueKey),
      WeightValueKey: getValidationMessage(WeightValueKey),
    });
