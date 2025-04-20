import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';

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
  final List<UserReceipeV2> receipes;

  @override
  List<Object> get props => [receipes];
}

class HomeScreenStateError extends HomeScreenState {
  const HomeScreenStateError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class HomeRetrieveReceipeException extends HomeScreenState {
  const HomeRetrieveReceipeException();

  @override
  List<Object> get props => [];
}

/// The controller for the home screen
class HomeScreenController extends Cubit<HomeScreenState> {
  HomeScreenController(
    this._retrieveReceipeFromApiOneTimePerDayUsecase,
    this._userReceipeService, {
    DateTime? now,
  }) : super(const HomeScreenStateLoading()) {
    currentNow = now;
  }
  final IUserRecipeService _userReceipeService;
  final RetrieveReceipeFromApiOneTimePerDayUsecase
      _retrieveReceipeFromApiOneTimePerDayUsecase;

  Future<void> _load() async {
    try {
      final receipes =
          await _retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(
        currentNow ?? DateTime.now(),
      );
      emit(HomeScreenStateLoaded(receipes));
    } on RetrieveReceipeException catch (_) {
      emit(const HomeRetrieveReceipeException());
    }
  }

  Future<void> reload() async {
    emit(const HomeScreenStateLoading());
    await _load();
  }

  Future<void> regenerateUserReceipe() async {
    emit(const HomeScreenStateLoading());
    await _userReceipeService.removeLastRecipesHomeUpdatedDate();
    await _load();
  }

  /// Is used for testing purposes
  DateTime? currentNow;
}
