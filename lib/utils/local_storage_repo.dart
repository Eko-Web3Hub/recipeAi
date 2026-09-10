import 'dart:async';
import 'dart:convert';

import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ILocalStorageRepository {
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> setSuggestedRecipes(List<UserRecipeV2> recipes);
  Future<List<UserRecipeV2>?> getSuggestedRecipes();
}

class LocalStorageRepository implements ILocalStorageRepository {
  static const String _dailySuggestedRecipesKey = 'dailySuggestedRecipes';

  LocalStorageRepository()
      : _sharedPreferenceInstanceCompleter = Completer<SharedPreferences>() {
    _initSharedPreferences();
  }

  _initSharedPreferences() async {
    final sharedPrefrenceInstance = await SharedPreferences.getInstance();
    _sharedPreferenceInstanceCompleter.complete(sharedPrefrenceInstance);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final sharedPrefrenceInstance =
        await _sharedPreferenceInstanceCompleter.future;

    await sharedPrefrenceInstance.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key ) async{
 final sharedPrefrenceInstance =
        await _sharedPreferenceInstanceCompleter.future;

        return sharedPrefrenceInstance.getBool(key);
  }

  @override
  Future<void> setSuggestedRecipes(List<UserRecipeV2> recipes) async {
    final sharedPrefrenceInstance =
        await _sharedPreferenceInstanceCompleter.future;

    final encoded = jsonEncode(
      recipes.map((recipe) => recipe.toLocalJson()).toList(),
    );

    await sharedPrefrenceInstance.setString(
      _dailySuggestedRecipesKey,
      encoded,
    );
  }

  @override
  Future<List<UserRecipeV2>?> getSuggestedRecipes() async {
    final sharedPrefrenceInstance =
        await _sharedPreferenceInstanceCompleter.future;

    final encoded = sharedPrefrenceInstance.getString(
      _dailySuggestedRecipesKey,
    );

    if (encoded == null) {
      return null;
    }

    final decoded = jsonDecode(encoded) as List;

    return decoded
        .map(
          (json) => UserRecipeV2.fromLocalJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  final Completer<SharedPreferences> _sharedPreferenceInstanceCompleter;
}
