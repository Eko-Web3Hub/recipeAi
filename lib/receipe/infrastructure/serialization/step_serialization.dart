
import 'package:recipe_ai/receipe/domain/model/step.dart';

abstract class StepSerialization {
  static ReceipeStep fromJson(Map<String, dynamic> json) {
    return ReceipeStep(description: json["description"], duration: json["duration"]);
  }


}