import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors.dart';

import 'patient_edit_viewmodel.dart';

class PatientEditView extends StackedView<PatientEditViewModel> {
  const PatientEditView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PatientEditViewModel viewModel,
    Widget? child,
  ) {
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
          'Edit Patient',
          style: TextStyle(color: kcDarkGreyColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: viewModel.isBusy
          ? const Center(
              child: CircularProgressIndicator(color: kcPrimaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Patient',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kcDarkGreyColor),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Edit patient information below.',
                    style: TextStyle(fontSize: 15, color: kcMediumGrey),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  _buildField(
                    label: 'Full Name',
                    hint: 'Enter patient name',
                    initialValue: viewModel.name,
                    errorText: viewModel.nameError,
                    onChanged: (val) => viewModel.name = val,
                  ),

                  // Age field
                  _buildField(
                    label: 'Age',
                    hint: 'Enter age',
                    initialValue: viewModel.ageText,
                    keyboardType: TextInputType.number,
                    errorText: viewModel.ageError,
                    onChanged: (val) => viewModel.ageText = val,
                  ),

                  // Gender dropdown
                  _buildDropdown(
                    label: 'Gender',
                    value: viewModel.gender.isEmpty ? null : viewModel.gender,
                    errorText: viewModel.genderError,
                    items: const ['Male', 'Female', 'Other'],
                    onChanged: (val) {
                      viewModel.gender = val ?? '';
                      viewModel.notifyListeners();
                    },
                  ),

                  // Contact field (optional)
                  _buildField(
                    label: 'Contact (Optional)',
                    hint: 'Phone or email',
                    initialValue: viewModel.contact,
                    onChanged: (val) => viewModel.contact = val,
                  ),

                  // Notes field (optional, multi-line)
                  _buildField(
                    label: 'Notes (Optional)',
                    hint: 'Additional information',
                    initialValue: viewModel.notes,
                    maxLines: 3,
                    onChanged: (val) => viewModel.notes = val,
                  ),

                  const SizedBox(height: 40),

                  _buildSaveButton(viewModel),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    String? initialValue,
    String? errorText,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: kcDarkGreyColor,
            ),
          ),
        ),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: _premiumInputDecoration(hint),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: kcErrorColor, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown({
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
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: kcDarkGreyColor,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: _premiumInputDecoration('Select'),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: kcErrorColor, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSaveButton(PatientEditViewModel viewModel) {
    return InkWell(
      onTap: () async {
        if (viewModel.isBusy) return;
        await viewModel.saveChanges();
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
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
        ),
      ),
    );
  }

  InputDecoration _premiumInputDecoration(String hint) {
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
  PatientEditViewModel viewModelBuilder(BuildContext context) =>
      PatientEditViewModel();

  @override
  void onViewModelReady(PatientEditViewModel viewModel) => viewModel.init();
}
