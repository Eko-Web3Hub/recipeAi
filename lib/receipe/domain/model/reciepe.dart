import 'package:equatable/equatable.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';

class Reciepe extends Equatable {
  final String name;
  final List<Ingredient> ingredients;
  final List<Step> steps;

  const Reciepe({
    required this.name,
    required this.ingredients,
    required this.steps,
  });

  @override
  List<Object?> get props => [name, ingredients, steps];
}
