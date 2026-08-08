import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/accounts.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/ui/common/app_colors.dart';
import 'package:vital_step/ui/common/ui_helpers.dart';

import 'home_tab_specialist_viewmodel.dart';

class HomeTabSpecialistView extends StackedView<HomeTabSpecialistViewModel> {
  const HomeTabSpecialistView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeTabSpecialistViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Vital Step',
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: ListView(
          children: [
            Image.asset(
              'assets/stethoscope.png',
              height: 200,
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hi ${viewModel.name != null ? ' ${viewModel.name}' : ''}',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: kcPrimaryColor,
                  onPressed: () async {
                    final DialogService dialogService =
                        locator<DialogService>();
                    await dialogService.showCustomDialog(
                        variant: DialogType.addPatient);
                    viewModel.patientAccounts = viewModel.getPatientAccounts();
                  },
                  child: const Text(
                    'Add Patient',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,
            FutureBuilder<List<Accounts>>(
                future: viewModel.patientAccounts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final Accounts account = snapshot.data![index];
                          return MaterialButton(
                            color: Colors.grey.shade400,
                            onPressed: () {
                              final NavigationService navigationService =
                                  locator<NavigationService>();
                              navigationService.navigateToAssesmentView(
                                  isSpecialist: true, patientAccount: account);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(account.user.name!),
                            ),
                          );
                        });
                  }
                  return const CircularProgressIndicator();
                })
          ],
        ),
      ),
    );
  }

  @override
  HomeTabSpecialistViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeTabSpecialistViewModel();

  @override
  void onViewModelReady(HomeTabSpecialistViewModel viewModel) {
    viewModel.patientAccounts = viewModel.getPatientAccounts();
    viewModel.init();
  }
}
