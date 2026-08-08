import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:vital_step/Model/spcialist_profile.dart';
import 'package:vital_step/ui/common/FormValidators.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/app_strings.dart';
import 'package:vital_step/ui/views/sign_up/sign_up_view.dart';
import 'package:vital_step/ui/views/sign_up_specialist/sign_up_specialist_view.form.dart';

import 'sign_up_specialist_viewmodel.dart';

@FormView(fields: [
  FormTextField(name: 'name', validator: FormValidators.nameValidator),
  FormTextField(
      name: 'mobileNumber', validator: FormValidators.mobileNumberValidator),
  FormTextField(name: 'email', validator: FormValidators.emailValidator),
  FormTextField(name: 'password', validator: FormValidators.passwordValidator),
  FormDateField(name: 'dob'),
  FormTextField(name: 'city'),
  FormTextField(name: 'country'),
  FormTextField(name: 'pincode'),
  FormDropdownField(
      items: countryCodeDropDownItems, name: "countryCodeDropDown")
])
class SignUpSpecialistView extends StackedView<SignUpSpecialistViewModel>
    with $SignUpSpecialistView {
  SignUpSpecialistView({Key? key, this.profile}) : super(key: key);
  final ProfileSpecialist? profile;
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
    SignUpSpecialistViewModel viewModel,
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
          update ? "Edit Specialist Profile" : "Specialist Registration",
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
                const Text("Join as Specialist", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kcDarkGreyColor)),
                const SizedBox(height: 8),
                const Text("Help patients manage their health better.", style: TextStyle(fontSize: 15, color: kcMediumGrey)),
                const SizedBox(height: 32),
              ],
              
              _buildSectionTitle("Professional Details"),
              _buildField("Full Name", nameController, "Dr. Smith", validator: FormValidators.nameValidator),
              _buildPhoneField(viewModel),
              _buildField("Email Address", emailController, "specialist@example.com", 
                  keyboardType: TextInputType.emailAddress, 
                  validator: FormValidators.emailValidator,
                  enabled: profile == null),
              
              if (!update) ...[
                const SizedBox(height: 8),
                _buildPasswordField(viewModel),
              ],
              
              const SizedBox(height: 32),
              _buildSectionTitle("Personal Details"),
              _buildField("Date of Birth", viewModel.viewDobController, "Select Date", readOnly: true, onTap: () => viewModel.setDOB(context)),
              
              const SizedBox(height: 32),
              _buildSectionTitle("Location"),
              Row(
                children: [
                  Expanded(child: _buildField("City", cityController, "City")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("Pincode", pincodeController, "123456", keyboardType: TextInputType.number)),
                ],
              ),
              _buildField("Country", countryController, "Country"),

              const SizedBox(height: 48),
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
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kcSecondaryColor)),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, 
      {TextInputType? keyboardType, String? Function(String?)? validator, bool enabled = true, bool readOnly = false, VoidCallback? onTap}) {
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
          decoration: premiumInputDecoration(hint),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhoneField(SignUpSpecialistViewModel vm) {
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
                value: vm.countryCodeDropDownValue,
                decoration: premiumInputDecoration("").copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18)),
                onChanged: (val) => vm.setCountryCodeDropDown(val!),
                items: CountryCodeDropDownValueToTitleMap.keys
                    .map((val) => DropdownMenuItem(value: val, child: Text(CountryCodeDropDownValueToTitleMap[val]!, style: const TextStyle(fontSize: 14))))
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

  Widget _buildPasswordField(SignUpSpecialistViewModel vm) {
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
        borderSide: const BorderSide(color: kcSecondaryColor, width: 2),
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

  Widget _buildSubmitButton(SignUpSpecialistViewModel vm, bool update) {
    return InkWell(
      onTap: () async {
        if (vm.isBusy) return;
        await vm.saveData(update: update);
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: kcSecondaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: kcSecondaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: vm.isBusy
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(update ? "Save Changes" : "Register Now", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        ),
      ),
    );
  }

  @override
  SignUpSpecialistViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SignUpSpecialistViewModel();
  @override
  void onViewModelReady(SignUpSpecialistViewModel viewModel) {
    syncFormWithViewModel(viewModel);
    if (profile != null) {
      viewModel.setProfile(profile!);
    }
  }
}
