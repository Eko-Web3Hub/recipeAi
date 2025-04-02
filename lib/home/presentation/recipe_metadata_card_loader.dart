import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/application/user_recipe_translate_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class RecipeMetadataCardLoader extends Cubit<Receipe> {
  RecipeMetadataCardLoader(
    this.receipe,
    this._userRecipeTranslateService,
  ) : super(receipe) {
    _load();
  }

  void _load() {
    final recipeId = convertRecipeNameToFirestoreId(receipe.name);

    // _subscription = _userRecipeTranslateService
    //     .watchTranslatedRecipe(
    //   recipeName: recipeId,
    // )
    //     .listen(
    //   (event) {
    //     if (event != null) {
    //       safeEmit(event);
    //     }
    //   },
    // );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  final Receipe receipe;
  final UserRecipeTranslateService _userRecipeTranslateService;

  StreamSubscription<Receipe?>? _subscription;
}
