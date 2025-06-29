import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/chat_ai/application/find_recipe_with_image_usecase.dart';
import 'package:recipe_ai/chat_ai/domain/model/chat_message.dart';
import 'package:recipe_ai/chat_ai/presentation/chat_ai_controller.dart';
import 'package:recipe_ai/chat_ai/presentation/find_recipe_with_image_controller.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';

class _BubleMessageChatContainer extends StatelessWidget {
  const _BubleMessageChatContainer({
    required this.child,
    required this.isRight,
  });

  final Widget? child;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: isRight ? Radius.circular(16) : Radius.circular(0),
          bottomRight: isRight ? Radius.circular(0) : Radius.circular(16),
        ),
      ),
      child: child,
    );
  }
}

class _ChatAiBubble extends StatelessWidget {
  const _ChatAiBubble({
    this.isRight = false,
    required this.text,
  });

  final bool isRight;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _BubleMessageChatContainer(
      isRight: isRight,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PictureDisplay extends StatelessWidget {
  const _PictureDisplay(this.imagePath, this.isRight);

  final bool isRight;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return _BubleMessageChatContainer(
      isRight: isRight,
      child: SizedBox(
        width: 200,
        height: 200,
        child: Image.file(
          File(imagePath),
        ),
      ),
    );
  }
}

enum ChatRole {
  user,
  ai,
}

class ChatAiScreen extends StatelessWidget {
  const ChatAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KitchenInventoryAppBar(
        title: '',
        arrowLeftOnPressed: () => context.pop(),
      ),
      body: BlocProvider(
        create: (_) => FindRecipeWithImageController(
          di<FindRecipeWithImageUsecase>(),
        ),
        child: BlocProvider(
          create: (context) => ChatAiController(
            di<TranslationController>(),
          ),
          child: Builder(builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: BlocBuilder<ChatAiController, ChatAiState>(
                    builder: (context, chatAiState) {
                  if (chatAiState is ChatAiLoadedState) {
                    final chatMessages = chatAiState.chatMessages;

                    return ListView.separated(
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: chatMessages[index].role == ChatRole.user
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: _AiChatMessageBuild.buildMessageWidget(
                            chatMessages[index],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 10,
                      ),
                      itemCount: chatMessages.length,
                    );
                  }

                  return SizedBox.shrink();
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AiChatMessageBuild implements Visitor {
  _AiChatMessageBuild(this.chatMessage);

  final ChatMessage chatMessage;

  Widget? messageWidget;

  static Widget buildMessageWidget(
    ChatMessage chatMessage,
  ) {
    final visitor = _AiChatMessageBuild(chatMessage);

    chatMessage.message.accept(visitor);

    return visitor.messageWidget!;
  }

  @override
  void visitCTAMessage(CTAMessage message) {
    messageWidget = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: _UploadFileCTA(
        message.text,
      ),
    );
  }

  @override
  void visitImageMessage(ImageMessage message) {
    messageWidget = _PictureDisplay(
      message.imageUrl,
      chatMessage.role == ChatRole.user,
    );
  }

  @override
  void visitTextMessage(TextMessage message) {
    messageWidget = _ChatAiBubble(
      isRight: chatMessage.role == ChatRole.user,
      text: message.text,
    );
  }

  @override
  void visitLoaderMessage(LoaderMessage message) {
    messageWidget = _BubleMessageChatContainer(
      isRight: chatMessage.role == ChatRole.user,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.text,
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const CircularProgressIndicator.adaptive(
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  void visitRecipeDisplayMessage(RecipeDisplayMessage message) {
    messageWidget = _BubleMessageChatContainer(
      isRight: chatMessage.role == ChatRole.user,
      child: _RecipeDisplay(
        message.recipe,
      ),
    );
  }
}

class _UploadFileCTA extends StatelessWidget {
  const _UploadFileCTA(
    this.text,
  );

  final String text;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final chatAiController = context.read<ChatAiController>();

    return BlocListener<FindRecipeWithImageController,
        FindRecipeWithImageState?>(
      listener: (context, findRecipeWithImageState) {
        if (findRecipeWithImageState is FindRecipeWithImageLoadedState) {
          chatAiController.removeLastMessage();
          chatAiController.addMessage(
            ChatMessage(
              TextMessage(
                appTexts.recipeFound,
              ),
              ChatRole.ai,
            ),
          );
          chatAiController.addMessage(
            ChatMessage(
              RecipeDisplayMessage(findRecipeWithImageState.userRecipe),
              ChatRole.ai,
            ),
          );
          return;
        }
      },
      child: MainBtn(
        text: text,
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          final XFile? photo = await picker.pickImage(
            source: ImageSource.gallery,
          );

          if (photo != null) {
            chatAiController.addMessage(
              ChatMessage(
                ImageMessage(photo.path),
                ChatRole.user,
              ),
            );

            Future.delayed(
              const Duration(milliseconds: 500),
            ).then(
              (_) async {
                chatAiController.addMessage(
                  ChatMessage(
                    LoaderMessage(
                      appTexts.findRecipeWithImageLoader,
                    ),
                    ChatRole.ai,
                  ),
                );
                context
                    .read<FindRecipeWithImageController>()
                    .findRecipe(photo.path);
              },
            );
          }
        },
      ),
    );
  }
}

class _RecipeDisplay extends StatelessWidget {
  const _RecipeDisplay(
    this.userRecipe,
  );

  final UserReceipeV2 userRecipe;

  @override
  Widget build(BuildContext context) {
    final translationController = di<TranslationController>();
    final appTexts = translationController.currentLanguage;
    final recipe = translationController.currentLanguageEnum.name == 'fr'
        ? userRecipe.receipeFr
        : userRecipe.receipeEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _RecipeImageContainer(),
        const SizedBox(height: 8),
        Text(
          recipe.name,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        MainBtn(
          text: appTexts.seeMore,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _RecipeImageContainer extends StatelessWidget {
  const _RecipeImageContainer({
    this.image,
  });

  final ImageProvider<Object>? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: greyVariantColor,
        image: image == null
            ? null
            : DecorationImage(
                fit: BoxFit.cover,
                image: image!,
              ),
      ),
    );
  }
}
