import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/saved_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

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
  final List<SavedReceipe> savedReceipes;

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
  SavedReceipeController(this._userReceipeRepository, this._authUserService)
      : super(const SavedReceipeStateLoading()) {
    _load();
  }

  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;

  Future<void> _load() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      _userReceipeRepository.watchAllSavedReceipes(uid).listen(
            (savedReceipts) {
              emit(SavedReceipeStateLoaded(savedReceipts));
            },
          );
    } on Exception catch (e) {
      log(e.toString());
      emit(SavedReceipeStateError(e.toString()));
    }
  }
}
