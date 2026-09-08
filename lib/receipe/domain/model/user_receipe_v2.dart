import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_serialization.dart';

class UserRecipeV2 extends Equatable {
  const UserRecipeV2({
    required this.id,
    required this.receipeFr,
    required this.receipeEn,
    required this.createdDate,
  });

  /// The [id] is the unique identifier for the user recipe.
  /// Is null only when the recipe is not saved in the database.
  final EntityId? id;
  final Receipe receipeFr;
  final Receipe receipeEn;
  final DateTime createdDate;

  UserRecipeV2 assignId(EntityId id) {
    return _copyWith(id: id);
  }

  factory UserRecipeV2.fromJson(Map<String, dynamic> json) {
    return UserRecipeV2(
      id: EntityId(json["id"]),
      receipeFr: ReceipeSerialization.fromJson(json["receipeFr"]),
      receipeEn: ReceipeSerialization.fromJson(json["receipeEn"]),
      createdDate: json["createdDate"] is String
          ? DateTime.parse(json["createdDate"] as String)
          : (json["createdDate"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id?.value,
      "receipeFr": ReceipeSerialization.toJson(receipeFr),
      "receipeEn": ReceipeSerialization.toJson(receipeEn),
      "createdDate": createdDate,
    };
  }

  /// Used to store/read this recipe outside of Firestore (e.g. local
  /// storage), where [createdDate] can't round-trip through a Firestore
  /// [Timestamp] and must be a plain JSON-encodable value instead.
  factory UserRecipeV2.fromLocalJson(Map<String, dynamic> json) {
    return UserRecipeV2(
      id: json["id"] == null ? null : EntityId(json["id"]),
      receipeFr: ReceipeSerialization.fromJson(json["receipeFr"]),
      receipeEn: ReceipeSerialization.fromJson(json["receipeEn"]),
      createdDate: DateTime.parse(json["createdDate"] as String),
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      "id": id?.value,
      "receipeFr": ReceipeSerialization.toJson(receipeFr),
      "receipeEn": ReceipeSerialization.toJson(receipeEn),
      "createdDate": createdDate.toIso8601String(),
    };
  }

  UserRecipeV2 _copyWith({
    EntityId? id,
    Receipe? receipeFr,
    Receipe? receipeEn,
    DateTime? createdDate,
  }) {
    return UserRecipeV2(
      id: id ?? this.id,
      receipeFr: receipeFr ?? this.receipeFr,
      receipeEn: receipeEn ?? this.receipeEn,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  List<Object?> get props => [id, receipeFr, receipeEn, createdDate];
}

class UserRecipeMetadata extends Equatable {
  const UserRecipeMetadata({required this.lastRecipesHomeUpdatedDate});

  final DateTime? lastRecipesHomeUpdatedDate;

  const UserRecipeMetadata.initial() : lastRecipesHomeUpdatedDate = null;

  UserRecipeMetadata updateLastRecipesHomeUpdatedDate(
    DateTime lastRecipesHomeUpdatedDate,
  ) {
    return _copyWith(lastRecipesHomeUpdatedDate: lastRecipesHomeUpdatedDate);
  }

  UserRecipeMetadata removeLastRecipesHomeUpdatedDate() {
    return UserRecipeMetadata(lastRecipesHomeUpdatedDate: null);
  }

  UserRecipeMetadata _copyWith({DateTime? lastRecipesHomeUpdatedDate}) {
    return UserRecipeMetadata(
      lastRecipesHomeUpdatedDate:
          lastRecipesHomeUpdatedDate ?? this.lastRecipesHomeUpdatedDate,
    );
  }

  factory UserRecipeMetadata.fromJson(Map<String, dynamic> json) {
    return UserRecipeMetadata(
      lastRecipesHomeUpdatedDate: json["lastRecipesHomeUpdatedDate"] == null
          ? null
          : (json["lastRecipesHomeUpdatedDate"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"lastRecipesHomeUpdatedDate": lastRecipesHomeUpdatedDate};
  }

  @override
  List<Object?> get props => [lastRecipesHomeUpdatedDate];
}
