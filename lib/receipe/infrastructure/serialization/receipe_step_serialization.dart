import 'package:recipe_ai/receipe/domain/model/step.dart';

abstract class ReceipeStepSerialization {
  static ReceipeStep fromJson(Map<String, dynamic> json) {
    return ReceipeStep(
      description: json["description"],
      duration: json["duration"],
    );
  }

  static Map<String, dynamic> toJson(ReceipeStep receipeStep) {
    return {
      "description": receipeStep.description,
      "duration": receipeStep.duration,
    };
  }
}
