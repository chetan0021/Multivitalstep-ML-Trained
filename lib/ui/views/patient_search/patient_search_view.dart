import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/research_patient.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'patient_search_viewmodel.dart';

class PatientSearchView extends StackedView<PatientSearchViewModel> {
  const PatientSearchView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, PatientSearchViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: kcVeryLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Patient Search",
          style: TextStyle(
            color: kcDarkGreyColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TextField(
              onChanged: viewModel.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by patient code or name...',
                hintStyle: const TextStyle(color: kcMediumGrey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: kcMediumGrey),
                filled: true,
                fillColor: kcVeryLightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Results
          Expanded(
            child: viewModel.isBusy
                ? const Center(
                    child: CircularProgressIndicator(
                      color: kcPrimaryColor,
                    ),
                  )
                : viewModel.searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildPatientList(viewModel),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.navigateToRegistration,
        backgroundColor: kcPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: kcLightGrey,
            ),
            verticalSpaceMedium,
            const Text(
              "No patients found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kcDarkGreyColor,
              ),
            ),
            verticalSpaceSmall,
            const Text(
              "Tap '+' to register a new patient.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kcMediumGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList(PatientSearchViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final patient = viewModel.searchResults[index];
        return _buildPatientCard(patient, viewModel);
      },
    );
  }

  Widget _buildPatientCard(
      ResearchPatient patient, PatientSearchViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => viewModel.selectPatient(patient),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      patient.name.isNotEmpty
                          ? patient.name[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        color: kcPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                horizontalSpaceMedium,
                // Patient info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.patientCode,
                        style: const TextStyle(
                          color: kcDarkGreyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient.name,
                        style: const TextStyle(
                          color: kcDarkGreyColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${patient.age} years • ${patient.gender}',
                        style: const TextStyle(
                          color: kcMediumGrey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to select',
                        style: TextStyle(
                          color: kcPrimaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Select icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: kcPrimaryColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  PatientSearchViewModel viewModelBuilder(BuildContext context) =>
      PatientSearchViewModel();

  @override
  void onViewModelReady(PatientSearchViewModel viewModel) => viewModel.init();
}
