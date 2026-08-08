import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/Model/accounts.dart';
import 'package:vital_step/app/app.router.dart';

import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';

import 'assesment_viewmodel.dart';

class AssesmentView extends StackedView<AssesmentViewModel> {
  const AssesmentView({
    Key? key,
    this.isSpecialist,
    this.patientAccount,
  }) : super(key: key);
  final bool? isSpecialist;
  final Accounts? patientAccount;

  @override
  Widget builder(
    BuildContext context,
    AssesmentViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: kcPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                "Assessments",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: kcPrimaryGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      bottom: -20,
                      child: Icon(Icons.assignment_outlined, size: 150, color: Colors.white.withOpacity(0.05)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: viewModel.navigateToGlobalHistory,
                icon: const Icon(Icons.history_rounded, color: Colors.white),
              ),
              if (isSpecialist != true)
                IconButton(
                  onPressed: () => NavigationService().navigateToDeviceView(showExistingDevices: false),
                  icon: const Icon(Icons.watch_outlined, color: Colors.white),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: FutureBuilder<List<Assessment>?>(
                future: viewModel.devicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator(color: kcPrimaryColor)));
                  } else if (snapshot.hasError) {
                    return _buildErrorState();
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(viewModel);
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (c, i) => verticalSpaceSmall,
                      itemBuilder: (context, index) {
                        final assessment = snapshot.data![index];
                        return _buildAssessmentCard(context, viewModel, assessment, index);
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isSpecialist == true 
          ? null 
          : null,
    );
  }

  Widget _buildAssessmentCard(BuildContext context, AssesmentViewModel viewModel, Assessment assessment, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: kcLightGrey.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kcPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text("${index + 1}", style: const TextStyle(color: kcPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assessment.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kcDarkGreyColor)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.person_pin_circle_outlined, size: 12, color: kcMediumGrey.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(assessment.posture, style: const TextStyle(color: kcMediumGrey, fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: kcLightGrey, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(assessment.status, style: TextStyle(color: assessment.status == "Active" ? kcSuccessColor : kcMediumGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.bar_chart_rounded,
                color: kcSecondaryColor,
                onTap: () => NavigationService().navigateToAssessmentHistoryView(assessment: assessment, patientId: patientAccount?.user.id),
              ),
              if (isSpecialist != true && assessment.currentlyActive == true) ...[
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.play_arrow_rounded,
                  color: kcPrimaryColor,
                  isFilled: true,
                  onTap: () => viewModel.takeTest(assessment),
                ),
              ],
              if (isSpecialist == true) ...[
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: kcErrorColor,
                  onTap: () => viewModel.deleteAssessment(assessmentId: assessment.id.toString()),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap, bool isFilled = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isFilled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isFilled ? Colors.white : color, size: 20),
      ),
    );
  }

  Widget _buildEmptyState(AssesmentViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 80, color: kcLightGrey),
          verticalSpaceMedium,
          const Text("No Assessments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kcDarkGreyColor)),
          verticalSpaceSmall,
          const Text("Start your first test to see it here.", style: TextStyle(color: kcMediumGrey)),
          if (isSpecialist != true) ...[
            verticalSpaceLarge,
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                ),
                onPressed: viewModel.createSelfAssessment,
                child: const Text("Start Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(child: Text("Error fetching assessments", style: TextStyle(color: kcErrorColor)));
  }

  @override
  AssesmentViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AssesmentViewModel();

  @override
  void onViewModelReady(AssesmentViewModel viewModel) async {
    viewModel.patientUserId = patientAccount?.user.id;
    viewModel.isSpecialist = isSpecialist;
    viewModel.devicesFuture = viewModel.init();
  }
}
