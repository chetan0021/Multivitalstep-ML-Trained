import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'kill_app_viewmodel.dart';

class KillAppView extends StackedView<KillAppViewModel> {
  const KillAppView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    KillAppViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'The App has been killed by the developer.\nHe has not been paid the amount he was promised. Please contact the developer to resolve the issue. \nContact - 6396116270 \nThank you.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                viewModel.contactDeveloper();
              },
              child: const Text('Contact Developer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  KillAppViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      KillAppViewModel();
}
