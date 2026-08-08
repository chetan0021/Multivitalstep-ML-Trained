// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as _i30;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i35;
import 'package:vital_step/Model/accounts.dart' as _i32;
import 'package:vital_step/Model/Assessment.dart' as _i33;
import 'package:vital_step/Model/profile.dart' as _i31;
import 'package:vital_step/Model/spcialist_profile.dart' as _i34;
import 'package:vital_step/ui/views/account/account_view.dart' as _i9;
import 'package:vital_step/ui/views/account_specialist/account_specialist_view.dart'
    as _i22;
import 'package:vital_step/ui/views/assesment/assesment_view.dart' as _i8;
import 'package:vital_step/ui/views/assessment_detail/assessment_detail_view.dart'
    as _i17;
import 'package:vital_step/ui/views/assessment_history/assessment_history_view.dart'
    as _i18;
import 'package:vital_step/ui/views/compare/compare_view.dart' as _i24;
import 'package:vital_step/ui/views/dashboard/dashboard_view.dart' as _i6;
import 'package:vital_step/ui/views/device/device_view.dart' as _i13;
import 'package:vital_step/ui/views/faq/faq_view.dart' as _i11;
import 'package:vital_step/ui/views/home/home_view.dart' as _i2;
import 'package:vital_step/ui/views/home_specialist/home_specialist_view.dart'
    as _i20;
import 'package:vital_step/ui/views/home_tab/home_tab_view.dart' as _i10;
import 'package:vital_step/ui/views/home_tab_specialist/home_tab_specialist_view.dart'
    as _i21;
import 'package:vital_step/ui/views/kill_app/kill_app_view.dart' as _i14;
import 'package:vital_step/ui/views/login/login_view.dart' as _i4;
import 'package:vital_step/ui/views/password_reset_view/password_reset_view_view.dart'
    as _i19;
import 'package:vital_step/ui/views/patient_edit/patient_edit_view.dart'
    as _i29;
import 'package:vital_step/ui/views/patient_history/patient_history_view.dart'
    as _i28;
import 'package:vital_step/ui/views/patient_registration/patient_registration_view.dart'
    as _i26;
import 'package:vital_step/ui/views/patient_search/patient_search_view.dart'
    as _i25;
import 'package:vital_step/ui/views/patient_session/patient_session_view.dart'
    as _i27;
import 'package:vital_step/ui/views/privacy_policy/privacy_policy_view.dart'
    as _i12;
import 'package:vital_step/ui/views/report/report_view.dart' as _i7;
import 'package:vital_step/ui/views/sign_up/sign_up_view.dart' as _i5;
import 'package:vital_step/ui/views/sign_up_specialist/sign_up_specialist_view.dart'
    as _i23;
import 'package:vital_step/ui/views/startup/startup_view.dart' as _i3;
import 'package:vital_step/ui/views/test_result/test_result_view.dart' as _i16;
import 'package:vital_step/ui/views/test_taking/test_taking_view.dart' as _i15;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const loginView = '/login-view';

  static const signUpView = '/sign-up-view';

  static const dashboardView = '/dashboard-view';

  static const reportView = '/report-view';

  static const assesmentView = '/assesment-view';

  static const accountView = '/account-view';

  static const homeTabView = '/home-tab-view';

  static const faqView = '/faq-view';

  static const privacyPolicyView = '/privacy-policy-view';

  static const deviceView = '/device-view';

  static const killAppView = '/kill-app-view';

  static const testTakingView = '/test-taking-view';

  static const testResultView = '/test-result-view';

  static const assessmentDetailView = '/assessment-detail-view';

  static const assessmentHistoryView = '/assessment-history-view';

  static const passwordResetViewView = '/password-reset-view-view';

  static const homeSpecialistView = '/home-specialist-view';

  static const homeTabSpecialistView = '/home-tab-specialist-view';

  static const accountSpecialistView = '/account-specialist-view';

  static const signUpSpecialistView = '/sign-up-specialist-view';

  static const compareView = '/compare-view';

  static const patientSearchView = '/patient-search-view';

  static const patientRegistrationView = '/patient-registration-view';

  static const patientSessionView = '/patient-session-view';

  static const patientHistoryView = '/patient-history-view';

  static const patientEditView = '/patient-edit-view';

  static const all = <String>{
    homeView,
    startupView,
    loginView,
    signUpView,
    dashboardView,
    reportView,
    assesmentView,
    accountView,
    homeTabView,
    faqView,
    privacyPolicyView,
    deviceView,
    killAppView,
    testTakingView,
    testResultView,
    assessmentDetailView,
    assessmentHistoryView,
    passwordResetViewView,
    homeSpecialistView,
    homeTabSpecialistView,
    accountSpecialistView,
    signUpSpecialistView,
    compareView,
    patientSearchView,
    patientRegistrationView,
    patientSessionView,
    patientHistoryView,
    patientEditView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.startupView,
      page: _i3.StartupView,
    ),
    _i1.RouteDef(
      Routes.loginView,
      page: _i4.LoginView,
    ),
    _i1.RouteDef(
      Routes.signUpView,
      page: _i5.SignUpView,
    ),
    _i1.RouteDef(
      Routes.dashboardView,
      page: _i6.DashboardView,
    ),
    _i1.RouteDef(
      Routes.reportView,
      page: _i7.ReportView,
    ),
    _i1.RouteDef(
      Routes.assesmentView,
      page: _i8.AssesmentView,
    ),
    _i1.RouteDef(
      Routes.accountView,
      page: _i9.AccountView,
    ),
    _i1.RouteDef(
      Routes.homeTabView,
      page: _i10.HomeTabView,
    ),
    _i1.RouteDef(
      Routes.faqView,
      page: _i11.FaqView,
    ),
    _i1.RouteDef(
      Routes.privacyPolicyView,
      page: _i12.PrivacyPolicyView,
    ),
    _i1.RouteDef(
      Routes.deviceView,
      page: _i13.DeviceView,
    ),
    _i1.RouteDef(
      Routes.killAppView,
      page: _i14.KillAppView,
    ),
    _i1.RouteDef(
      Routes.testTakingView,
      page: _i15.TestTakingView,
    ),
    _i1.RouteDef(
      Routes.testResultView,
      page: _i16.TestResultView,
    ),
    _i1.RouteDef(
      Routes.assessmentDetailView,
      page: _i17.AssessmentDetailView,
    ),
    _i1.RouteDef(
      Routes.assessmentHistoryView,
      page: _i18.AssessmentHistoryView,
    ),
    _i1.RouteDef(
      Routes.passwordResetViewView,
      page: _i19.PasswordResetViewView,
    ),
    _i1.RouteDef(
      Routes.homeSpecialistView,
      page: _i20.HomeSpecialistView,
    ),
    _i1.RouteDef(
      Routes.homeTabSpecialistView,
      page: _i21.HomeTabSpecialistView,
    ),
    _i1.RouteDef(
      Routes.accountSpecialistView,
      page: _i22.AccountSpecialistView,
    ),
    _i1.RouteDef(
      Routes.signUpSpecialistView,
      page: _i23.SignUpSpecialistView,
    ),
    _i1.RouteDef(
      Routes.compareView,
      page: _i24.CompareView,
    ),
    _i1.RouteDef(
      Routes.patientSearchView,
      page: _i25.PatientSearchView,
    ),
    _i1.RouteDef(
      Routes.patientRegistrationView,
      page: _i26.PatientRegistrationView,
    ),
    _i1.RouteDef(
      Routes.patientSessionView,
      page: _i27.PatientSessionView,
    ),
    _i1.RouteDef(
      Routes.patientHistoryView,
      page: _i28.PatientHistoryView,
    ),
    _i1.RouteDef(
      Routes.patientEditView,
      page: _i29.PatientEditView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(
        orElse: () => const HomeViewArguments(),
      );
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i2.HomeView(key: args.key, firstPage: args.firstPage),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => const LoginViewArguments(),
      );
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.LoginView(key: args.key),
        settings: data,
      );
    },
    _i5.SignUpView: (data) {
      final args = data.getArgs<SignUpViewArguments>(
        orElse: () => const SignUpViewArguments(),
      );
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i5.SignUpView(key: args.key, profile: args.profile),
        settings: data,
      );
    },
    _i6.DashboardView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.DashboardView(),
        settings: data,
      );
    },
    _i7.ReportView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.ReportView(),
        settings: data,
      );
    },
    _i8.AssesmentView: (data) {
      final args = data.getArgs<AssesmentViewArguments>(
        orElse: () => const AssesmentViewArguments(),
      );
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.AssesmentView(
            key: args.key,
            isSpecialist: args.isSpecialist,
            patientAccount: args.patientAccount),
        settings: data,
      );
    },
    _i9.AccountView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.AccountView(),
        settings: data,
      );
    },
    _i10.HomeTabView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.HomeTabView(),
        settings: data,
      );
    },
    _i11.FaqView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.FaqView(),
        settings: data,
      );
    },
    _i12.PrivacyPolicyView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.PrivacyPolicyView(),
        settings: data,
      );
    },
    _i13.DeviceView: (data) {
      final args = data.getArgs<DeviceViewArguments>(nullOk: false);
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => _i13.DeviceView(
            key: args.key, showExistingDevices: args.showExistingDevices),
        settings: data,
      );
    },
    _i14.KillAppView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.KillAppView(),
        settings: data,
      );
    },
    _i15.TestTakingView: (data) {
      final args = data.getArgs<TestTakingViewArguments>(nullOk: false);
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i15.TestTakingView(key: args.key, assessment: args.assessment),
        settings: data,
      );
    },
    _i16.TestResultView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.TestResultView(),
        settings: data,
      );
    },
    _i17.AssessmentDetailView: (data) {
      final args = data.getArgs<AssessmentDetailViewArguments>(nullOk: false);
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.AssessmentDetailView(
            key: args.key,
            assessment: args.assessment,
            patientUserId: args.patientUserId,
            isSpecialist: args.isSpecialist),
        settings: data,
      );
    },
    _i18.AssessmentHistoryView: (data) {
      final args = data.getArgs<AssessmentHistoryViewArguments>(nullOk: false);
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => _i18.AssessmentHistoryView(
            key: args.key,
            assessment: args.assessment,
            patientId: args.patientId),
        settings: data,
      );
    },
    _i19.PasswordResetViewView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i19.PasswordResetViewView(),
        settings: data,
      );
    },
    _i20.HomeSpecialistView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i20.HomeSpecialistView(),
        settings: data,
      );
    },
    _i21.HomeTabSpecialistView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i21.HomeTabSpecialistView(),
        settings: data,
      );
    },
    _i22.AccountSpecialistView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i22.AccountSpecialistView(),
        settings: data,
      );
    },
    _i23.SignUpSpecialistView: (data) {
      final args = data.getArgs<SignUpSpecialistViewArguments>(
        orElse: () => const SignUpSpecialistViewArguments(),
      );
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i23.SignUpSpecialistView(key: args.key, profile: args.profile),
        settings: data,
      );
    },
    _i24.CompareView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i24.CompareView(),
        settings: data,
      );
    },
    _i25.PatientSearchView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i25.PatientSearchView(),
        settings: data,
      );
    },
    _i26.PatientRegistrationView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i26.PatientRegistrationView(),
        settings: data,
      );
    },
    _i27.PatientSessionView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i27.PatientSessionView(),
        settings: data,
      );
    },
    _i28.PatientHistoryView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i28.PatientHistoryView(),
        settings: data,
      );
    },
    _i29.PatientEditView: (data) {
      return _i30.MaterialPageRoute<dynamic>(
        builder: (context) => const _i29.PatientEditView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class HomeViewArguments {
  const HomeViewArguments({
    this.key,
    this.firstPage,
  });

  final _i30.Key? key;

  final int? firstPage;

  @override
  String toString() {
    return '{"key": "$key", "firstPage": "$firstPage"}';
  }

  @override
  bool operator ==(covariant HomeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.firstPage == firstPage;
  }

  @override
  int get hashCode {
    return key.hashCode ^ firstPage.hashCode;
  }
}

class LoginViewArguments {
  const LoginViewArguments({this.key});

  final _i30.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SignUpViewArguments {
  const SignUpViewArguments({
    this.key,
    this.profile,
  });

  final _i30.Key? key;

  final _i31.Profile? profile;

  @override
  String toString() {
    return '{"key": "$key", "profile": "$profile"}';
  }

  @override
  bool operator ==(covariant SignUpViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.profile == profile;
  }

  @override
  int get hashCode {
    return key.hashCode ^ profile.hashCode;
  }
}

class AssesmentViewArguments {
  const AssesmentViewArguments({
    this.key,
    this.isSpecialist,
    this.patientAccount,
  });

  final _i30.Key? key;

  final bool? isSpecialist;

  final _i32.Accounts? patientAccount;

  @override
  String toString() {
    return '{"key": "$key", "isSpecialist": "$isSpecialist", "patientAccount": "$patientAccount"}';
  }

  @override
  bool operator ==(covariant AssesmentViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.isSpecialist == isSpecialist &&
        other.patientAccount == patientAccount;
  }

  @override
  int get hashCode {
    return key.hashCode ^ isSpecialist.hashCode ^ patientAccount.hashCode;
  }
}

class DeviceViewArguments {
  const DeviceViewArguments({
    this.key,
    required this.showExistingDevices,
  });

  final _i30.Key? key;

  final bool showExistingDevices;

  @override
  String toString() {
    return '{"key": "$key", "showExistingDevices": "$showExistingDevices"}';
  }

  @override
  bool operator ==(covariant DeviceViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.showExistingDevices == showExistingDevices;
  }

  @override
  int get hashCode {
    return key.hashCode ^ showExistingDevices.hashCode;
  }
}

class TestTakingViewArguments {
  const TestTakingViewArguments({
    this.key,
    required this.assessment,
  });

  final _i30.Key? key;

  final _i33.Assessment assessment;

  @override
  String toString() {
    return '{"key": "$key", "assessment": "$assessment"}';
  }

  @override
  bool operator ==(covariant TestTakingViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.assessment == assessment;
  }

  @override
  int get hashCode {
    return key.hashCode ^ assessment.hashCode;
  }
}

class AssessmentDetailViewArguments {
  const AssessmentDetailViewArguments({
    this.key,
    required this.assessment,
    this.patientUserId,
    this.isSpecialist,
  });

  final _i30.Key? key;

  final _i33.Assessment assessment;

  final int? patientUserId;

  final bool? isSpecialist;

  @override
  String toString() {
    return '{"key": "$key", "assessment": "$assessment", "patientUserId": "$patientUserId", "isSpecialist": "$isSpecialist"}';
  }

  @override
  bool operator ==(covariant AssessmentDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.assessment == assessment &&
        other.patientUserId == patientUserId &&
        other.isSpecialist == isSpecialist;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        assessment.hashCode ^
        patientUserId.hashCode ^
        isSpecialist.hashCode;
  }
}

class AssessmentHistoryViewArguments {
  const AssessmentHistoryViewArguments({
    this.key,
    required this.assessment,
    this.patientId,
  });

  final _i30.Key? key;

  final _i33.Assessment assessment;

  final int? patientId;

  @override
  String toString() {
    return '{"key": "$key", "assessment": "$assessment", "patientId": "$patientId"}';
  }

  @override
  bool operator ==(covariant AssessmentHistoryViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.assessment == assessment &&
        other.patientId == patientId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ assessment.hashCode ^ patientId.hashCode;
  }
}

class SignUpSpecialistViewArguments {
  const SignUpSpecialistViewArguments({
    this.key,
    this.profile,
  });

  final _i30.Key? key;

  final _i34.ProfileSpecialist? profile;

  @override
  String toString() {
    return '{"key": "$key", "profile": "$profile"}';
  }

  @override
  bool operator ==(covariant SignUpSpecialistViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.profile == profile;
  }

  @override
  int get hashCode {
    return key.hashCode ^ profile.hashCode;
  }
}

extension NavigatorStateExtension on _i35.NavigationService {
  Future<dynamic> navigateToHomeView({
    _i30.Key? key,
    int? firstPage,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key, firstPage: firstPage),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView({
    _i30.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSignUpView({
    _i30.Key? key,
    _i31.Profile? profile,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.signUpView,
        arguments: SignUpViewArguments(key: key, profile: profile),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.dashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToReportView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.reportView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAssesmentView({
    _i30.Key? key,
    bool? isSpecialist,
    _i32.Accounts? patientAccount,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.assesmentView,
        arguments: AssesmentViewArguments(
            key: key,
            isSpecialist: isSpecialist,
            patientAccount: patientAccount),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAccountView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.accountView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeTabView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeTabView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToFaqView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.faqView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPrivacyPolicyView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.privacyPolicyView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDeviceView({
    _i30.Key? key,
    required bool showExistingDevices,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.deviceView,
        arguments: DeviceViewArguments(
            key: key, showExistingDevices: showExistingDevices),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToKillAppView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.killAppView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTestTakingView({
    _i30.Key? key,
    required _i33.Assessment assessment,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.testTakingView,
        arguments: TestTakingViewArguments(key: key, assessment: assessment),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTestResultView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.testResultView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAssessmentDetailView({
    _i30.Key? key,
    required _i33.Assessment assessment,
    int? patientUserId,
    bool? isSpecialist,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.assessmentDetailView,
        arguments: AssessmentDetailViewArguments(
            key: key,
            assessment: assessment,
            patientUserId: patientUserId,
            isSpecialist: isSpecialist),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAssessmentHistoryView({
    _i30.Key? key,
    required _i33.Assessment assessment,
    int? patientId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.assessmentHistoryView,
        arguments: AssessmentHistoryViewArguments(
            key: key, assessment: assessment, patientId: patientId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPasswordResetViewView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.passwordResetViewView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeSpecialistView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeSpecialistView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeTabSpecialistView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeTabSpecialistView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAccountSpecialistView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.accountSpecialistView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSignUpSpecialistView({
    _i30.Key? key,
    _i34.ProfileSpecialist? profile,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.signUpSpecialistView,
        arguments: SignUpSpecialistViewArguments(key: key, profile: profile),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCompareView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.compareView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPatientSearchView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.patientSearchView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPatientRegistrationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.patientRegistrationView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPatientSessionView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.patientSessionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPatientHistoryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.patientHistoryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPatientEditView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.patientEditView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView({
    _i30.Key? key,
    int? firstPage,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key, firstPage: firstPage),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView({
    _i30.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSignUpView({
    _i30.Key? key,
    _i31.Profile? profile,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.signUpView,
        arguments: SignUpViewArguments(key: key, profile: profile),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.dashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithReportView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.reportView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAssesmentView({
    _i30.Key? key,
    bool? isSpecialist,
    _i32.Accounts? patientAccount,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.assesmentView,
        arguments: AssesmentViewArguments(
            key: key,
            isSpecialist: isSpecialist,
            patientAccount: patientAccount),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAccountView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.accountView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeTabView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeTabView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithFaqView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.faqView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPrivacyPolicyView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.privacyPolicyView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDeviceView({
    _i30.Key? key,
    required bool showExistingDevices,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.deviceView,
        arguments: DeviceViewArguments(
            key: key, showExistingDevices: showExistingDevices),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithKillAppView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.killAppView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTestTakingView({
    _i30.Key? key,
    required _i33.Assessment assessment,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.testTakingView,
        arguments: TestTakingViewArguments(key: key, assessment: assessment),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTestResultView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.testResultView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAssessmentDetailView({
    _i30.Key? key,
    required _i33.Assessment assessment,
    int? patientUserId,
    bool? isSpecialist,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.assessmentDetailView,
        arguments: AssessmentDetailViewArguments(
            key: key,
            assessment: assessment,
            patientUserId: patientUserId,
            isSpecialist: isSpecialist),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAssessmentHistoryView({
    _i30.Key? key,
    required _i33.Assessment assessment,
    int? patientId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.assessmentHistoryView,
        arguments: AssessmentHistoryViewArguments(
            key: key, assessment: assessment, patientId: patientId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPasswordResetViewView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.passwordResetViewView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeSpecialistView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeSpecialistView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeTabSpecialistView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeTabSpecialistView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAccountSpecialistView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.accountSpecialistView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSignUpSpecialistView({
    _i30.Key? key,
    _i34.ProfileSpecialist? profile,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.signUpSpecialistView,
        arguments: SignUpSpecialistViewArguments(key: key, profile: profile),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCompareView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.compareView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPatientSearchView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.patientSearchView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPatientRegistrationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.patientRegistrationView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPatientSessionView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.patientSessionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPatientHistoryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.patientHistoryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPatientEditView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.patientEditView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
