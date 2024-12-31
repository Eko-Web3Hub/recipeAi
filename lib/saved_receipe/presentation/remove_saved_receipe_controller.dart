
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

class RemoveSavedReceipeController extends Cubit<ReceipeItemState> {
  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;

  RemoveSavedReceipeController( this._userReceipeRepository, this._authUserService): super(const ReceipeItemStateSaved());

     Future<void> removeReceipe(String name) async {
    try {
      final uid = _authUserService.currentUser!.uid;
      await _userReceipeRepository.removeSavedReceipe(uid,name);
    } on Exception catch (_) {
      emit(const ReceipeItemStateError("Error removing receipe"));
    }
  }
}