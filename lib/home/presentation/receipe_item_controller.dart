import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
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
    this._receipeId,
    this._userReceipeRepository,
    this._authUserService,
    this._analyticsRepository,
  ) : super(const ReceipeItemStateSaved()) {
    checkReceipeStatus();
  }
  final EntityId _receipeId;
  final IUserReceipeRepositoryV2 _userReceipeRepository;
  final IAuthUserService _authUserService;
  final IAnalyticsRepository _analyticsRepository;

  Future<void> _saveReceipe() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      await _userReceipeRepository.saveOneReceipt(
        uid,
        _receipeId,
      );
      _analyticsRepository.logEvent(
        RecipeSavedEvent(),
      );
      checkReceipeStatus();
    } on Exception catch (_) {
      emit(const ReceipeItemStateError("Error saving receipe"));
      return;
    }
  }

  Future<void> _removeReceipe() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      await _userReceipeRepository.removeSavedReceipe(
        uid,
        _receipeId,
      );

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
      _removeReceipe();
    } else {
      _saveReceipe();
    }
  }

  Future<void> checkReceipeStatus() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      _userReceipeRepository
          .isReceiptSaved(
        uid,
        _receipeId,
      )
          .listen(
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
