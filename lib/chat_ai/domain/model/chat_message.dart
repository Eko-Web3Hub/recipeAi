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

abstract class Visitor {
  void visitTextMessage(TextMessage message);
  void visitImageMessage(ImageMessage message);
  void visitCTAMessage(CTAMessage message);
  void visitLoaderMessage(LoaderMessage message);
}

abstract class ChatMessageType {
  void accept(Visitor visitor);
}

class TextMessage extends ChatMessageType {
  final String text;

  TextMessage(this.text);

  @override
  void accept(Visitor visitor) => visitor.visitTextMessage(this);
}

class ImageMessage extends ChatMessageType {
  final String imageUrl;

  ImageMessage(this.imageUrl);

  @override
  void accept(Visitor visitor) => visitor.visitImageMessage(this);
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

  @override
  void accept(Visitor visitor) => visitor.visitCTAMessage(this);
}

class LoaderMessage extends ChatMessageType {
  final String text;

  LoaderMessage(
    this.text,
  );

  @override
  void accept(Visitor visitor) => visitor.visitLoaderMessage(
        this,
      );
}
