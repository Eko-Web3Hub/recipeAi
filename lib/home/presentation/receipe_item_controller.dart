import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

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
  ReceipeItemController(this._receipe, this._userReceipeRepository,
      this._authUserService, this._index)
      : super(const ReceipeItemStateSaved()) {
    checkReceipeStatus();
  }
  final Receipe _receipe;
  final int _index;
  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;

  Future<void> saveReceipe() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      await _userReceipeRepository.saveOneReceipt(uid, _index, _receipe);
      checkReceipeStatus();
    } on Exception catch (_) {
      emit(const ReceipeItemStateError("Error saving receipe"));
      return;
    }
  }

  Future<void> removeReceipe() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      await _userReceipeRepository.removeSavedReceipe(
          uid, "${uid.value}$_index");
      checkReceipeStatus();
    } on Exception catch (_) {
      emit(const ReceipeItemStateError("Error removing saved receipe"));
      return;
    }
  }

  Future<void> checkReceipeStatus() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      _userReceipeRepository.isReceiptSaved(uid, _index).listen(
            (isSaved) {
               emit(isSaved
          ? const ReceipeItemStateSaved()
          : const ReceipeItemStateUnsaved());
            },
          );
     
    } on Exception catch (_) {
      emit(const ReceipeItemStateError("Error checking receipe status"));
    }
  }
}
