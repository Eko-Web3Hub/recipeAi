import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class SavedReceipeState extends Equatable {
  const SavedReceipeState();
  @override
  List<Object> get props => [];
}

class SavedReceipeStateLoading extends SavedReceipeState {
  const SavedReceipeStateLoading();
}

class SavedReceipeStateLoaded extends SavedReceipeState {
  const SavedReceipeStateLoaded(this.savedReceipes);
  final List<UserReceipeV2> savedReceipes;

  @override
  List<Object> get props => [savedReceipes];
}

class SavedReceipeStateError extends SavedReceipeState {
  const SavedReceipeStateError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

/// The controller for the saved receipe screen
class SavedReceipeController extends Cubit<SavedReceipeState> {
  SavedReceipeController(this._userReceipeService)
      : super(const SavedReceipeStateLoading()) {
    _load();
  }

  final IUserRecipeService _userReceipeService;

  Future<void> _load() async {
    try {
      _userReceipeService.watchAllSavedReceipes().listen(
        (savedReceipes) {
          safeEmit(SavedReceipeStateLoaded(savedReceipes));
        },
      );
    } on Exception catch (e) {
      log(e.toString());
      emit(SavedReceipeStateError(e.toString()));
    }
  }
}
