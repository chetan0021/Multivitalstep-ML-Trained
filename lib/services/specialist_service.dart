import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/accounts.dart';
import 'package:vital_step/Model/spcialist_profile.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/login_service.dart';
import 'package:vital_step/ui/common/app_strings.dart';

class SpecialistService {
  final _logger = getLogger("SpecialistService");
  final box = GetStorage();
  final _loginService = locator<LoginService>();
  final _dialogService = locator<DialogService>();
  Future<ProfileSpecialist> getSpecialistProfile() async {
    final String userId = (await _loginService.getUserId())!;
    final Response response = await get(
      Uri.parse('$apiBaseUrl/specialist/$userId'),
      headers: <String, String>{'accept': 'application/json'},
    );
    _logger.i(response.body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final ProfileSpecialist profile = ProfileSpecialist.fromJson(json);
      return profile;
    } else {
      _logger.e(
          'Failed to load account details, status code: ${response.statusCode}');

      throw Exception('Failed to load account details');
    }
  }

  Future<List<Accounts>> getAccounts() async {
    final ProfileSpecialist profileSpecialist = await getSpecialistProfile();
    return profileSpecialist.accounts!;
    // List<Profile> patients = [];
    // for (var account in profileSpecialist.accounts!) {
    //   patients.add(account.user);
    // }
    // return patients;
  }

  Future<String?> getSpecialistName() async {
    final ProfileSpecialist profileSpecialist = await getSpecialistProfile();
    return profileSpecialist.name;
  }

  Future<void> addPatient(
      {required String patientEmail, required String patientAccessCode}) async {
    final String userId = (await _loginService.getUserId())!;
    final cookie = await box.read("cookie");
    final Response response = await post(
      Uri.parse('$apiBaseUrl/accountAccess/'),
      headers: <String, String>{
        'accept': 'application/json',
        "Content-Type": "application/json",
        "Cookie": cookie
      },
      body: jsonEncode({
        'email': patientEmail,
        'accessCode': patientAccessCode,
        "specialistId": int.parse(userId)
      }),
    );
    _logger.i(response.body);
    if (response.statusCode == 200) {
      return;
    } else {
      _logger.e('Failed to add patient, status code: ${response.statusCode}');
      throw Exception('Failed to add patient, ${response.statusCode}');
    }
  }

  Future<void> deleteAccountAccess({int? id}) async {
    final cookie = box.read("cookie");
    final url = '$apiBaseUrl/accountAccess/$id';
    final response = await delete(Uri.parse(url), headers: <String, String>{
      'accept': 'application/json',
      "Cookie": cookie
    });

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "User Deleted succesfully");
      NavigationService().clearStackAndShow(Routes.homeSpecialistView);
      return;
    } else {
      Fluttertoast.showToast(
          msg: "Unable to delete the user ${response.statusCode}");
      _logger.e(
          'Failed to delete account access, status code: ${response.statusCode}');
    }
  }

  Future<void> createAssessment(
      String posture, String assessmentType, String patientId) async {
    const url = "$apiBaseUrl/assessment";
    final cookie = await box.read("cookie");
    final Response response = await post(
      Uri.parse(url),
      headers: <String, String>{
        'accept': 'application/json',
        "Content-Type": "application/json",
        "Cookie": cookie
      },
      body: jsonEncode({
        'userId': int.parse(patientId),
        'posture': posture,
        'type': assessmentType,
      }),
    );
    _logger.i(response.body);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Assessment created successfully");
      return;
    } else {
      _logger.e(
          'Failed to create assessment, status code: ${response.statusCode}');
      throw Exception('Failed to create assessment');
    }
  }

  deleteAssessment({required String assessmentId}) async {
    final cookie = box.read('cookie');
    final url = '$apiBaseUrl/assessment/$assessmentId';
    final response = await delete(Uri.parse(url), headers: <String, String>{
      'accept': 'application/json',
      "Cookie": cookie
    });
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Assessment deleted successfully");
    } else {
      _logger.e(
          'Failed to delete assessment, status code: ${response.statusCode}');
      Fluttertoast.showToast(
          msg:
              "Failed to delete assessment,status Code ${response.statusCode}");
    }
  }

  Future<void> addComment(
      {required String comment, required int assessmentId}) async {
    final assignerId = box.read("userId")?.toString() ?? "";
    final cookie = box.read("cookie");
    const url = "$apiBaseUrl/remarks";
    final response = await http.post(Uri.parse(url),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "Cookie": cookie
        },
        body: jsonEncode({
          "AssignerId": int.parse(assignerId),
          "assessmentId": assessmentId,
          "remarks": comment
        }));
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Comment Added Successfully");
    } else {
      _logger.e("Unable to post comment ${response.statusCode}");
      throw (response.statusCode);
    }
  }

  deleteRemark({required int remarkId}) async {
    final cookie = box.read("cookie");
    final url = "$apiBaseUrl/remarks/${remarkId.toString()}";
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        "Cookie": cookie
      },
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Comment deleted Successfully");
    } else {
      _logger.e("Unable to delete comment ${response.statusCode}");
      Fluttertoast.showToast(msg: "unable to delete the remark");
    }
  }

  updateProfile(ProfileSpecialist signUpInfo) async {
    final cookie = box.read('cookie').toString();
    var headers = {
      "accept": "application/json",
      'Content-Type': 'application/json',
      "cookie": cookie,
    };
    final userId = box.read('userId')?.toString() ?? "";
    final address = '$apiBaseUrl/specialist/$userId';
    var request = http.Request('PUT', Uri.parse(address));
    var json = signUpInfo.toJson();
    json.removeWhere((key, value) {
      return value == null || value == "";
    });
    request.body = jsonEncode(json);
    request.headers.addAll(headers);

    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Profile Updated Successfully");
    } else {
      _logger
          .e('Failed to update profile, status code: ${response.statusCode}');
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Error Updating Profile',
        description: 'An error occurred',
      );
    }
  }

  Future<void> signUp(ProfileSpecialist signUpInfo) async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request =
        http.Request('POST', Uri.parse('$apiBaseUrl/specialist-queue'));

    var signUpJson = signUpInfo.toJson();
    signUpJson.removeWhere((key, value) {
      return value == null || value == "";
    });

    request.body = jsonEncode(signUpJson);
    _logger.i('Request body: ${request.body}');
    request.headers.addAll(headers);

    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final DialogService dialogService = locator<DialogService>();
      dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'SignUp Successful ',
        description:
            'Your profile has been sent for approval, our team will reach out to you soon',
      );
    } else if (response.statusCode == 404) {
      _logger.e(
          'Failed to create a Account, status code: ${response.statusCode}, Account Already exists');
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Unable to create a new account',
        description: 'Unable to create a new account, Account Already exists',
      );
    } else {
      _logger.e('Failed to Signup, status code: ${response.statusCode}');
      _logger.e('Unable to sign Up: ${response.body}');
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Error Signing Up',
        description: 'An error occurred',
      );
    }
  }
}
