import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/application/user_preference_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';

class UserPreferenceRepository extends Mock
    implements IUserPreferenceRepository {}

void main() {
  late IUserPreferenceRepository userPreferenceRepository;
  const uid = EntityId('uid');
  const userPreference = UserPreference({});

  setUp(() {
    userPreferenceRepository = UserPreferenceRepository();
  });

  test(
    'should save user preference',
    () async {
      when(() => userPreferenceRepository.save(uid, userPreference)).thenAnswer(
        (_) => Future.value(),
      );
      final sut = UserPreferenceService(
        userPreferenceRepository,
      );

      await sut.saveUserPreference(uid, userPreference);

      verify(() => userPreferenceRepository.save(uid, userPreference))
          .called(1);
    },
  );
}
