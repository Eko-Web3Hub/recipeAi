import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_serialization.dart';

abstract class UserReceipeSerialization {
  static UserReceipe fromJson(Map<String, dynamic> json) {
    return UserReceipe(
      receipes: (json["receipes"] as List)
          .map(
            (e) => ReceipeSerialization.fromJson(e),
          )
          .toList(),
      lastUpdatedDate: (json["lastUpdatedDate"] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> toJson(UserReceipe userReceipe) {
    return {
      "receipes": userReceipe.receipes
          .map(
            (e) => ReceipeSerialization.toJson(e),
          )
          .toList(),
      "lastUpdatedDate": userReceipe.lastUpdatedDate,
    };
  }
}
