import 'package:get_storage/get_storage.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/login_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _loginService = locator<LoginService>();
  final _accountService = locator<AccountsService>();
  Future runStartupLogic() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final bool killApp = await _accountService.killApp();
      if (killApp) {
        _navigationService.navigateToKillAppView();
        return;
      }
      final isLoggedIn = await _loginService.isLoggedIn();
      if (isLoggedIn) {
        final userType = await _loginService.getUserType();
        if (userType == 'Patient') {
          _navigationService.clearStackAndShow(Routes.homeView);
        } else if (userType == 'Specialist') {
          _navigationService.clearStackAndShow(Routes.homeSpecialistView);
        } else {
          _navigationService.clearStackAndShow(Routes.loginView);
        }
      } else {
        _navigationService.clearStackAndShow(Routes.loginView);
      }
    } catch (e) {
      final dialogService = locator<DialogService>();
      await dialogService.showDialog(
        title: 'Error',
        description: e.toString(),
      );
      final box = GetStorage();
      await box.erase();
      _navigationService.clearStackAndShow(Routes.loginView);
    }
  }
}
