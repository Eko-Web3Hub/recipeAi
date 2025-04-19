import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

class UserReceipeV2 extends Equatable {
  const UserReceipeV2({
    required this.id,
    required this.receipesFr,
    required this.receipesEn,
    required this.createdDate,
    required this.isForHome,
    required this.isAddedToFavorites,
  });

  /// The [id] is the unique identifier for the user recipe.
  /// Is null only when the recipe is not saved in the database.
  final EntityId? id;
  final List<Receipe> receipesFr;
  final List<Receipe> receipesEn;
  final DateTime createdDate;
  final bool isForHome;
  final bool isAddedToFavorites;

  @override
  List<Object?> get props => [
        receipesFr,
        receipesEn,
        createdDate,
        isForHome,
        isAddedToFavorites,
      ];
}
