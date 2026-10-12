import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/accounts_service.dart';

class ExistingDevicesModel extends BaseViewModel {
  final _accountsService = locator<AccountsService>();
  List<String>? devices;
  Future<List<String>?> init() async {
    // devices = await _accountsService.getDevices();
    return devices;
  }
}
