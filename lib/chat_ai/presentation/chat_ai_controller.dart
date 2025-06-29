import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/chat_ai/domain/model/chat_message.dart';
import 'package:recipe_ai/chat_ai/presentation/chat_ai_screen.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';

abstract class ChatAiState {}

class ChatAiLoadingState extends ChatAiState {}

class ChatAiLoadedState extends ChatAiState {
  final List<ChatMessage> chatMessages;

  ChatAiLoadedState(this.chatMessages);
}

List<ChatMessage> _initialChatMessages(AppLocalizations appTexts) =>
    <ChatMessage>[
      ChatMessage(
        TextMessage(
          appTexts.chatInitMessageFindRecipeWithImg,
        ),
        ChatRole.ai,
      ),
      ChatMessage(
        CTAMessage(
          appTexts.importAPicture,
          CtaAction.uploadFile,
        ),
        ChatRole.ai,
      ),
    ];

class ChatAiController extends Cubit<ChatAiState> {
  ChatAiController(
    this.translationController,
  ) : super(ChatAiLoadingState()) {
    _load();
  }

  void _load() {
    emit(
      ChatAiLoadedState(
        _initialChatMessages(
          translationController.currentLanguage,
        ),
      ),
    );
  }

  void addMessage(ChatMessage message) {
    assert(state is ChatAiLoadedState);
    final currentState = state as ChatAiLoadedState;

    emit(
      ChatAiLoadedState(
        [
          ...currentState.chatMessages,
          message,
        ],
      ),
    );
  }

  void removeMessage(int index) {
    assert(state is ChatAiLoadedState);
    final currentState = state as ChatAiLoadedState;

    if (index < 0 || index >= currentState.chatMessages.length) {
      return; // Index out of bounds, do nothing
    }

    final updatedMessages = [...currentState.chatMessages];
    updatedMessages.removeAt(index);

    emit(
      ChatAiLoadedState(updatedMessages),
    );
  }

  void removeLastMessage() {
    assert(state is ChatAiLoadedState);
    final currentState = state as ChatAiLoadedState;

    if (currentState.chatMessages.isEmpty) {
      return; // No messages to remove, do nothing
    }

    final updatedMessages = [...currentState.chatMessages];
    log('Removing last message: ${updatedMessages.length}');
    updatedMessages.removeLast();

    emit(
      ChatAiLoadedState(updatedMessages),
    );
  }

  final TranslationController translationController;
}
