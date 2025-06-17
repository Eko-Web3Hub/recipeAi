import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/chat_ai/presentation/chat_ai_controller.dart';
import 'package:recipe_ai/l10n/app_localizations_en.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';

class TranslationControllerMock extends Mock implements TranslationController {}

void main() {
  late TranslationController translationController;

  setUp(() {
    translationController = TranslationControllerMock();

    when(() => translationController.currentLanguage).thenAnswer(
      (_) => AppLocalizationsEn(),
    );
  });

  ChatAiController sut() => ChatAiController(translationController);

  blocTest<ChatAiController, ChatAiState>(
    'should load initial chat messages',
    build: () => sut(),
    verify: (sut) {
      expect(sut.state, isA<ChatAiLoadedState>());
      final loadedState = sut.state as ChatAiLoadedState;
      expect(
        loadedState.chatMessages.length,
        equals(2),
      );
    },
  );
}
