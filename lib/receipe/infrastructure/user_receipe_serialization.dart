import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';

abstract class UserReceipeSerialization {
  static UserReceipe fromJson(Map<String, dynamic> json) {
    return UserReceipe(
      receipes: (json["receipes"] as List)
          .map((e) => ReceipeSerialization.fromJson(e))
          .toList(),
      lastUpdatedDate: DateTime.parse(json["lastUpdatedDate"]),
    );
  }

  static Map<String, dynamic> toJson(UserReceipe userReceipe) {
    return {
      "receipes": userReceipe.receipes.map((e) => e.toJson()).toList(),
      "lastUpdatedDate": userReceipe.lastUpdatedDate,
    };
  }
}
