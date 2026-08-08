import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vital_step/Model/Device.dart';
import 'package:vital_step/Model/profile.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/services/login_service.dart';
import 'package:vital_step/ui/common/app_strings.dart';

class AccountsService {
  final LoginService _loginService = LoginService();
  final box = GetStorage();
  final _logger = getLogger("AccountsService");
  Future<Profile> getAccountDetails({int? patientUserId}) async {
    final String userId = patientUserId != null
        ? patientUserId.toString()
        : (await _loginService.getUserId())!;
    final Response response = await get(
      Uri.parse('$apiBaseUrl/user/$userId'),
      headers: <String, String>{'accept': 'application/json'},
    );
    _logger.i(response.body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Profile profile = Profile.fromJson(json);
      return profile;
    } else {
      _logger.e(
          'Failed to load account details, status code: ${response.statusCode}');

      throw Exception('Failed to load account details');
    }
  }

  Future<List<Device>> getDevices() async {
    try {
      Profile profile = await getAccountDetails();
      List<String> devices = [];
      if (profile.device == null) {
        return [];
      }
      for (var device in profile.device!) {
        devices.add(device.id.toString());
      }
      return profile.device!;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addDevice(
      {required String deviceCode, required String deviceName}) async {
    final String userId = (await _loginService.getUserId())!;
    final String cookie = box.read("cookie");
    final Headers headers = {
      'Content-Type': 'application/json',
      'cookie': cookie,
      "accept": "application/json"
    };
    final Response response = await post(
      Uri.parse('$apiBaseUrl/device'),
      headers: headers,
      body: jsonEncode({
        "userId": int.parse(userId),
        "deviceName": deviceName,
        "deviceCode": deviceCode,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      _logger.e(
          'Failed to add device, status code: ${response.statusCode}, body: ${response.body}');
      throw Exception('Failed to add device');
    }
  }

  Future<bool> killApp() async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      // Added timeout to prevent infinite hang if network is slow/broken
      final response = await client
          .from("vitalStep")
          .select()
          .eq("id", 1)
          .single()
          .timeout(const Duration(seconds: 3));
      return response['kill_switch'] ?? false;
    } catch (e) {
      _logger.w("Kill switch check skipped (likely offline): $e");
      // Default to false (don't kill app) if we can't reach the server
      return false;
    }
  }

  Future<void> deleteAccount() async {
    final String userId = (await _loginService.getUserId())!;

    final String cookie = box.read("cookie");
    final Headers headers = {
      'Content-Type': 'application/json',
      'cookie': cookie,
      "accept": "application/json"
    };
    final Response response = await delete(
      Uri.parse('$apiBaseUrl/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Account deleted successfully");
      final loginService = locator<LoginService>();
      await loginService.signOut();
      return;
    } else {
      _logger.e(
          'Failed to delete account, status code: ${response.statusCode}, body: ${response.body}');
      Fluttertoast.showToast(
          msg: "Unable to delete the account, please try again later. ");
    }
  }
}
