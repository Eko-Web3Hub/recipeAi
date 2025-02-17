import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

import '../../receipe/domain/repositories/user_receipe_repository.dart';

abstract class HomeScreenState extends Equatable {
  const HomeScreenState();
  @override
  List<Object> get props => [];
}

class HomeScreenStateLoading extends HomeScreenState {
  const HomeScreenStateLoading();
}

class HomeScreenStateLoaded extends HomeScreenState {
  const HomeScreenStateLoaded(this.receipes);
  final List<Receipe> receipes;

  @override
  List<Object> get props => [receipes];
}

class HomeScreenStateError extends HomeScreenState {
  const HomeScreenStateError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class HomeRtrieveReceipeException extends HomeScreenState {
  const HomeRtrieveReceipeException();

  @override
  List<Object> get props => [];
}

/// The controller for the home screen
class HomeScreenController extends Cubit<HomeScreenState> {
  HomeScreenController(
    this._retrieveReceipeFromApiOneTimePerDayUsecase,
    this._userReceipeRepository,
    this._authUserService, {
    DateTime? now,
  }) : super(const HomeScreenStateLoading()) {
    currentNow = now;
  }
  final IUserReceipeRepository _userReceipeRepository;
  final RetrieveReceipeFromApiOneTimePerDayUsecase
      _retrieveReceipeFromApiOneTimePerDayUsecase;
  final IAuthUserService _authUserService;

  Future<void> _load() async {
    try {
      final receipes =
          await _retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(
        currentNow ?? DateTime.now(),
      );
      emit(HomeScreenStateLoaded(receipes));
    } on RetrieveReceipeException catch (_) {
      emit(const HomeRtrieveReceipeException());
    }
  }

  Future<void> reload() async {
    emit(const HomeScreenStateLoading());
    await _load();
  }

  Future<void> regenerateUserReceipe() async {
    emit(const HomeScreenStateLoading());
    await _userReceipeRepository.deleteUserReceipe(
      _authUserService.currentUser!.uid,
    );
    await _load();
  }

  /// Is used for testing purposes
  DateTime? currentNow;
}
