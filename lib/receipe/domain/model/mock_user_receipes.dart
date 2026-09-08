import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';

/// Temporary mock recipe used while the recipe-generation API is disabled,
/// so the home → detail flow can still be reviewed end to end.
/// Remove once the API is back online.
final _saladeBassamoiseReceipe = Receipe(
  name: 'Salade Bassamoise',
  averageTime: '20 min',
  totalCalories: '410',
  proteinGrams: '29g',
  carbsGrams: '34g',
  lipidsGrams: '16g',
  ingredients: const [
    Ingredient(name: 'Attiéké cuit', quantity: '200 g', date: null, id: null),
    Ingredient(
      name: 'Thon au naturel',
      quantity: '200 g',
      date: null,
      id: null,
    ),
    Ingredient(name: 'Tomates', quantity: '2', date: null, id: null),
    Ingredient(name: 'Ciboulette', quantity: '1 bouquet', date: null, id: null),
    Ingredient(
      name: 'Menthe verte',
      quantity: '½ bouquet',
      date: null,
      id: null,
    ),
    Ingredient(name: 'Persil', quantity: '1 bouquet', date: null, id: null),
    Ingredient(name: 'Concombre', quantity: '1', date: null, id: null),
    Ingredient(name: 'Citron', quantity: '1', date: null, id: null),
    Ingredient(name: 'Huile végétale', quantity: null, date: null, id: null),
    Ingredient(name: 'Vinaigre', quantity: null, date: null, id: null),
    Ingredient(name: 'Sel, poivre', quantity: 'au goût', date: null, id: null),
  ],
  steps: const [
    ReceipeStep(
      description: 'Découpez tous vos légumes idéalement en dés.',
      duration: null,
    ),
    ReceipeStep(
      description:
          "Mettez l'attiéké dans un saladier et y rajouter les légumes, "
          'les herbes et le thon.',
      duration: null,
    ),
    ReceipeStep(
      description:
          'Pour la vinaigrette, mélangez environ 2 CS '
          "d'huile pour 1 CS de vinaigre. Salez, poivrez et ajoutez "
          'le jus du citron.',
      duration: null,
    ),
    ReceipeStep(
      description:
          'Et versez la vinaigrette. Goûtez et rectifiez '
          "l'assaisonnement si nécessaire 🙂",
      duration: null,
    ),
    ReceipeStep(
      description: "C'est prêt ! Bonne dégustation !",
      duration: null,
    ),
  ],
);

final mockSaladeBassamoiseUserReceipe = UserRecipeV2(
  id: const EntityId('mock-salade-bassamoise'),
  receipeFr: _saladeBassamoiseReceipe,
  receipeEn: _saladeBassamoiseReceipe,
  createdDate: DateTime.now(),
);
