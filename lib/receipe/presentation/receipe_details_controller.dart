import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/user_recipe_translate_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
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
    this.seconds,
    this._userRecipeTranslateService,
  ) : super(
          const ReceipeDetailsState.loading(),
        ) {
    _load(receipeSample);
  }

  ReceipeDetailsController.fromReceipe(
    Receipe receipe,
    this._userRecipeTranslateService,
  ) : super(
          ReceipeDetailsState.loaded(receipe),
        ) {
    _load(receipe);
  }

  void _load(Receipe recipe) async {
    final recipeName = convertRecipeNameToFirestoreId(recipe.name);

    _userRecipeTranslateService
        .watchTranslatedRecipe(
      recipeName: recipeName,
    )
        .listen(
      (event) {
        if (event != null) {
          safeEmit(
            ReceipeDetailsState.loaded(
              event,
            ),
          );
        }
      },
    );
  }

  int? seconds;
  EntityId? receipeId;
  final UserRecipeTranslateService _userRecipeTranslateService;
}
