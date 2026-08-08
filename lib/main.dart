import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vital_step/ReceivedNotification.dart';
import 'package:vital_step/app/app.bottomsheets.dart';
import 'package:vital_step/app/app.dialogs.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/services/device_selection_service.dart';
import 'package:vital_step/services/notifications_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

/// Second Supabase client for patient data (New_Supabase_Project).
/// Distinct from [Supabase.instance.client] which handles kill-switch only.
late final SupabaseClient patientSupabaseClient;

@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  // print('notification(${notificationResponse.id}) action tapped: '
  //     '${notificationResponse.actionId} with'
  //     ' payload: ${notificationResponse.payload}');
  //
  await StackedService.navigatorKey?.currentState
      ?.pushNamed(Routes.assesmentView);
  //   print(
  //       'notification action tapped with input: ${notificationResponse.input}');
  // if (notificationResponse.input?.isNotEmpty ?? false) {

  // }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  await Supabase.initialize(
    url: 'https://aoujgxqgixpanztyyshc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvdWpneHFnaXhwYW56dHl5c2hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjMxOTc3ODQsImV4cCI6MjAzODc3Mzc4NH0.7oZoJa7kYpIjj48dOI_iamjxLlMqv_pek52RswBtpRs',
  );

  // Initialize second Supabase client for patient data
  patientSupabaseClient = SupabaseClient(
    const String.fromEnvironment(
      'PATIENT_SUPABASE_URL',
      defaultValue: 'https://cbebmpgsbxqdzpfgqulj.supabase.co',
    ),
    const String.fromEnvironment(
      'PATIENT_SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNiZWJtcGdzYnhxZHpwZmdxdWxqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNjQ3MjEsImV4cCI6MjA5ODY0MDcyMX0.n5oOlnR1GFWDG2SxLOlmW1B_NPvnhABl7Kv-pP5mtKY',
    ),
  );

  setupBottomSheetUi();
  await GetStorage.init();

  // Initialize DeviceSelectionService
  final deviceSelectionService = locator<DeviceSelectionService>();
  await deviceSelectionService.initialize();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings("app_icon");

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  final NotificationsService notificationsService =
      locator<NotificationsService>();
  notificationsService.handleNotification();

  //for terminated state
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = Routes.startupView;

  final response = notificationAppLaunchDetails?.notificationResponse;
  if (response != null) {
    initialRoute = Routes.assesmentView;
  }

  runApp(MainApp(initialRoute: initialRoute));

//for foreground and background
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
    await notificationsService.handleNotification();
  }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.initialRoute});
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: _buildTheme(context),
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    try {
      return ThemeData(
        textTheme: Theme.of(context).textTheme,
        primaryColor: const Color(0xFF1E88E5),
      );
    } catch (e) {
      // Fallback to default theme if GoogleFonts fails (e.g. AssetManifest error)
      debugPrint(
          "GoogleFonts failed to load: $e. Falling back to system fonts.");
      return ThemeData(
        primaryColor: const Color(0xFF1E88E5),
      );
    }
  }
}
