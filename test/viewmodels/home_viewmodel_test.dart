import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vital_step/app/app.bottomsheets.dart';
import 'package:vital_step/ui/common/app_strings.dart';
import 'package:vital_step/ui/views/home/home_viewmodel.dart';

import '../helpers/test_helpers.dart';

void main() {
  HomeViewModel getModel() => HomeViewModel();

  group('showBottomSheet -', () {
    test('When called, should show custom bottom sheet using notice variant',
        () {
      final bottomSheetService = getAndRegisterBottomSheetService();

      final model = getModel();
      model.showBottomSheet();
      verify(bottomSheetService.showCustomSheet(
        variant: BottomSheetType.notice,
        title: ksHomeBottomSheetTitle,
        description: ksHomeBottomSheetDescription,
      ));
    });
  });
}
