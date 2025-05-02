import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

import 'package:recipe_ai/utils/safe_emit.dart';

class ReceipeDetailsState extends Equatable {
  const ReceipeDetailsState(
    this.reciepe,
  );

  const ReceipeDetailsState.loading() : this(null);
  const ReceipeDetailsState.loaded(
    Receipe reciepe,
  ) : this(
          reciepe,
        );

  final Receipe? reciepe;

  @override
  List<Object?> get props => [reciepe];
}

class ReceipeDetailsController extends Cubit<ReceipeDetailsState> {
  ReceipeDetailsController(
    this.receipeId,
    this.appLanguage,
    this.userSharingUid,
    this.seconds,
    this._authUserService,
    this._userAccountMetaDataRepository,
    this._userReceipeRepositoryV2,
  ) : super(
          const ReceipeDetailsState.loading(),
        ) {
    _loadRecipeUsingId();
  }

  ReceipeDetailsController.fromReceipe(
    UserReceipeV2 receipe,
    this._authUserService,
    this._userAccountMetaDataRepository,
    this._userReceipeRepositoryV2,
  ) : super(
          ReceipeDetailsState.loaded(receipe.receipeEn),
        ) {
    _load(
      receipe,
    );
  }

  void _loadRecipeUsingId() async {
    log('Loading recipe using ID: $receipeId');
    log('with language: $appLanguage');
    final recipe = await _userReceipeRepositoryV2.getRecipeByName(
      appLanguage!,
      receipeId!,
      userSharingUid!,
    );
    _load(recipe!);
  }

  void _load(UserReceipeV2 userRecipe) async {
    _subscription = _userAccountMetaDataRepository
        .watchUserAccount(_authUserService.currentUser!.uid)
        .listen((userAccount) async {
      if (userAccount != null) {
        if (userAccount.appLanguage == AppLanguage.fr) {
          safeEmit(
            ReceipeDetailsState.loaded(
              userRecipe.receipeFr,
            ),
          );
          return;
        }

        safeEmit(
          ReceipeDetailsState.loaded(
            userRecipe.receipeEn,
          ),
        );
      } else {
        // If user account is null, emit the recipe in English by default
        ReceipeDetailsState.loaded(
          userRecipe.receipeEn,
        );
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  int? seconds;
  EntityId? receipeId;
  EntityId? userSharingUid;
  final IAuthUserService _authUserService;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;
  final IUserReceipeRepositoryV2 _userReceipeRepositoryV2;
  AppLanguage? appLanguage;
  StreamSubscription? _subscription;
}
