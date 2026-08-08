import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/profile.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/ui/common/FormValidators.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/app_strings.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:vital_step/ui/views/sign_up/sign_up_view.form.dart';

import 'sign_up_viewmodel.dart';

@FormView(fields: [
  FormTextField(name: 'name', validator: FormValidators.nameValidator),
  FormTextField(
      name: 'mobile number', validator: FormValidators.mobileNumberValidator),
  FormTextField(name: 'email', validator: FormValidators.emailValidator),
  FormTextField(name: 'password', validator: FormValidators.passwordValidator),
  FormTextField(
      name: 'height', validator: FormValidators.heightInCentiMetersValidator),
  FormTextField(name: "accessCode"),
  FormTextField(name: "city"),
  FormTextField(name: "country"),
  FormTextField(name: "pincode"),
  FormTextField(name: "address"),
  FormTextField(name: "palmLength"),
  FormTextField(name: "palmWidth"),
  FormTextField(name: "countryCode"),
  FormTextField(name: "knucklesLength"),
  FormTextField(name: 'weight', validator: FormValidators.weightInKgValidator),
  FormDateField(name: 'dob'),
  FormDropdownField(items: [
    StaticDropdownItem(title: "Right", value: "Right"),
    StaticDropdownItem(title: "Left", value: "Left"),
  ], name: 'dominant hand'),
  FormDropdownField(items: [
    StaticDropdownItem(title: "Male", value: "Male"),
    StaticDropdownItem(title: "Female", value: "Female"),
    StaticDropdownItem(title: "prefer not to say", value: "Prefer not to say"),
    StaticDropdownItem(title: "Other", value: "Other"),
  ], name: "gender"),
  FormDropdownField(
      items: countryCodeDropDownItems, name: "countryCodesDropDown")
])
class SignUpView extends StackedView<SignUpViewModel> with $SignUpView {
  SignUpView({Key? key, this.profile}) : super(key: key);
  final Profile? profile;
  final inputStyle = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), // Add border radius
        borderSide: BorderSide.none, // Remove the default border
      ),
      fillColor: Colors.grey[200],
      filled: true);

  @override
  Widget builder(
    BuildContext context,
    SignUpViewModel viewModel,
    Widget? child,
  ) {
    final bool update = profile != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kcDarkGreyColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          update ? "Edit Profile" : "Create Account",
          style: const TextStyle(color: kcDarkGreyColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: viewModel.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!update) ...[
                const Text("Join VitalStep", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kcDarkGreyColor)),
                const SizedBox(height: 8),
                const Text("Start tracking your grip strength today.", style: TextStyle(fontSize: 15, color: kcMediumGrey)),
                const SizedBox(height: 32),
              ],
              
              _buildSectionTitle("Personal Information"),
              _buildField("Full Name", nameController, "e.g. John Doe", validator: FormValidators.nameValidator),
              _buildPhoneField(viewModel),
              _buildField("Email Address", emailController, "e.g. john@example.com", 
                  keyboardType: TextInputType.emailAddress, 
                  validator: FormValidators.emailValidator,
                  enabled: profile == null),
              _buildPasswordField(viewModel),
              
              const SizedBox(height: 32),
              _buildSectionTitle("Physical Metrics"),
              Row(
                children: [
                  Expanded(child: _buildField("Height (cm)", heightController, "170", keyboardType: TextInputType.number, validator: FormValidators.heightInCentiMetersValidator)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("Weight (kg)", weightController, "70", keyboardType: TextInputType.number, validator: FormValidators.weightInKgValidator)),
                ],
              ),
              _buildField("Date of Birth", viewModel.viewDobController, "Select Date", readOnly: true, onTap: () => viewModel.setDOB(context)),
              
              const SizedBox(height: 32),
              _buildSectionTitle("Hand Specifications"),
              Row(
                children: [
                  Expanded(child: _buildDropdown("Dominant Hand", viewModel.dominantHandValue, DominantHandValueToTitleMap, (val) => viewModel.setDominantHand(val!))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdown("Gender", viewModel.genderValue, GenderValueToTitleMap, (val) => viewModel.setGender(val!))),
                ],
              ),
              const SizedBox(height: 16),
              _buildMeasurementField(context, "Palm Length (cm)", palmLengthController, "assets/palmLength.png"),
              _buildMeasurementField(context, "Palm Width (cm)", palmWidthController, "assets/palmWidth.png"),
              _buildMeasurementField(context, "Knuckles Length (cm)", knucklesLengthController, "assets/knucleLength.png"),
              
              const SizedBox(height: 32),
              _buildSectionTitle("Address"),
              _buildField("Street Address", addressController, "123 Main St"),
              Row(
                children: [
                  Expanded(child: _buildField("City", cityController, "City")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("Pincode", pincodeController, "123456", keyboardType: TextInputType.number)),
                ],
              ),
              _buildField("Country", countryController, "Country"),

              const SizedBox(height: 32),
              if (profile == null) _buildTermsCheckbox(viewModel),
              
              const SizedBox(height: 40),
              _buildSubmitButton(viewModel, update),
              const SizedBox(height: 24),
              if (profile == null) const SignUpBottom(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kcPrimaryColor)),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, 
      {TextInputType? keyboardType, String? Function(String?)? validator, bool enabled = true, bool readOnly = false, VoidCallback? onTap, Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kcDarkGreyColor)),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          decoration: premiumInputDecoration(hint).copyWith(suffixIcon: suffixIcon),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhoneField(SignUpViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kcDarkGreyColor)),
        ),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                value: vm.countryCodesDropDownValue,
                decoration: premiumInputDecoration("").copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18)),
                onChanged: (val) => vm.setCountryCodesDropDown(val!),
                items: CountryCodesDropDownValueToTitleMap.keys
                    .map((val) => DropdownMenuItem(value: val, child: Text(CountryCodesDropDownValueToTitleMap[val]!, style: const TextStyle(fontSize: 14))))
                    .toList(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: mobileNumberController,
                keyboardType: TextInputType.phone,
                validator: FormValidators.mobileNumberValidator,
                enabled: profile == null,
                decoration: premiumInputDecoration("Phone Number"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordField(SignUpViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kcDarkGreyColor)),
        ),
        TextFormField(
          controller: passwordController,
          obscureText: !vm.passwordVisible,
          validator: FormValidators.passwordValidator,
          decoration: premiumInputDecoration("••••••••").copyWith(
            suffixIcon: IconButton(
              icon: Icon(vm.passwordVisible ? Icons.visibility : Icons.visibility_off, color: kcMediumGrey),
              onPressed: () {
                vm.passwordVisible = !vm.passwordVisible;
                vm.rebuildUi();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, Map<String, String> itemsMap, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kcDarkGreyColor)),
        ),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: premiumInputDecoration("Select"),
          items: itemsMap.keys.map((val) => DropdownMenuItem(value: val, child: Text(itemsMap[val]!))).toList(),
        ),
      ],
    );
  }

  Widget _buildMeasurementField(BuildContext context, String label, TextEditingController controller, String assetPath) {
    return _buildField(
      label,
      controller,
      "0.0",
      keyboardType: TextInputType.number,
      suffixIcon: IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(assetPath, width: 250, height: 250, fit: BoxFit.contain),
              ),
            ),
          );
        },
        icon: const Icon(Icons.info_outline, color: kcMediumGrey, size: 20),
      ),
    );
  }

  InputDecoration premiumInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kcLightGrey, fontSize: 14),
      fillColor: const Color(0xFFF9FAFB),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _buildTermsCheckbox(SignUpViewModel vm) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: RichText(
        text: TextSpan(
          children: [
            const TextSpan(text: "I accept the ", style: TextStyle(color: kcMediumGrey, fontSize: 13)),
            TextSpan(
              text: "Terms and Conditions",
              style: const TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 13),
              recognizer: TapGestureRecognizer()..onTap = () => NavigationService().navigateToPrivacyPolicyView(),
            ),
          ],
        ),
      ),
      value: vm.isTermsAccepted,
      onChanged: (val) {
        vm.isTermsAccepted = val!;
        vm.rebuildUi();
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildSubmitButton(SignUpViewModel vm, bool update) {
    return InkWell(
      onTap: () async {
        if (vm.isBusy) return;
        await vm.saveData(update: update);
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: kcPrimaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: kcPrimaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: vm.isBusy
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(update ? "Save Changes" : "Create Account", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        ),
      ),
    );
  }

  @override
  SignUpViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SignUpViewModel();

  @override
  void onViewModelReady(SignUpViewModel viewModel) {
    syncFormWithViewModel(viewModel);
    if (profile != null) {
      viewModel.setProfile(profile!);
    }
  }

  @override
  void onDispose(SignUpViewModel viewModel) {
    disposeForm();
  }
}

class SignUpBottom extends StatelessWidget {
  const SignUpBottom({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have an account?",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              NavigationService().navigateToLoginView();
            },
            child: const Text(
              "Sign In",
              style: TextStyle(
                  fontSize: 15,
                  color: kcPrimaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key, required this.update});
  final bool update;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        verticalSpaceLarge,
        const Text(
          "VITALSTEP",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        verticalSpaceMedium,
        Text(
          update == true ? "Update" : "Sign Up",
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
        verticalSpaceLarge,
      ],
    );
  }
}
