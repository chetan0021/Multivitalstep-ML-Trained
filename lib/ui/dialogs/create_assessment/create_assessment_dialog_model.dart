import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/specialist_service.dart';

class CreateAssessmentDialogModel extends BaseViewModel {
  final _specialistService = locator<SpecialistService>();
  final _accountsService = locator<AccountsService>();
  String? selectedPosture = "Full Body Weight";
  String? selectedAssessmentType = "Daily";
  final List<String> assessmentTypes = ["Weekly", "Monthly", "Daily"];
  final List<String> postureTypes = [
    "Full Body Weight",
    "Full Arm Weight",
    "Forward Loading",
    "Backward Off Loading",
    "Side Loading",
    "Side Off Loading",
    "sitting"
  ];

  Future<bool> createAssessment(int? patientId) async {
    setBusy(true);
    if (selectedPosture == null || selectedAssessmentType == null) {
      Fluttertoast.showToast(
          msg: "Please select a posture and assessment type");
      setBusy(false);
      return false;
    }
    try {
      // If no patientId passed (self-assessment), use the logged-in user's own ID
      int resolvedPatientId = patientId ?? (await _getOwnUserId());
      await _specialistService.createAssessment(
          selectedPosture!, selectedAssessmentType!, resolvedPatientId.toString());
      setBusy(false);
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to create assessment");
      setBusy(false);
      return false;
    }
  }

  Future<int> _getOwnUserId() async {
    final profile = await _accountsService.getAccountDetails();
    return profile.id ?? 0;
  }
}
