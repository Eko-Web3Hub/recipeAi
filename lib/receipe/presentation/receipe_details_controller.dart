import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/utils/constant.dart';

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
  ) : super(
          const ReceipeDetailsState.loading(),
        ) {
    _load();
  }

  ReceipeDetailsController.fromReceipe(Receipe receipe)
      : super(
          ReceipeDetailsState.loaded(receipe),
        );

  void _load() async {
    await Future.delayed(
      Duration(seconds: seconds ?? 3),
    );
    emit(
       ReceipeDetailsState.loaded(
        receipeSample,
      ),
    );
  }

  int? seconds;
  EntityId? receipeId;
}
