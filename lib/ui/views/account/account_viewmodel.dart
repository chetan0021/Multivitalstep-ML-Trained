import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/profile.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/login_service.dart';
import 'package:vital_step/services/mode_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountViewModel extends BaseViewModel {
  final _logger = getLogger("AccountViewModel");
  final DialogService _dialogService = locator<DialogService>();
  final _accountService = locator<AccountsService>();
  final _modeService = locator<ModeService>();
  Profile? profile;

  bool get isPatientMode => _modeService.isPatientMode;
  String? get activePatientCode => _modeService.activePatientCode;
  String? get activePatientName => _modeService.activePatientName;
  String? get accessCode => profile?.access_code;

  void togglePatientMode(bool value) {
    _modeService.setPatientMode(value);
    notifyListeners();
  }

  Future<void> init() async {
    setBusy(true);
    profile = await _accountService.getAccountDetails();
    setBusy(false);
    notifyListeners();
  }

  Map<String, dynamic> getDevices(Profile prof) {
    final devices = prof.device;
    if (devices == null || devices.isEmpty) {
      return {'No devices': 'Click to add a device'};
    }
    final deviceMap = <String, dynamic>{};
    for (final device in devices) {
      deviceMap[device.id.toString()] = device.deviceName;
    }
    return deviceMap;
  }

  /// Shows a confirmation dialog before signing out.
  Future<void> signOut() async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Log Out',
      description: 'Are you sure you want to log out?',
      confirmationTitle: 'Log Out',
      cancelTitle: 'Cancel',
      barrierDismissible: true,
    );
    if (response == null || !response.confirmed) return;
    final loginService = locator<LoginService>();
    await loginService.signOut();
  }

  /// Shows two confirmation dialogs before deleting the account —
  /// extra safety for an irreversible destructive action.
  Future<void> deleteAccount() async {
    final first = await _dialogService.showConfirmationDialog(
      title: 'Delete Account',
      description:
          'This will permanently delete your account and all your data. This cannot be undone.',
      confirmationTitle: 'Continue',
      cancelTitle: 'Cancel',
      barrierDismissible: true,
    );
    if (first == null || !first.confirmed) return;

    final second = await _dialogService.showConfirmationDialog(
      title: 'Are you absolutely sure?',
      description:
          'All your assessments, test results and account data will be permanently deleted.',
      confirmationTitle: 'Yes, Delete',
      cancelTitle: 'No, Keep Account',
      barrierDismissible: true,
    );
    if (second == null || !second.confirmed) {
      _logger.i('User cancelled account deletion at second confirmation');
      return;
    }

    await _accountService.deleteAccount();
  }

  Future<void> contactSupport() async {
    const phoneNumber = "919916387717";
    const message = "Hello Vital Step Support, I need help with...";
    final url = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      _logger.e("Could not launch WhatsApp: $e");
    }
  }

  Future<void> openTutorial() async {
    final url = Uri.parse(
        "https://drive.google.com/file/d/1osdagMbTrg-geKEcOsgetIH636LCfA1k/view?usp=sharing");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      _logger.e("Could not open tutorial: $e");
    }
  }
}
