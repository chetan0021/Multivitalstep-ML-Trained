import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/Model/SignUpInfo.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:vital_step/services/notifications_service.dart';
import 'package:vital_step/ui/common/app_strings.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final _logger = getLogger("LoginService");
  final box = GetStorage();
  final DialogService _dialogService = locator<DialogService>();

  /// this function will check if the user is currently logged in or not
  Future<bool> isLoggedIn() async {
    try {
      final userId = await getUserId();
      return userId != null;
    } catch (e) {
      _logger.e('Failed to check if user is logged in, error: $e');
      return false;
    }
  }

  Future<String?> getUserId() async {
    try {
      final userId = box.read("userId");
      return userId?.toString();
    } catch (e) {
      _logger.e('Failed to get userId, error: $e');
      return null;
    }
  }

  Future<void> signIn(
      String email, String password, String selectedUserType) async {
    // selectedUserType = "Patient", "Specialist";
    final requestUrl = selectedUserType == 'Patient'
        ? '$apiBaseUrl/auth/login'
        : '$apiBaseUrl/auth/login-specialist';
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('POST', Uri.parse(requestUrl));
    request.body = json.encode({"email": email, "password": password});
    request.headers.addAll(headers);

    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final cookie = response.headers['set-cookie'];
      final json = jsonDecode(response.body);
      final userId = json['id'].toString();
      box.write("cookie", cookie);
      box.write('userId', userId);
      box.write('userType', selectedUserType);
      NavigationService().navigateToStartupView();
    } else if (response.statusCode == 404) {
      _logger.e('Failed to login, status code: ${response.statusCode}');
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Error Logging In',
        description: 'The account does not exists',
      );
    } else if (response.statusCode == 400) {
      _logger.e('Failed to login, status code: ${response.statusCode}');
      var description = 'The password is wrong';

      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Error Logging In',
        description: description,
      );
    } else if (response.statusCode == 401 && selectedUserType == 'Specialist') {
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Error Logging In',
        description:
            "Your Account is still under review, please try again in some time. ",
      );
    } else {
      _logger.e('Failed to login, status code: ${response.statusCode}');
      _logger.e('Server error response: ${response.body}');

      String errorMessage = 'An unexpected error occurred during sign in.';
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson is Map && errorJson.containsKey('message')) {
          errorMessage = errorJson['message'];
        } else if (errorJson is Map && errorJson.containsKey('error')) {
          errorMessage = errorJson['error'];
        }
      } catch (_) {
        errorMessage = 'Server error (${response.statusCode}). Please contact support.';
      }

      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Error Logging In',
        description: errorMessage,
      );
    }
  }

  Future<void> signUp(SignUpInfo signUpInfo) async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('POST', Uri.parse('$apiBaseUrl/auth/register'));

    var signUpJson = signUpInfo.toJson();
    // Remove null or empty values to avoid potential backend rejection
    signUpJson.removeWhere((key, value) => value == null || value == "");

    request.body = json.encode(signUpJson);
    _logger.i('Request body: ${request.body}');
    request.headers.addAll(headers);

    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      String? cookie = response.headers['set-cookie'];
      
      // Handle both array [0] and object formats for userId
      final dynamic userIdData = (jsonResponse is List && jsonResponse.isNotEmpty)
          ? jsonResponse[0]['id']
          : jsonResponse['id'];
      
      if (userIdData == null) {
        _logger.e('Failed to extract userId from response: ${response.body}');
        _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Error Signing Up',
          description: '[DEBUG_NEW_1] Failed to retrieve user ID after registration.',
        );
        return;
      }

      final userId = userIdData.toString();

      cookie ??= await getCookie(
          userId: userId,
          email: signUpInfo.email,
          password: signUpInfo.password);

      if (cookie == null) {
        _logger.e('Failed to get cookie after successful registration');
        _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Error Signing Up',
          description: '[DEBUG_NEW_2] Registration successful, but auto-login failed. Please try signing in.',
        );
        return;
      }
      
      _logger.i('User registered successfully, userId: $userId');
      box.write("cookie", cookie);
      box.write('userId', userId);
      NavigationService().navigateToDeviceView(showExistingDevices: false);
    } else if (response.statusCode == 404) {
      _logger.e('Failed to create account, status code 404. Account probably already exists.');
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Unable to Create Account',
        description: 'An account with this email already exists.',
      );
    } else {
      _logger.e('Failed to Signup, status code: ${response.statusCode}');
      _logger.e('Server error response: ${response.body}');
      
      // Try to parse the error message from the server response
      String errorMessage = '[DEBUG_SERVER_ERROR]: ';
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson is Map && errorJson.containsKey('message')) {
          errorMessage = errorJson['message'];
        } else if (errorJson is Map && errorJson.containsKey('error')) {
          errorMessage = errorJson['error'];
        }
      } catch (_) {
        // If parsing fails, use the status code
        errorMessage = 'Server error (${response.statusCode}). Please contact support.';
      }

      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Error Signing Up',
        description: errorMessage,
      );
    }
  }

  Future<void> signOut() async {
    await box.erase();
    final NotificationsService notificationsService =
        locator<NotificationsService>();
    await notificationsService.clearAllFutureNotifications();
    Fluttertoast.showToast(msg: "User Logged Out Successfully");
    NavigationService().navigateToStartupView();
  }

  Future<String?> getCookie(
      {required String userId,
      required String email,
      required String password}) async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('POST', Uri.parse('$apiBaseUrl/auth/login'));
    request.body = json.encode({"email": email, "password": password});
    request.headers.addAll(headers);

    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final cookie = response.headers['set-cookie'];
      return cookie;
    } else {
      _logger.e('Failed to get cookie, status code: ${response.statusCode}');
      return null;
    }
  }

  updateProfile(SignUpInfo signUpInfo) async {
    final cookie = box.read('cookie').toString();
    var headers = {
      "accept": "application/json",
      'Content-Type': 'application/json',
      "cookie": cookie,
    };
    final userId = box.read('userId');
    final address = '$apiBaseUrl/user/$userId';
    var request = http.Request('PUT', Uri.parse(address));

    request.body = json.encode(signUpInfo.toJson());
    request.headers.addAll(headers);

    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Profile Updated Successfully");
    } else {
      _logger.e('Failed to update profile, status code: ${response.statusCode}');
      _logger.e('Server error response: ${response.body}');

      String errorMessage = 'An unexpected error occurred while updating profile.';
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson is Map && errorJson.containsKey('message')) {
          errorMessage = errorJson['message'];
        } else if (errorJson is Map && errorJson.containsKey('error')) {
          errorMessage = errorJson['error'];
        }
      } catch (_) {
        errorMessage = 'Server error (${response.statusCode}). Please contact support.';
      }

      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Error Updating Profile',
        description: errorMessage,
      );
    }
  }

  Future<String?> getUserType() async {
    final userType = box.read('userType');
    return userType?.toString();
  }
}
