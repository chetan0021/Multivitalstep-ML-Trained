import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/login_service.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';

import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  LoginView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  String _selectedUserType = 'Patient'; // Initial value for the dropdown
  String _email = 'a';
  String _password = '';

  double generalTextFontSize = 15;

  final List<String> _userTypes = ['Specialist', 'Patient'];

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildLoginForm(context, viewModel),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kcPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.health_and_safety_rounded, color: kcPrimaryColor, size: 32),
        ),
        const SizedBox(height: 24),
        const Text(
          "Welcome back",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kcDarkGreyColor, letterSpacing: -0.5),
        ),
        verticalSpaceTiny,
        const Text(
          "Sign in to continue your health journey",
          style: TextStyle(fontSize: 16, color: kcMediumGrey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, LoginViewModel viewModel) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Identity"),
          DropdownButtonFormField<String>(
            value: _selectedUserType,
            decoration: premiumInputDecoration("Select User Type"),
            items: _userTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (val) {
              _selectedUserType = val!;
              viewModel.notifyListeners();
            },
          ),
          const SizedBox(height: 20),
          _buildLabel("Email Address"),
          TextFormField(
            decoration: premiumInputDecoration("e.g. name@email.com"),
            keyboardType: TextInputType.emailAddress,
            onSaved: (val) => _email = val!,
            validator: (val) => (val == null || val.isEmpty) ? "Email is required" : null,
          ),
          const SizedBox(height: 20),
          _buildLabel("Password"),
          TextFormField(
            obscureText: !viewModel.passwordVisible,
            decoration: premiumInputDecoration("••••••••").copyWith(
              suffixIcon: IconButton(
                icon: Icon(viewModel.passwordVisible ? Icons.visibility : Icons.visibility_off, color: kcMediumGrey),
                onPressed: () {
                  viewModel.passwordVisible = !viewModel.passwordVisible;
                  viewModel.rebuildUi();
                },
              ),
            ),
            onSaved: (val) => _password = val!,
            validator: (val) => (val == null || val.isEmpty) ? "Password is required" : null,
          ),
          const SizedBox(height: 30),
          _buildLoginButton(viewModel),
          const SizedBox(height: 24),
          _buildFooterLinks(context),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kcDarkGreyColor)),
    );
  }

  InputDecoration premiumInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kcLightGrey, fontSize: 15, fontWeight: FontWeight.w500),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: kcLightGrey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel vm) {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          if (vm.isBusy) return;
          vm.setBusy(true);
          await locator<LoginService>().signIn(_email, _password, _selectedUserType);
          vm.setBusy(false);
        }
      },
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kcPrimaryColor, kcPrimaryColorDark]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: kcPrimaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Center(
          child: vm.isBusy
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Trouble signing in? ", style: TextStyle(color: kcMediumGrey)),
            GestureDetector(
              onTap: () => NavigationService().navigateToPasswordResetViewView(),
              child: const Text("Reset Password", style: TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? ", style: TextStyle(color: kcMediumGrey)),
            GestureDetector(
              onTap: () => NavigationService().navigateToSignUpView(),
              child: const Text("Sign Up", style: TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => NavigationService().navigateToSignUpSpecialistView(),
          child: const Text("Join as Specialist", style: TextStyle(color: kcSecondaryColor, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
  @override
  LoginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginViewModel();
}
