import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/spcialist_profile.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/login_service.dart';
import 'package:vital_step/services/specialist_service.dart';

class AccountSpecialistViewModel extends BaseViewModel {
  ProfileSpecialist? profile;
  final SpecialistService _specialistService = locator<SpecialistService>();
  Future<void> init() async {
    profile = await _specialistService.getSpecialistProfile();
    notifyListeners();
  }

  void signOut() async {
    final loginService = locator<LoginService>();
    await loginService.signOut();
  }
}
