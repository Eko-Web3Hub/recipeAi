import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

enum ReceipeItemStatus { saved, unsaved }

class ReceipeItemController extends Cubit<ReceipeItemStatus> {
  ReceipeItemController(this._receipe, this._userReceipeRepository,
      this._authUserService, this._index)
      : super(ReceipeItemStatus.unsaved) {
    checkReceipeStatus();
  }
  final Receipe _receipe;
  final int _index;
  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;

  Future<void> saveReceipe() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      await _userReceipeRepository.saveOneReceipt(uid,_index ,_receipe);
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  Future<void> checkReceipeStatus() async {
    try {
      final uid = _authUserService.currentUser!.uid;
     final isSaved = await _userReceipeRepository.isOneReceiptSaved(uid, _index);
      emit(isSaved ? ReceipeItemStatus.saved : ReceipeItemStatus.unsaved);
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
