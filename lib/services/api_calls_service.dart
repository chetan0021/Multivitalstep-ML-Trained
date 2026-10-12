import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';

import 'package:http/http.dart' as http;
import 'package:stacked_services/stacked_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vital_step/Model/Assessment.dart';
import 'package:vital_step/Model/Comment.dart';
import 'package:vital_step/Model/accounts.dart';
import 'package:vital_step/Model/profile.dart';
import 'package:vital_step/Model/test.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/login_service.dart';
import 'package:vital_step/ui/common/app_strings.dart';

class ApiCallsService {
  final _loginService = locator<LoginService>();
  final box = GetStorage();
  final _logger = getLogger("ApiCallsService");
  final cookie = GetStorage().read('cookie');
  final _accountsService = locator<AccountsService>();

  Future<List<Assessment>> getAllUserAssessments({int? patientUserId}) async {
    final Profile profile =
        await _accountsService.getAccountDetails(patientUserId: patientUserId);
    List<Assessment> assessments = [];
    for (var assessment in profile.assessment!) {
      assessments.add(assessment);
    }
    _logger.i(assessments);
    try {
      final assessmentAndQueueIds = await getUserQueue();
      for (var assessmentAndQueueId in assessmentAndQueueIds) {
        for (var assessment in assessments) {
          if (assessmentAndQueueId["assessmentId"] == assessment.id) {
            assessment.queueId = assessmentAndQueueId["queueId"];
            assessment.currentlyActive = true;
          }
        }
      }
      if (assessmentAndQueueIds.isEmpty) {
        for (var assessment in assessments) {
          assessment.currentlyActive = true;
        }
      }
    } catch (e) {
      _logger.e("We were not able to fetch the status of assessments");
    }
    _logger.i(assessments);
    return assessments;
  }

  Future<List<Test>> getAllUserTests() async {
    final userId = (await _loginService.getUserId())!;
    final cookie = box.read('cookie');
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final response = await get(
      Uri.parse('$apiBaseUrl/test/user/$userId'),
      headers: headers,
    );
    _logger.i(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final tests = data.map((e) => Test.fromJson(e)).toList();
      tests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return tests;
    } else {
      _logger.e("Error in fetching tests");
      // Return empty list instead of throwing to avoid crashing UI if endpoint fails
      return [];
    }
  }

  Future<Test> getLastTest() async {
    final tests = await getAllUserTests();
    if (tests.isNotEmpty) {
      return tests.last;
    } else {
      throw Exception("No tests found");
    }
  }

  Future<List<Test>> getAllAssessmentTests({required int assessmentId}) async {
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final response = await get(
      Uri.parse('$apiBaseUrl/test/assessment/$assessmentId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Test.fromJson(e)).toList();
    } else {
      _logger.e(
          "Error in fetching assessments, status code: ${response.statusCode}");
      throw Exception(
          "Error in fetching assessments, status code: ${response.statusCode}");
    }
  }

  getHandsValues() async {
    final userId = (await _loginService.getUserId())!;
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final response = await get(
      Uri.parse('$apiBaseUrl/test/hands/$userId'),
      headers: headers,
    );
    _logger.i(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      Map<String, Test?> handsValues = {};
      
      if (data["Left"] != null && data["Left"].isNotEmpty) {
        handsValues["Left"] = Test.fromJson(data["Left"][0]);
      } else {
        handsValues["Left"] = null;
      }
      
      if (data["Right"] != null && data["Right"].isNotEmpty) {
        handsValues["Right"] = Test.fromJson(data["Right"][0]);
      } else {
        handsValues["Right"] = null;
      }

      return handsValues;
    } else {
      _logger.e(
          "Error in fetching hands values, status code: ${response.statusCode}");
      throw Exception(
          "Error in fetching hands values, status code: ${response.statusCode}");
    }
  }

  Future<List<String>> getAllPossibleDevices() async {
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    _logger.i(cookie);
    final response = await get(
      Uri.parse('$apiBaseUrl/device-queue/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> devices = [];
      for (var data in data) {
        devices.add(data["deviceCode"].toString());
      }
      return devices;
    } else {
      _logger
          .e("Error in fetching devices, status code: ${response.statusCode}");
      throw Exception(
          "Error in fetching devices, status code: ${response.statusCode}");
    }
  }

  Future<List<String>> getAssessmentQueue(
      {required String assessmentId}) async {
    final cookie = box.read('cookie');
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final response = await get(
      Uri.parse('$apiBaseUrl/queue/assessment/$assessmentId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> assessments = [];
      for (var data in data) {
        assessments.add(data["assessmentId"].toString());
      }
      return assessments;
    } else {
      _logger.e(
          "Error in fetching assessment queue, status code: ${response.statusCode}");
      throw Exception(
          "Error in fetching assessment queue, status code: ${response.statusCode}");
    }
  }

  createTestQueue(
      {required Assessment assessment,
      required String hand,
      required String deviceId}) async {
    final userId = (await _loginService.getUserId())!;
    final cookie = box.read('cookie');
    final Headers headers = {
      'accept': 'application/json',
      "cookie": cookie,
      "Content-Type": "application/json"
    };
    final body = jsonEncode({
      "userId": int.parse(userId),
      "assessmentId": assessment.id,
      "deviceId": int.parse(deviceId),
      "posture": assessment.posture,
      "hand": hand,
    });
    final response = await http.post(Uri.parse('$apiBaseUrl/queue/'),
        headers: headers, body: body);

    if (response.statusCode == 200) {
      _logger.i("Test created successfully");
    } else {
      _logger.e("Error in creating test, status code: ${response.statusCode}");
      throw Exception(
          "Error in creating test, status code: ${response.statusCode}");
    }
  }

  Future<void> deleteTest({required int id}) async {
    final cookie = box.read('cookie');
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final response = await delete(
      Uri.parse('$apiBaseUrl/test/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      _logger.i("Test deleted successfully");
      Fluttertoast.showToast(msg: "Test deleted Successfully");
    } else {
      _logger.e("Error in deleting test, status code: ${response.statusCode}");
      Fluttertoast.showToast(
          msg: "Unable to delete the test ${response.statusCode}");
    }
  }

  final _dialogService = locator<DialogService>();
  Future<void> sendResetPasswordEmail(
      {required String email, required String userType}) async {
    final user = userType == "Patient" ? "user" : "specialist";
    final url = Uri.parse('$apiBaseUrl/$user/forgot-password/');
    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': email,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      _logger.i("reset password email sent successfully");
      Fluttertoast.showToast(msg: "Reset password email sent successfully");
    } else if (response.statusCode == 302) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        final redirectResponse = await http.post(
          Uri.parse(redirectUrl),
          headers: headers,
          body: body,
        );
        if (redirectResponse.statusCode == 200) {
          _logger.i("Reset password email sent successfully after redirect");
          Fluttertoast.showToast(
              msg:
                  "Reset password email sent successfully, after redirection. ");
        } else {
          _logger.e(
              "Error in sending email for password reset after redirect, status code: ${redirectResponse.statusCode}");
          Fluttertoast.showToast(
              msg: "Error in sending email ${redirectResponse.statusCode}");
        }
      } else if (response.statusCode == 404) {
        _logger.e(
            "Error in sending email for password reset, status code: ${response.statusCode}");
        _dialogService.showCustomDialog(
            variant: DialogType.infoAlert,
            title: "Error",
            description: "Email not registered, please sign up!");
      } else {
        _logger.e(
            "Error in sending email for password reset, status code: ${response.statusCode}");
        Fluttertoast.showToast(
            msg: "Error in sending email ${response.statusCode}");
      }
    }
  }

  Future<List<Comment>> getComments({required int assessmentId}) async {
    final cookie = box.read('cookie');
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final response = await get(
      Uri.parse('$apiBaseUrl/remarks/assessment/$assessmentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<Comment> comments = [];
      for (var item in json) {
        comments.add(Comment.fromJson(item));
      }

      return comments;
    } else {
      _logger.e(
          "Fetching comments from server gave the error ${response.statusCode}, ");
      throw Exception(response.statusCode);
    }
  }

  Future<List<Accounts>> getSpecialists() async {
    final userId = (await _loginService.getUserId())!;
    final cookie = box.read('cookie');
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final response = await get(
      Uri.parse('$apiBaseUrl/accountAccess/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<Accounts> accounts = [];
      for (var item in json) {
        accounts.add(Accounts.fromJson(item));
      }
      return accounts;
    } else {
      _logger.e(
          "Fetching Specialists from server gave the error ${response.statusCode}, ");
      throw Exception(response.statusCode);
    }
  }

  Future<List<Map<String, int>>> getUserQueue() async {
    //  curl -X 'GET' \
    // 'https://ameya-backend.onrender.com/api/queue/user/5' \
    // -H 'accept: application/json'
    final userId = (await _loginService.getUserId())!;
    final cookie = box.read('cookie');
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final response = await get(
      Uri.parse('$apiBaseUrl/queue/user/$userId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<Map<String, int>> assessmentAndQueueId = [];
      for (var item in json) {
        assessmentAndQueueId
            .add({"assessmentId": item["assessmentId"], "queueId": item["id"]});
      }
      return assessmentAndQueueId;
    } else {
      _logger.e(
          "Fetching user Queue from server gave the error ${response.statusCode}, ");
      throw Exception(response.statusCode);
    }
  }

  Future<void> cancelAssessment({required int queueId}) async {
    final cookie = box.read('cookie');
    final Headers headers = {'accept': 'application/json', "cookie": cookie};
    final Response response = await delete(
      Uri.parse('$apiBaseUrl/queue/$queueId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      _logger.i("Assessment cancelled successfully");
      Fluttertoast.showToast(msg: "Assessment cancelled successfully");
      NavigationService().clearStackAndShow(Routes.homeView,
          arguments: const HomeViewArguments(firstPage: 1));
      // NavigationService().back();
    } else {
      _logger.e(
          "Error in cancelling assessment, status code: ${response.statusCode}");
      Fluttertoast.showToast(
          msg: "Error in cancelling assessment ${response.statusCode}");
    }
  }

  Future<int> getQueueId(Assessment assessment) async {
    final userAndAssessmentIds = await getUserQueue();
    for (var userAndAssessmentId in userAndAssessmentIds) {
      if (userAndAssessmentId["assessmentId"] == assessment.id) {
        return userAndAssessmentId["queueId"]!;
      }
    }
    throw Exception("Queue Id not found");
  }
}
