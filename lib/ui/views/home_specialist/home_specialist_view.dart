import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors.dart';

import 'home_specialist_viewmodel.dart';

class HomeSpecialistView extends StackedView<HomeSpecialistViewModel> {
  const HomeSpecialistView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeSpecialistViewModel viewModel,
    Widget? child,
  ) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (viewModel.selectedIndex != 0) {
            viewModel.onItemTapped(0);
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: viewModel.screens[viewModel.selectedIndex],
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(92, 158, 158, 158),
                  offset: Offset(0, 0),
                  blurRadius: 6,
                )
              ],
              color: Colors.white,
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  label: 'Account',
                ),
              ],
              selectedItemColor: kcPrimaryColor,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              selectedLabelStyle:
                  const TextStyle(color: kcPrimaryColor, fontSize: 12),
              selectedIconTheme: const IconThemeData(
                size: 17,
              ),
              unselectedIconTheme: const IconThemeData(size: 17),
              unselectedLabelStyle:
                  const TextStyle(color: Colors.grey, fontSize: 12),
              currentIndex: viewModel.selectedIndex,
              onTap: (selectedIndex) {
                viewModel.onItemTapped(selectedIndex);
              },
            ),
          ),
        ));
  }

  @override
  HomeSpecialistViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeSpecialistViewModel();
}
