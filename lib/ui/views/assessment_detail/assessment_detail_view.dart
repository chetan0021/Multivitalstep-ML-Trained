import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/Model/Comment.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';

import 'assessment_detail_viewmodel.dart';

class AssessmentDetailView extends StackedView<AssessmentDetailViewModel> {
  const AssessmentDetailView(
      {Key? key,
      required this.assessment,
      this.patientUserId,
      this.isSpecialist})
      : super(key: key);
  final Assessment assessment;
  final int? patientUserId;
  final bool? isSpecialist;

  @override
  Widget builder(
    BuildContext context,
    AssessmentDetailViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          assessment.type,
          style: const TextStyle(color: kcDarkGreyColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kcDarkGreyColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(viewModel),
            verticalSpaceMedium,
            _buildDatesCard(viewModel),
            verticalSpaceMedium,
            _buildActionButtons(context, viewModel),
            verticalSpaceLarge,
            _buildSectionHeader("Remarks"),
            verticalSpaceSmall,
            _buildRemarksList(viewModel),
            verticalSpaceLarge,
            if (isSpecialist == true) _buildAddCommentButton(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(AssessmentDetailViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kcPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kcPrimaryColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem("BMI", vm.busy(vm.calculatingBMI) ? "..." : vm.bmi.toString(), kcPrimaryColor),
          Container(width: 1, height: 40, color: kcPrimaryColor.withOpacity(0.1)),
          _buildStatItem("Status", "Active", kcSecondaryColor), // Placeholder for status if available
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: kcMediumGrey, fontSize: 12, fontWeight: FontWeight.w600)),
          verticalSpaceTiny,
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDatesCard(AssessmentDetailViewModel vm) {
    if (vm.busy(vm.calculatingDates)) {
      return const Center(child: CircularProgressIndicator(color: kcPrimaryColor));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: premiumCardDecoration,
      child: Column(
        children: [
          _buildDateRow("Started On", vm.startDate, Icons.calendar_today_outlined),
          const Divider(height: 30),
          _buildDateRow("Last Entry", vm.endDate, Icons.history),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String date, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kcSecondaryColor),
        horizontalSpaceSmall,
        Text(label, style: const TextStyle(color: kcMediumGrey, fontSize: 14)),
        const Spacer(),
        Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AssessmentDetailViewModel vm) {
    return Column(
      children: [
        _buildElevatedButton(
          "See Assessment History",
          Icons.bar_chart_rounded,
          () => NavigationService().navigateToAssessmentHistoryView(assessment: assessment, patientId: patientUserId),
          kcPrimaryColor,
        ),
        if (isSpecialist != true) ...[
          verticalSpaceSmall,
          _buildElevatedButton(
            "Set Reminder",
            Icons.notifications_active_outlined,
            () => locator<DialogService>().showCustomDialog(variant: DialogType.setReminder, data: assessment.toJson()),
            kcSecondaryColor,
          ),
        ],
      ],
    );
  }

  Widget _buildElevatedButton(String label, IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            horizontalSpaceSmall,
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kcDarkGreyColor));
  }

  Widget _buildRemarksList(AssessmentDetailViewModel vm) {
    return FutureBuilder<List<Comment>>(
      future: vm.comments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kcPrimaryColor));
        }

        final comments = snapshot.data ?? [];
        if (comments.isEmpty) {
          return _buildEmptyRemarks();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: premiumCardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: kcSecondaryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: kcSecondaryColor, size: 16),
                      ),
                      horizontalSpaceSmall,
                      Text(vm.getDateAndTime(comment.createdAt.toLocal()), style: const TextStyle(color: kcMediumGrey, fontSize: 12)),
                      const Spacer(),
                      if (isSpecialist == true)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: kcLightGrey, size: 20),
                          onPressed: () async {
                            await vm.deleteRemark(id: comment.id);
                            vm.comments = null;
                            vm.rebuildUi();
                            vm.comments = vm.getComments(assessmentId: assessment.id);
                          },
                        )
                    ],
                  ),
                  verticalSpaceTiny,
                  Text(comment.remarks, style: const TextStyle(fontSize: 15, color: kcDarkGreyColor, height: 1.4)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyRemarks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: premiumCardDecoration,
      child: const Column(
        children: [
          Icon(Icons.chat_bubble_outline, size: 40, color: kcLightGrey),
          verticalSpaceSmall,
          Text("No comments yet", style: TextStyle(color: kcMediumGrey)),
        ],
      ),
    );
  }

  Widget _buildAddCommentButton(AssessmentDetailViewModel vm) {
    return _buildElevatedButton(
      "Add Remark",
      Icons.add_comment_rounded,
      () async {
        final dialogService = locator<DialogService>();
        await dialogService.showCustomDialog(variant: DialogType.addComment, data: assessment.toJson());
        vm.comments = null;
        vm.rebuildUi();
        vm.comments = vm.getComments(assessmentId: assessment.id);
      },
      kcDarkGreyColor,
    );
  }

  @override
  AssessmentDetailViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AssessmentDetailViewModel();

  @override
  void onViewModelReady(AssessmentDetailViewModel viewModel) {
    viewModel.patientUserId = patientUserId;
    viewModel.getBMI();
    viewModel.getDates(assessmentId: assessment.id);
    viewModel.comments = viewModel.getComments(assessmentId: assessment.id);
  }
}
