import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_serialization.dart';

class UserReceipeV2 extends Equatable {
  const UserReceipeV2({
    required this.id,
    required this.receipeFr,
    required this.receipeEn,
    required this.createdDate,
    required this.isForHome,
    required this.isAddedToFavorites,
  });

  /// The [id] is the unique identifier for the user recipe.
  /// Is null only when the recipe is not saved in the database.
  final EntityId? id;
  final Receipe receipeFr;
  final Receipe receipeEn;
  final DateTime createdDate;
  final bool isForHome;
  final bool isAddedToFavorites;

  UserReceipeV2 addToFavorite() {
    assert(!isAddedToFavorites, "Already added to favorites");

    return _copyWith(isAddedToFavorites: true);
  }

  UserReceipeV2 removeFromFavorite() {
    assert(isAddedToFavorites, "Already removed from favorites");

    return _copyWith(isAddedToFavorites: false);
  }

  UserReceipeV2 assignId(EntityId id) {
    return _copyWith(id: id);
  }

  factory UserReceipeV2.fromJson(Map<String, dynamic> json) {
    return UserReceipeV2(
      id: EntityId(json["id"]),
      receipeFr: ReceipeSerialization.fromJson(json["receipeFr"]),
      receipeEn: ReceipeSerialization.fromJson(json["receipeEn"]),
      createdDate: (json["createdDate"] as Timestamp).toDate(),
      isForHome: json["isForHome"] as bool,
      isAddedToFavorites: json["isAddedToFavorites"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id?.value,
      "receipeFr": ReceipeSerialization.toJson(receipeFr),
      "receipeEn": ReceipeSerialization.toJson(receipeEn),
      "createdDate": createdDate,
      "isForHome": isForHome,
      "isAddedToFavorites": isAddedToFavorites,
    };
  }

  UserReceipeV2 _copyWith({
    EntityId? id,
    Receipe? receipeFr,
    Receipe? receipeEn,
    DateTime? createdDate,
    bool? isForHome,
    bool? isAddedToFavorites,
  }) {
    return UserReceipeV2(
      id: id ?? this.id,
      receipeFr: receipeFr ?? this.receipeFr,
      receipeEn: receipeEn ?? this.receipeEn,
      createdDate: createdDate ?? this.createdDate,
      isForHome: isForHome ?? this.isForHome,
      isAddedToFavorites: isAddedToFavorites ?? this.isAddedToFavorites,
    );
  }

  @override
  List<Object?> get props => [
        id,
        receipeFr,
        receipeEn,
        createdDate,
        isForHome,
        isAddedToFavorites,
      ];
}

class UserRecipeMetadata extends Equatable {
  const UserRecipeMetadata({
    required this.lastRecipesHomeUpdatedDate,
  });

  final DateTime lastRecipesHomeUpdatedDate;

  UserRecipeMetadata updateLastRecipesHomeUpdatedDate(
    DateTime lastRecipesHomeUpdatedDate,
  ) {
    return _copyWith(lastRecipesHomeUpdatedDate: lastRecipesHomeUpdatedDate);
  }

  UserRecipeMetadata _copyWith({
    DateTime? lastRecipesHomeUpdatedDate,
  }) {
    return UserRecipeMetadata(
      lastRecipesHomeUpdatedDate:
          lastRecipesHomeUpdatedDate ?? this.lastRecipesHomeUpdatedDate,
    );
  }

  factory UserRecipeMetadata.fromJson(Map<String, dynamic> json) {
    return UserRecipeMetadata(
      lastRecipesHomeUpdatedDate:
          (json["lastRecipesHomeUpdatedDate"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lastRecipesHomeUpdatedDate": lastRecipesHomeUpdatedDate,
    };
  }

  @override
  List<Object?> get props => [
        lastRecipesHomeUpdatedDate,
      ];
}
