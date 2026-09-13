import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';

class UserFinishedRecipe {
  final EntityId recipeId;
  final int note;
  final DateTime? finishedAt;

  UserFinishedRecipe({
    required this.recipeId,
    required this.note,
    this.finishedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId.value,
      'note': note,
      'finishedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserFinishedRecipe.fromJson(Map<String, dynamic> json) {
    return UserFinishedRecipe(
      recipeId: EntityId(json['recipeId']),
      note: json['note'],
      finishedAt: (json['finishedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// How many times a recipe has been cooked, and the most recent time it was.
class RecipeCookedSummary {
  const RecipeCookedSummary({required this.count, required this.lastCookedAt});

  final int count;
  final DateTime? lastCookedAt;
}
