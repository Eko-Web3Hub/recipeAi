import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';

class FirestoreUserPreferenceQuizzRepository
    implements IUserPreferenceQuizzRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserPreferenceQuizzRepository(this._firestore);

  static const String _collection = 'UserPreferenceQuizz';

  @override
  Future<List<UserPreferenceQuestion>> retrieve() async {
    final doc = await _firestore.collection(_collection).get();

    if (doc.docs.isEmpty) {
      return [];
    } else {
      return doc.docs.map<UserPreferenceQuestion>(
        (e) {
          final data = e.data();
          final type =
              userPreferenceQuestionTypeFromString(data['type'] as String);
          if (type == UserPreferenceQuestionType.multipleChoice) {
            return UserPreferenceQuestionMultipleChoice.fromJson(data);
          } else {
            throw UnimplementedError();
          }
        },
      ).toList();
    }
  }
}
