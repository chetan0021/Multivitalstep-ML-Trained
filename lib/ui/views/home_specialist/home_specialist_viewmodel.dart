import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/views/account_specialist/account_specialist_view.dart';
import 'package:vital_step/ui/views/home_tab_specialist/home_tab_specialist_view.dart';

class HomeSpecialistViewModel extends BaseViewModel {
  int selectedIndex = 0;
  final List<Widget> screens = [
    const HomeTabSpecialistView(),
    const AccountSpecialistView(),
  ];

  void onItemTapped(
    int index,
  ) {
    selectedIndex = index;
    rebuildUi();
  }
}
