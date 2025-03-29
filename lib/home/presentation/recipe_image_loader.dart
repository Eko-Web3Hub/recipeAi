import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

import '../../utils/function_caller.dart';

abstract class RecipeImageState extends Equatable {}

class RecipeImageLoading extends RecipeImageState {
  @override
  List<Object?> get props => [];
}

class RecipeImageLoaded extends RecipeImageState {
  RecipeImageLoaded(this.url);

  final String? url;

  @override
  List<Object?> get props => [url];
}

class RecipeImageLoader extends Cubit<RecipeImageState> {
  RecipeImageLoader(
    this._functionsCaller,
    this.recipeName,
  ) : super(RecipeImageLoading()) {
    // _load();
  }

  void _load() async {
    final response = await _functionsCaller.callFunction(
      'retrieve_recipe_image',
      {'recipe_name': recipeName},
    );
    safeEmit(RecipeImageLoaded(response['url']));
  }

  final FunctionsCaller _functionsCaller;
  final String recipeName;
}
