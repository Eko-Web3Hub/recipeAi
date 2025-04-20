import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class HistoricState {}

class HistoricLoadingState extends HistoricState {}

class HistoricLoadedState extends HistoricState {
  HistoricLoadedState(this.recipes);

  final List<UserReceipeV2> recipes;
}

class HistoricController extends Cubit<HistoricState> {
  HistoricController(this._userRecipeService) : super(HistoricLoadingState()) {
    _load();
  }

  void _load() async {
    final recipes = await _userRecipeService.getAllUserRecipes();

    safeEmit(HistoricLoadedState(recipes));
  }

  final IUserRecipeService _userRecipeService;
}
