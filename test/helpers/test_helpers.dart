import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:vital_step/services/login_service.dart';
import 'package:vital_step/services/accounts_service.dart';
import 'package:vital_step/services/api_calls_service.dart';
import 'package:vital_step/services/device_selection_service.dart';
import 'package:vital_step/services/notifications_service.dart';
import 'package:vital_step/services/specialist_service.dart';
// @stacked-import

import 'test_helpers.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<LoginService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<AccountsService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<ApiCallsService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DeviceSelectionService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<NotificationsService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<SpecialistService>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
])
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  getAndRegisterLoginService();
  getAndRegisterAccountsService();
  getAndRegisterApiCallsService();
  getAndRegisterDeviceSelectionService();
  getAndRegisterNotificationsService();
  getAndRegisterSpecialistService();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  when(service.showCustomSheet<T, T>(
    enableDrag: anyNamed('enableDrag'),
    enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
    exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
    ignoreSafeArea: anyNamed('ignoreSafeArea'),
    isScrollControlled: anyNamed('isScrollControlled'),
    barrierDismissible: anyNamed('barrierDismissible'),
    additionalButtonTitle: anyNamed('additionalButtonTitle'),
    variant: anyNamed('variant'),
    title: anyNamed('title'),
    hasImage: anyNamed('hasImage'),
    imageUrl: anyNamed('imageUrl'),
    showIconInMainButton: anyNamed('showIconInMainButton'),
    mainButtonTitle: anyNamed('mainButtonTitle'),
    showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
    secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
    showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
    takesInput: anyNamed('takesInput'),
    barrierColor: anyNamed('barrierColor'),
    barrierLabel: anyNamed('barrierLabel'),
    customData: anyNamed('customData'),
    data: anyNamed('data'),
    description: anyNamed('description'),
  )).thenAnswer((realInvocation) =>
      Future.value(showCustomSheetResponse ?? SheetResponse<T>()));

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockLoginService getAndRegisterLoginService() {
  _removeRegistrationIfExists<LoginService>();
  final service = MockLoginService();
  locator.registerSingleton<LoginService>(service);
  return service;
}

MockAccountsService getAndRegisterAccountsService() {
  _removeRegistrationIfExists<AccountsService>();
  final service = MockAccountsService();
  locator.registerSingleton<AccountsService>(service);
  return service;
}

MockApiCallsService getAndRegisterApiCallsService() {
  _removeRegistrationIfExists<ApiCallsService>();
  final service = MockApiCallsService();
  locator.registerSingleton<ApiCallsService>(service);
  return service;
}

MockDeviceSelectionService getAndRegisterDeviceSelectionService() {
  _removeRegistrationIfExists<DeviceSelectionService>();
  final service = MockDeviceSelectionService();
  locator.registerSingleton<DeviceSelectionService>(service);
  return service;
}

MockNotificationsService getAndRegisterNotificationsService() {
  _removeRegistrationIfExists<NotificationsService>();
  final service = MockNotificationsService();
  locator.registerSingleton<NotificationsService>(service);
  return service;
}

MockSpecialistService getAndRegisterSpecialistService() {
  _removeRegistrationIfExists<SpecialistService>();
  final service = MockSpecialistService();
  locator.registerSingleton<SpecialistService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
