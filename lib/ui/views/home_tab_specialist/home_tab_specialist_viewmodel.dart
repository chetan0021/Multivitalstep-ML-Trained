import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/accounts.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/specialist_service.dart';

class HomeTabSpecialistViewModel extends BaseViewModel {
  late Future<List<Accounts>>? patientAccounts;
  final _specialistService = locator<SpecialistService>();
  String? name;
  void init() async {
    name = await _specialistService.getSpecialistName();
    rebuildUi();
  }

  Future<List<Accounts>> getPatientAccounts() async {
    final List<Accounts> patients = await _specialistService.getAccounts();
    return patients;
  }
}
