import 'package:flutter_test/flutter_test.dart';
import 'package:vital_step/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('TestResultViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
