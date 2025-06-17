import 'package:equatable/equatable.dart';
import 'package:recipe_ai/chat_ai/presentation/chat_ai_screen.dart';

class ChatMessage extends Equatable {
  final ChatMessageType message;
  final ChatRole role;

  const ChatMessage(this.message, this.role);

  @override
  List<Object?> get props => [
        message,
        role,
      ];
}

abstract class ChatMessageType {}

class TextMessage extends ChatMessageType {
  final String text;

  TextMessage(this.text);
}

class ImageMessage extends ChatMessageType {
  final String imageUrl;

  ImageMessage(this.imageUrl);
}

enum CtaAction {
  uploadFile,
}

class CTAMessage extends ChatMessageType {
  final CtaAction action;

  final String text;

  CTAMessage(
    this.text,
    this.action,
  );
}
