// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../services/accounts_service.dart';
import '../services/ai_service.dart';
import '../services/analysis_service.dart';
import '../services/hubspot_service.dart';
import '../services/api_calls_service.dart';
import '../services/connection_manager_service.dart';
import '../services/device_selection_service.dart';
import '../services/login_service.dart';
import '../services/mode_service.dart';
import '../services/notifications_service.dart';
import '../services/patient_service.dart';
import '../services/specialist_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => LoginService());
  locator.registerLazySingleton(() => AnalysisService());
  locator.registerLazySingleton(() => AiService());
  locator.registerLazySingleton(() => HubSpotService());
  locator.registerLazySingleton(() => AccountsService());
  locator.registerLazySingleton(() => ApiCallsService());
  locator.registerLazySingleton(() => NotificationsService());
  locator.registerLazySingleton(() => SpecialistService());
  locator.registerLazySingleton(() => DeviceSelectionService());
  locator.registerLazySingleton(() => ConnectionManagerService());
  locator.registerLazySingleton(() => ModeService());
  locator.registerLazySingleton(() => PatientService());
}
