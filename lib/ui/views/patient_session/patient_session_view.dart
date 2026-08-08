import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:vital_step/ui/views/patient_session/patient_session_viewmodel.dart';

class PatientSessionView extends StackedView<PatientSessionViewModel> {
  const PatientSessionView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PatientSessionViewModel viewModel,
    Widget? child,
  ) {
    return PopScope(
      // Prevent app closure when patient session is the stack root.
      // Always fall back to home instead of exiting the app.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          NavigationService().clearStackAndShow(
            Routes.homeView,
            arguments: const HomeViewArguments(firstPage: 0),
          );
        }
      },
      child: Scaffold(
        backgroundColor: kcVeryLightGrey,
        appBar: AppBar(
          title: Text(
            viewModel.patient?.patientCode ?? 'Patient Session',
            style: const TextStyle(
              color: kcDarkGreyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: kcDarkGreyColor, size: 20),
            onPressed: () => NavigationService().clearStackAndShow(
              Routes.homeView,
              arguments: const HomeViewArguments(firstPage: 0),
            ),
          ),
        ),
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : viewModel.patient == null
                ? const Center(child: Text('No patient data available'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (viewModel.hasFailedRetries)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFFFB300)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Color(0xFFFFB300), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${viewModel.failedRetryCount} reading(s) could not be synced. Check your connection.',
                                    style: const TextStyle(
                                        fontSize: 13, color: Color(0xFF856404)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _buildProfileCard(viewModel),
                        verticalSpaceMedium,
                        _buildActionButtons(viewModel),
                        verticalSpaceMedium,
                        _buildSessionCountBadge(viewModel),
                        verticalSpaceMedium,
                        _buildRecentReadingsSection(context, viewModel),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileCard(PatientSessionViewModel viewModel) {
    final patient = viewModel.patient!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kcPrimaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: kcPrimaryColor,
                ),
              ),
              horizontalSpaceMedium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    verticalSpaceTiny,
                    Text(
                      '${patient.age} years • ${patient.gender}',
                      style: const TextStyle(
                        color: kcMediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (patient.contact.isNotEmpty) ...[
            verticalSpaceMedium,
            _buildInfoRow(Icons.phone_outlined, 'Contact', patient.contact),
          ],
          if (patient.notes.isNotEmpty) ...[
            verticalSpaceMedium,
            _buildInfoRow(Icons.note_outlined, 'Notes', patient.notes),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: kcMediumGrey),
        horizontalSpaceSmall,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: kcMediumGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              verticalSpaceTiny,
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: kcDarkGreyColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(PatientSessionViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Take Test',
            kcSuccessColor,
            viewModel.takeTest,
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: _buildActionButton(
            'View History',
            kcSecondaryColor,
            viewModel.viewHistory,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCountBadge(PatientSessionViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: premiumCardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Sessions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kcDarkGreyColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: kcPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${viewModel.readings.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kcPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReadingsSection(
      BuildContext context, PatientSessionViewModel viewModel) {
    // Show last 5 readings
    final recentReadings = viewModel.readings.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Readings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kcDarkGreyColor,
              ),
            ),
            Row(
              children: [
                _buildSecondaryActionButton(
                  'Export CSV',
                  kcWarningColor,
                  viewModel.exportCSV,
                ),
                horizontalSpaceSmall,
                _buildSecondaryActionButton(
                  'Edit',
                  kcMediumGrey,
                  viewModel.editPatient,
                ),
              ],
            ),
          ],
        ),
        verticalSpaceMedium,
        if (recentReadings.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: premiumCardDecoration,
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 48,
                    color: kcLightGrey,
                  ),
                  verticalSpaceSmall,
                  Text(
                    'No readings yet',
                    style: TextStyle(
                      color: kcMediumGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...recentReadings.map((reading) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReadingCard(context, reading, viewModel),
              )),
      ],
    );
  }

  Widget _buildSecondaryActionButton(
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildReadingCard(
      BuildContext context, reading, PatientSessionViewModel viewModel) {
    final dateStr = _formatDate(reading.createdAt);
    final avgValue = reading.average.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: kcMediumGrey),
                  horizontalSpaceSmall,
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: kcMediumGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kcPrimaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${reading.hand} • ${reading.posture}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kcPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Reading'),
                          content: const Text(
                              'Delete this reading? This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(_, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(_, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: kcErrorColor)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await viewModel.deleteReading(reading.id);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kcErrorColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 16, color: kcErrorColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          verticalSpaceMedium,
          Row(
            children: [
              _buildTrialValue('T1', reading.trial1),
              horizontalSpaceSmall,
              _buildTrialValue('T2', reading.trial2),
              horizontalSpaceSmall,
              _buildTrialValue('T3', reading.trial3),
              horizontalSpaceSmall,
              _buildAverageValue(avgValue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrialValue(String label, double value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: kcVeryLightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: kcMediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            verticalSpaceTiny,
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 15,
                color: kcDarkGreyColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageValue(String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: kcAccentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              'AVG',
              style: TextStyle(
                fontSize: 11,
                color: kcAccentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            verticalSpaceTiny,
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: kcAccentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  PatientSessionViewModel viewModelBuilder(BuildContext context) =>
      PatientSessionViewModel();

  @override
  void onViewModelReady(PatientSessionViewModel viewModel) {
    viewModel.init();
  }
}
