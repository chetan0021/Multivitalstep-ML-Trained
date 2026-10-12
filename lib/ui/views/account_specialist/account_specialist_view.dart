import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/ui/common/NavOption.dart' as clickable_nav_option;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vital_step/ui/common/ScreenHeading.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';
import 'package:vital_step/ui/widgets/common/nav_option/nav_option.dart';

import 'account_specialist_viewmodel.dart';

class AccountSpecialistView extends StackedView<AccountSpecialistViewModel> {
  const AccountSpecialistView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AccountSpecialistViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(25),
        color: kcPrimaryColor.withAlpha(10),
        child: ListView(
          children: [
            ScreenHeading(heading: "Account", showBackButton: false),
            Container(
              padding: const EdgeInsets.only(bottom: 10, top: 30),
              child: Row(
                children: [
                  const Text(
                    "PROFILE",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      NavigationService().navigateToSignUpSpecialistView(
                          profile: viewModel.profile);
                    },
                    child: Text(
                      "Edit Profile!",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
            viewModel.profile == null
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        NavOption("Profile", Icons.person_outline,
                            data: viewModel.profile!.toJson()),
                      ],
                    ),
                  ),
            Container(
              padding: const EdgeInsets.only(bottom: 10, top: 30),
              child: const Text(
                "ABOUT",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'App_support@SP4ameya.com',
                  query:
                      'subject=Support Request&body=Hello, I need help with...',
                );

                if (await canLaunch(emailLaunchUri.toString())) {
                  await launch(emailLaunchUri.toString());
                } else {
                  Fluttertoast.showToast(msg: "Could not launch email");
                }
              },
              child: Container(
                color: Colors.white,
                child: const Column(
                  children: [
                    NavOption(
                      "Contact Us",
                      Icons.contact_page_outlined,
                      data: {
                        "Email": "App_support@SP4ameya.com",
                        "Phone Number": "+91 99163 87717"
                      },
                    ),
                  ],
                ),
              ),
            ),
            verticalSpaceMedium,
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  clickable_nav_option.NavOption("Logout", Icons.logout, () {
                    viewModel.signOut();
                  }),
                ],
              ),
            ),
            verticalSpaceMedium,
          ],
        ),
      ),
    );
  }

  @override
  AccountSpecialistViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AccountSpecialistViewModel();

  @override
  void onViewModelReady(AccountSpecialistViewModel viewModel) {
    viewModel.init();
  }
}
