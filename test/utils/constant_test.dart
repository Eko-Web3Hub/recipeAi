import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/utils/constant.dart';

void main() {
  test(
      'appLanguageFromString show throw an exception for a unsupported language',
      () async {
    expect(() => appLanguageFromString('unsupported'), throwsException);
  });
}
