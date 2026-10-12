import 'package:stacked/stacked.dart';
import 'package:vital_step/Model/Comment.dart';
import 'package:vital_step/Model/test.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:vital_step/services/specialist_service.dart';

class AssessmentDetailViewModel extends BaseViewModel {
  final String calculatingBMI = "Calculating";
  final String calculatingDates = "CalculatingDates";
  int? patientUserId;
  String bmi = "Calculating";
  String startDate = "Calculating";
  String endDate = "Calculating";
  final _accountService = locator<AccountsService>();
  final _apiCallsService = locator<ApiCallsService>();
  final _specialistService = locator<SpecialistService>();
  Future<List<Comment>>? comments;

  void getBMI() async {
    setBusyForObject(calculatingBMI, true);
    final profile =
        await _accountService.getAccountDetails(patientUserId: patientUserId);
    final height = profile.height; // height is in CMS
    final weight = profile.weight; // Weight is in KGs
    final double heightInMeters = height / 100;
    final double bmi = weight / (heightInMeters * heightInMeters);
    this.bmi = bmi.toStringAsFixed(2);
    setBusyForObject(calculatingBMI, false);
    rebuildUi();
  }

  void getDates({required int assessmentId}) async {
    setBusyForObject(calculatingDates, true);
    final test = await _apiCallsService.getAllAssessmentTests(
        assessmentId: assessmentId);
    startDate = getEarliestDate(test);
    endDate = getLastDate(test);
    setBusyForObject(calculatingDates, false);
    rebuildUi();
  }

  String getEarliestDate(List<Test> assessments) {
    if (assessments.isEmpty) return "No assessments found";
    assessments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final startingDate = assessments.first.createdAt;
    return "${startingDate.day} - ${startingDate.month} - ${startingDate.year}";
  }

  String getLastDate(List<Test> assessments) {
    if (assessments.isEmpty) return "No assessments found";
    assessments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final lastDate = assessments.last.createdAt;
    return "${lastDate.day} - ${lastDate.month} - ${lastDate.year}";
  }

  Future<List<Comment>> getComments({required int assessmentId}) async {
    return await _apiCallsService.getComments(assessmentId: assessmentId);
  }

  getDateAndTime(DateTime local) {
    return "${local.day}-${local.month}-${local.year} ${local.hour}:${local.minute}";
  }

  deleteRemark({required int id}) async {
    return await _specialistService.deleteRemark(remarkId: id);
  }
}
