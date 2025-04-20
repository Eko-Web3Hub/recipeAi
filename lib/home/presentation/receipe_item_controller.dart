import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class ReceipeItemState extends Equatable {
  const ReceipeItemState();
  @override
  List<Object> get props => [];
}

class ReceipeItemStateSaved extends ReceipeItemState {
  const ReceipeItemStateSaved();
}

class ReceipeItemStateUnsaved extends ReceipeItemState {
  const ReceipeItemStateUnsaved();
}

class ReceipeItemStateError extends ReceipeItemState {
  const ReceipeItemStateError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class ReceipeItemController extends Cubit<ReceipeItemState> {
  ReceipeItemController(
    this._receipe,
    this._userRecipeService,
    this._analyticsRepository,
  ) : super(const ReceipeItemStateUnsaved()) {
    checkReceipeStatus();
  }
  final UserReceipeV2 _receipe;
  final IUserRecipeService _userRecipeService;
  final IAnalyticsRepository _analyticsRepository;

  Future<void> _saveReceipe() async {
    try {
      await _userRecipeService.addToFavorite(_receipe);
      _analyticsRepository.logEvent(
        RecipeSavedEvent(),
      );
      checkReceipeStatus();
    } on Exception catch (_) {
      emit(const ReceipeItemStateError("Error saving receipe"));
      return;
    }
  }

  Future<void> _removeFromReceipe() async {
    try {
      await _userRecipeService.removeFromFavorite(_receipe);
      _analyticsRepository.logEvent(
        RecipeUnSaveEvent(),
      );
      checkReceipeStatus();
    } on Exception catch (_) {
      emit(const ReceipeItemStateError("Error removing saved receipe"));
      return;
    }
  }

  void toggleFavorite() {
    if (state is ReceipeItemStateSaved) {
      _removeFromReceipe();
    } else {
      _saveReceipe();
    }
  }

  Future<void> checkReceipeStatus() async {
    try {
      _userRecipeService.isReceiptSaved(_receipe.id!).listen(
        (isSaved) {
          safeEmit(isSaved
              ? const ReceipeItemStateSaved()
              : const ReceipeItemStateUnsaved());
        },
      );
    } on Exception catch (_) {
      emit(const ReceipeItemStateError("Error checking receipe status"));
    }
  }
}
