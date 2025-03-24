import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/utils/constant.dart';

abstract class IUserRecipeTranslateRepository {
  Stream<Receipe?> watchTranslatedRecipe({
    required EntityId uid,
    required AppLanguage language,
    required EntityId recipeName,
  });
}
