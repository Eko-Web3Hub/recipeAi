import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/kitchen/presentation/ingredient_controller.dart';

void main() {
  IngredientController build() => IngredientController();

  blocTest<IngredientController, IngredientState>(
    'should be in initial state',
    build: () => build(),
    verify: (bloc) {
      expect(bloc.state, isA<IngredientInitialState>());
    },
  );
}
