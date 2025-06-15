import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class _ChatAiBubble extends StatelessWidget {
  const _ChatAiBubble({
    this.isRight = false,
    required this.text,
  });

  final bool isRight;
  final String text;

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
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
    );
  }
}

final _chatWidgets = <_ChatItem>[
  _ChatItem(
    role: ChatRole.ai,
    widget: _ChatInitWidget(),
  ),
];

enum ChatRole {
  user,
  ai,
}

class _ChatItem {
  const _ChatItem({
    required this.role,
    required this.widget,
  });

  final ChatRole role;
  final Widget widget;
}

class _ChatInitWidget extends StatelessWidget {
  const _ChatInitWidget();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChatAiBubble(
          text: appTexts.chatInitMessageFindRecipeWithImg,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: MainBtn(
            text: appTexts.importAPicture,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: ListView.separated(
            itemBuilder: (context, index) {
              return Align(
                alignment: _chatWidgets[index].role == ChatRole.user
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: _chatWidgets[index].widget,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(
              height: 10,
            ),
            itemCount: _chatWidgets.length,
          ),
        ),
      ),
    );
  }
}
