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

class HomeScreenController extends Cubit<HomeScreenState> {
  HomeScreenController(
    this._retrieveReceipeFromApiOneTimePerDayUsecase,
  ) : super(const HomeScreenStateLoading()) {
    _load();
  }

  final RetrieveReceipeFromApiOneTimePerDayUsecase
      _retrieveReceipeFromApiOneTimePerDayUsecase;

  Future<void> _load() async {
    try {
      final receipes =
          await _retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(
        DateTime.now(),
      );
      emit(HomeScreenStateLoaded(receipes));
    } on RetrieveReceipeException catch (e) {
      log(e.message);
      emit(HomeScreenStateError(e.message));
    }
  }
}
