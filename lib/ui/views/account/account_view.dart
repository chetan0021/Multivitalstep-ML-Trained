import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:vital_step/ui/views/account/account_viewmodel.dart';

class AccountView extends StackedView<AccountViewModel> {
  const AccountView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AccountViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: kcDarkGreyColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(viewModel),
                  verticalSpaceMedium,
                  if (viewModel.accessCode != null)
                    _buildAccessCodeCard(context, viewModel),
                  if (viewModel.accessCode != null) verticalSpaceMedium,
                  _buildSettingsGroup([
                    _buildSettingsItem(
                      icon: Icons.person_outline,
                      title: "Edit Profile",
                      onTap: () => NavigationService()
                          .navigateToSignUpView(profile: viewModel.profile),
                    ),
                    _buildSettingsItem(
                      icon: Icons.watch_outlined,
                      title: "My Devices",
                      onTap: () => NavigationService()
                          .navigateToDeviceView(showExistingDevices: true),
                    ),
                  ]),
                  verticalSpaceMedium,
                  _buildSettingsGroup([
                    _buildSettingsItem(
                      icon: Icons.contact_support_outlined,
                      title: "Contact Support",
                      onTap: () => viewModel.contactSupport(),
                    ),
                    _buildSettingsItem(
                      icon: Icons.play_circle_outline,
                      title: "Tutorial on Device",
                      onTap: () => viewModel.openTutorial(),
                    ),
                    _buildSettingsItem(
                      icon: Icons.question_answer_outlined,
                      title: "FAQs",
                      onTap: () => NavigationService().navigateToFaqView(),
                    ),
                  ]),
                  verticalSpaceMedium,
                  _buildSettingsGroup([_buildModeSwitchItem(viewModel)]),
                  verticalSpaceMedium,
                  _buildActionButtons(viewModel),
                  verticalSpaceLarge,
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(AccountViewModel viewModel) {
    final profile = viewModel.profile;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: premiumCardDecoration,
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: kcSecondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 40, color: kcSecondaryColor),
          ),
          horizontalSpaceMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? "User",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  profile?.email ?? "No email provided",
                  style: const TextStyle(color: kcMediumGrey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessCodeCard(
      BuildContext context, AccountViewModel viewModel) {
    final code = viewModel.accessCode!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kcPrimaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_2_rounded,
                    color: kcPrimaryColor, size: 20),
              ),
              horizontalSpaceSmall,
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Patient ID',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kcDarkGreyColor,
                      ),
                    ),
                    Text(
                      'Share this QR so your specialist can add you',
                      style: TextStyle(fontSize: 11, color: kcMediumGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpaceMedium,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QR Code drawn with CustomPainter — no extra package needed
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kcLightGrey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    size: 120,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: kcDarkGreyColor,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: kcDarkGreyColor,
                    ),
                  ),
                ),
              ),
              horizontalSpaceMedium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Access Code',
                      style: TextStyle(fontSize: 12, color: kcMediumGrey),
                    ),
                    verticalSpaceTiny,
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kcDarkGreyColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    verticalSpaceSmall,
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Access code copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: kcPrimaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_rounded,
                                size: 14, color: kcPrimaryColor),
                            SizedBox(width: 4),
                            Text(
                              'Copy Code',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: kcPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    verticalSpaceSmall,
                    const Text(
                      'Ask your specialist to scan this QR or enter the code above to link your account.',
                      style: TextStyle(
                          fontSize: 11, color: kcMediumGrey, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: premiumCardDecoration,
      child: Column(
        children: items.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget item = entry.value;
          return Column(
            children: [
              item,
              if (idx < items.length - 1)
                Divider(height: 1, color: Colors.grey.shade100, indent: 60),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: kcMediumGrey, size: 22),
            horizontalSpaceMedium,
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right, color: kcLightGrey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitchItem(AccountViewModel viewModel) {
    final isOn = viewModel.isPatientMode;
    final hasPatient = viewModel.activePatientName != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle row — same style as other settings items
        InkWell(
          onTap: () {
            viewModel.togglePatientMode(!isOn);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.science_outlined,
                    color: isOn ? kcPrimaryColor : kcMediumGrey, size: 22),
                horizontalSpaceMedium,
                const Expanded(
                  child: Text(
                    'Patient Session Mode',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                Switch(
                  value: isOn,
                  onChanged: (val) => viewModel.togglePatientMode(val),
                  activeColor: kcPrimaryColor,
                ),
              ],
            ),
          ),
        ),
        // When mode is ON, show patient entry as a sub-item
        if (isOn) ...[
          Divider(height: 1, color: Colors.grey.shade100, indent: 60),
          InkWell(
            onTap: () =>
                NavigationService().navigateTo(Routes.patientSearchView),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.person_search_rounded,
                      color: kcPrimaryColor, size: 22),
                  horizontalSpaceMedium,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Patient Search',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: kcPrimaryColor)),
                        if (hasPatient)
                          Text(
                            'Active: ${viewModel.activePatientCode} \u2022 ${viewModel.activePatientName}',
                            style: const TextStyle(
                                fontSize: 12, color: kcMediumGrey),
                          )
                        else
                          const Text('Tap to search or register a patient',
                              style:
                                  TextStyle(fontSize: 12, color: kcMediumGrey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: kcLightGrey, size: 20),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(AccountViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton(
            onPressed: () => viewModel.signOut(),
            style: TextButton.styleFrom(
              backgroundColor: kcBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              "Log Out",
              style: TextStyle(
                  color: kcErrorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
        verticalSpaceSmall,
        TextButton(
          onPressed: () => viewModel.deleteAccount(),
          child: const Text(
            "Delete Account",
            style: TextStyle(color: kcMediumGrey, fontSize: 13),
          ),
        ),
      ],
    );
  }

  @override
  AccountViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AccountViewModel();

  @override
  void onViewModelReady(AccountViewModel viewModel) {
    viewModel.init();
  }
}
