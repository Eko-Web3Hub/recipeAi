import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/receipe/domain/model/saved_receipe.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_serialization.dart';

abstract class SavedReceipeSerialization {
  static SavedReceipe fromQueryDocumentSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    log("saved data: ${doc.data()}");
    return SavedReceipe(
      receipe: ReceipeSerialization.fromJson(doc.data()),
      documentId: doc.id,
    );
  }
}
