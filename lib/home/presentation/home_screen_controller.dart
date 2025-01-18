import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

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

/// The controller for the home screen
class HomeScreenController extends Cubit<HomeScreenState> {
  HomeScreenController(this._retrieveReceipeFromApiOneTimePerDayUsecase,
      {DateTime? now})
      : super(const HomeScreenStateLoading()) {
    currentNow = now;
    load();
  }

  final RetrieveReceipeFromApiOneTimePerDayUsecase
      _retrieveReceipeFromApiOneTimePerDayUsecase;

  Future<void> load() async {
    try {
      _subscription = _retrieveReceipeFromApiOneTimePerDayUsecase
          .retrieve(
        currentNow ?? DateTime.now(),
      )
          .listen(
        (receipes) {
          emit(HomeScreenStateLoaded(receipes));
          return;
        },
      );
    } on RetrieveReceipeException catch (e) {
      log(e.message);
      emit(HomeScreenStateError(e.message));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  /// Is used for testing purposes
  DateTime? currentNow;
  late StreamSubscription<List<Receipe>> _subscription;
}
