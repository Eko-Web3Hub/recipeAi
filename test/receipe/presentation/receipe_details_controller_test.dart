import 'package:bloc_test/bloc_test.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

void main() {
  const EntityId receipeId = EntityId('1');

  ReceipeDetailsController buildSut() {
    return ReceipeDetailsController(
      receipeId,
    );
  }

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details',
    build: () => buildSut(),
    expect: () => const <ReceipeDetailsState>[
      ReceipeDetailsState.loaded(
        receipeSample,
      ),
    ],
  );
}
