import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';

const horizontalScreenPadding = 30.0;

enum InputType { text, password }

const receipeSample = Receipe(
  name: ' Burger Healthy',
  ingredients: [
    Ingredient(
      name: 'Tomatoes',
      quantity: '3pcs',
    ),
    Ingredient(
      name: 'Water',
      quantity: null,
    ),
    Ingredient(
      name: 'Steak',
      quantity: null,
    ),
    Ingredient(
      name: 'Egg',
      quantity: '10pcs',
    ),
  ],
  steps: [
    Step(
      description: 'Mash black beans in a large bowl for 10min',
      duration: '10:00',
    ),
    Step(
      description: 'Mash black beans in a large bowl for 15min',
      duration: '15:00',
    ),
    Step(
      description: 'Mash black beans in a large bowl for 5min',
      duration: '5:00',
    ),
    Step(
      description: 'Mash black beans in a large bowl and mixture with water',
      duration: null,
    ),
  ],
);
