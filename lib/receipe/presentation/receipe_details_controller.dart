import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/utils/constant.dart';

class ReceipeDetailsState {
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
}

class ReceipeDetailsController extends Cubit<ReceipeDetailsState> {
  ReceipeDetailsController(
    this.receipeId,
  ) : super(
          const ReceipeDetailsState.loading(),
        ) {
    _load();
  }

  void _load() async {
    await Future.delayed(const Duration(seconds: 3));
    emit(
      const ReceipeDetailsState.loaded(
        receipeSample,
      ),
    );
  }

  EntityId receipeId;
}
