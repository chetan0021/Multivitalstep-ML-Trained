class FormValidators {
  static String? doubleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Value cant be null";
    }
    if (double.tryParse(value) == null) {
      return "value must be decimal value";
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password should not be empty";
    }

    if (value.length < 8) {
      return "Password must has at least 8 alpha characters";
    }

    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!value.contains('@')) {
      return 'Email is not valid';
    }

    return null;
  }

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty || value == "") {
      return 'Name is required';
    }
    return null;
  }

  static String? mobileNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }

    if (value.length < 10 || int.tryParse(value) == null) {
      return 'Mobile number is not valid';
    }

    return null;
  }

  static String? heightInCentiMetersValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }

    if (int.tryParse(value) == null ||
        int.parse(value) < 50 ||
        int.parse(value) > 250) {
      return 'Height must be between 50 and 250 meters';
    }

    return null;
  }

  static String? weightInKgValidator(String? weight) {
    if (weight == null || weight.isEmpty) {
      return 'Weight is required';
    }

    if (double.parse(weight) < 10 || double.parse(weight) > 200) {
      return 'Weight must be between 10 and 200 kg';
    }

    return null;
  }

  static String? dobValidator(DateTime? dateString) {
    if (dateString == null) {
      return 'Date of birth is required';
    }

    if (dateString.isAfter(DateTime.now())) {
      return 'Date of birth cannot be in the future';
    }

    return null;
  }

  static String? pincodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }
    if (value.length != 6) {
      return 'Pincode should be of 6 digits';
    }
    if (int.tryParse(value) == null) {
      return "Pincode must be an integer";
    }
    return null;
  }
}
