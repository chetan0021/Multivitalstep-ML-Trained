import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors.dart';

import 'patient_registration_viewmodel.dart';

class PatientRegistrationView
    extends StackedView<PatientRegistrationViewModel> {
  const PatientRegistrationView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PatientRegistrationViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.registeredPatient != null) {
      return _buildSuccessView(context, viewModel);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: kcDarkGreyColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register Patient',
          style: TextStyle(color: kcDarkGreyColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Patient',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kcDarkGreyColor)),
            const SizedBox(height: 8),
            const Text('Enter patient information to begin session.',
                style: TextStyle(fontSize: 15, color: kcMediumGrey)),
            const SizedBox(height: 32),

            // ── Personal Information ───────────────────────────────────────
            _sectionTitle('Personal Information'),

            _buildTextField(
              label: 'Full Name',
              hint: 'Enter patient name',
              errorText: viewModel.nameError,
              onChanged: (v) => viewModel.name = v,
            ),

            _buildTextField(
              label: 'Age',
              hint: 'e.g. 28',
              keyboardType: TextInputType.number,
              errorText: viewModel.ageError,
              onChanged: (v) => viewModel.ageText = v,
            ),

            _buildDropdownField(
              label: 'Gender',
              value: viewModel.gender.isEmpty ? null : viewModel.gender,
              errorText: viewModel.genderError,
              items: const ['Male', 'Female', 'Other', 'Prefer not to say'],
              onChanged: (v) {
                viewModel.gender = v ?? '';
                viewModel.notifyListeners();
              },
            ),

            _buildTextField(
              label: 'Date of Birth',
              hint: 'Select date',
              controller: viewModel.dobController,
              readOnly: true,
              onTap: () => viewModel.setDOB(context),
            ),

            _buildTextField(
              label: 'Phone Number',
              hint: 'e.g. +91 98765 43210',
              keyboardType: TextInputType.phone,
              onChanged: (v) => viewModel.phone = v,
            ),

            _buildTextField(
              label: 'Email Address',
              hint: 'e.g. patient@example.com',
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => viewModel.email = v,
            ),

            _buildConditionField(viewModel),

            const SizedBox(height: 24),

            // ── Physical Metrics ───────────────────────────────────────────
            _sectionTitle('Physical Metrics'),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Height (cm)',
                    hint: '170',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => viewModel.heightText = v,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Weight (kg)',
                    hint: '70',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => viewModel.weightText = v,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Hand Specifications ────────────────────────────────────────
            _sectionTitle('Hand Specifications'),

            _buildDropdownField(
              label: 'Dominant Hand',
              value: viewModel.dominantHand.isEmpty
                  ? null
                  : viewModel.dominantHand,
              items: const ['Right', 'Left'],
              onChanged: (v) {
                viewModel.dominantHand = v ?? '';
                viewModel.notifyListeners();
              },
            ),

            _buildTextField(
              label: 'Palm Length (cm)',
              hint: '0.0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => viewModel.palmLengthText = v,
            ),

            _buildTextField(
              label: 'Palm Width (cm)',
              hint: '0.0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => viewModel.palmWidthText = v,
            ),

            _buildTextField(
              label: 'Knuckles Length (cm)',
              hint: '0.0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => viewModel.knuckleLengthText = v,
            ),

            const SizedBox(height: 24),

            // ── Notes ──────────────────────────────────────────────────────
            _sectionTitle('Additional Notes'),

            _buildTextField(
              label: 'Notes (Optional)',
              hint: 'Any relevant clinical notes...',
              maxLines: 3,
              onChanged: (v) => viewModel.notes = v,
            ),

            const SizedBox(height: 40),

            // ── Register button ────────────────────────────────────────────
            InkWell(
              onTap: () async {
                if (viewModel.isBusy) return;
                await viewModel.register();
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: kcPrimaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kcPrimaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: viewModel.isBusy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register Patient',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Success screen ─────────────────────────────────────────────────────────
  Widget _buildSuccessView(
      BuildContext context, PatientRegistrationViewModel viewModel) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Registration Complete',
            style:
                TextStyle(color: kcDarkGreyColor, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: kcSuccessColor, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kcLightGrey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('Patient Code',
                      style: TextStyle(
                          fontSize: 16,
                          color: kcMediumGrey,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Text(
                    viewModel.registeredPatient!.patientCode,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kcPrimaryColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(viewModel.registeredPatient!.name,
                      style: const TextStyle(
                          fontSize: 18,
                          color: kcDarkGreyColor,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            InkWell(
              onTap: () => viewModel.confirmAndNavigate(),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: kcPrimaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kcPrimaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('Continue to Session',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kcPrimaryColor)),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? errorText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextEditingController? controller,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: kcDarkGreyColor)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          decoration: _inputDeco(hint),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(errorText,
                style: const TextStyle(color: kcErrorColor, fontSize: 12)),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    String? errorText,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: kcDarkGreyColor)),
        ),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          decoration: _inputDeco('Select'),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(errorText,
                style: const TextStyle(color: kcErrorColor, fontSize: 12)),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  /// Condition dropdown + optional free-text field when "Other" is selected.
  Widget _buildConditionField(PatientRegistrationViewModel viewModel) {
    const conditions = [
      'None',
      'Cervical Radiculopathy',
      'Basal Ganglia Disorder',
      'Carpal Tunnel Syndrome',
      'Brachial Plexus Injury',
      'Peripheral Neuropathy',
      'Thoracic Outlet Syndrome',
      'Cubital Tunnel Syndrome',
      'Radial Nerve Palsy',
      'Ulnar Nerve Palsy',
      'Tennis Elbow (Lateral Epicondylitis)',
      "Golfer's Elbow (Medial Epicondylitis)",
      'Rotator Cuff Tear',
      'Frozen Shoulder (Adhesive Capsulitis)',
      "De Quervain's Tenosynovitis",
      'Trigger Finger',
      "Dupuytren's Contracture",
      'Complex Regional Pain Syndrome (CRPS)',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: const Text('Condition',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: kcDarkGreyColor)),
        ),
        DropdownButtonFormField<String>(
          value: viewModel.condition.isEmpty ? null : viewModel.condition,
          isExpanded: true,
          onChanged: (v) {
            viewModel.condition = v ?? 'None';
            viewModel.notifyListeners();
          },
          decoration: _inputDeco('Select condition'),
          items: conditions
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
        // Show free-text box only when "Other" is selected
        if (viewModel.condition == 'Other') ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: const Text('Please specify condition',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: kcDarkGreyColor)),
          ),
          TextField(
            autofocus: true,
            onChanged: (v) => viewModel.conditionOther = v,
            decoration: _inputDeco('Enter condition name'),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) {
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

  @override
  PatientRegistrationViewModel viewModelBuilder(BuildContext context) =>
      PatientRegistrationViewModel();
}
