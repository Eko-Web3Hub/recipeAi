import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/onboarding_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/infrastructure/serialization/onboarding_step_serialization.dart';

const onboardingQuizzAssetPath = 'assets/data/onboarding_quizz.json';

typedef AssetLoader = Future<String> Function(String path);

/// Reads the `OnboardingQuizz` collection, one document per step keyed by the
/// step key. The bundled asset — the same file the collection is seeded from —
/// takes over when Firestore fails or holds nothing usable, so the onboarding
/// is never blocked.
class FirestoreOnboardingQuizzRepository implements IOnboardingQuizzRepository {
  FirestoreOnboardingQuizzRepository(this._firestore, {AssetLoader? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  static const String _collection = 'OnboardingQuizz';

  final FirebaseFirestore _firestore;
  final AssetLoader _loadAsset;

  List<OnboardingStep>? _cache;

  @override
  Future<List<OnboardingStep>> retrieve() async {
    if (_cache case final steps?) return steps;

    final remote = await _retrieveRemote();
    if (remote.isNotEmpty) return _cache = remote;

    // Not cached: the next call gives Firestore another chance.
    return _retrieveBundled();
  }

  Future<List<OnboardingStep>> _retrieveRemote() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return OnboardingStepSerialization.catalogueFromJson({
        for (final doc in snapshot.docs) doc.id: doc.data(),
      });
    } catch (e) {
      log('Onboarding quizz: Firestore unavailable, using the bundled one: $e');
      return const [];
    }
  }

  Future<List<OnboardingStep>> _retrieveBundled() async {
    final json = jsonDecode(await _loadAsset(onboardingQuizzAssetPath));
    return OnboardingStepSerialization.catalogueFromJson(
      json as Map<String, dynamic>,
    );
  }
}
