import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/presentation/widget/primary_action_button.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/shopping/presentation/join_shopping_list_controller.dart';
import 'package:recipe_ai/shopping/presentation/shopping_widgets.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/widgets/empty_state_view.dart';

/// Opened by an invitation link: who invites to which list, and the button
/// to join it.
class JoinShoppingListScreen extends StatelessWidget {
  const JoinShoppingListScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JoinShoppingListController(
        token,
        di<IShoppingListRepository>(),
        di<IAuthUserService>(),
        di<IUserPersonnalInfoService>(),
      ),
      child: ListenableBuilder(
        listenable: di<TranslationController>(),
        builder: (context, _) => const _JoinShoppingListView(),
      ),
    );
  }
}

class _JoinShoppingListView extends StatelessWidget {
  const _JoinShoppingListView();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      body: BlocListener<JoinShoppingListController, JoinShoppingListState>(
        listenWhen: (previous, current) =>
            current.status == JoinShoppingListStatus.joined,
        // `go`, not `push`: back from the list must not land on the
        // invitation again.
        listener: (context, state) =>
            context.go('/shopping-lists/${state.invite!.listId.value}'),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShoppingHeader(title: appTexts.shoppingListJoinTitle),
              Expanded(
                child:
                    BlocBuilder<
                      JoinShoppingListController,
                      JoinShoppingListState
                    >(
                      builder: (context, state) => SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
                        child: _JoinContent(state: state),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JoinContent extends StatelessWidget {
  const _JoinContent({required this.state});

  final JoinShoppingListState state;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    switch (state.status) {
      case JoinShoppingListStatus.loading:
      case JoinShoppingListStatus.joined:
        return const Center(child: CustomProgress());
      case JoinShoppingListStatus.invalid:
        return EmptyStateView(
          iconSize: 60,
          icon: Icon(
            Icons.link_off_rounded,
            color: recipeLoaderInkColor.withValues(alpha: 0.45),
          ),
          title: appTexts.shoppingListJoinInvalid,
          subtitle: appTexts.shoppingListJoinInvalidSubtitle,
        );
      case JoinShoppingListStatus.error:
        return Center(
          child: Text(
            appTexts.shoppingListJoinError,
            style: shoppingMutedStyle(13),
          ),
        );
      case JoinShoppingListStatus.ready:
      case JoinShoppingListStatus.joining:
        break;
    }

    final invite = state.invite!;
    final inviter = invite.inviterName.trim();

    return EmptyStateView(
      iconSize: 72,
      icon: ShoppingMemberAvatar(
        name: inviter.isEmpty ? null : inviter,
        size: 56,
      ),
      title: invite.listName,
      subtitle: inviter.isEmpty
          ? appTexts.shoppingListJoinMessageAnonymous
          : appTexts.shoppingListJoinMessage(inviter),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: state.status == JoinShoppingListStatus.joining
            ? const CustomProgress()
            : PrimaryActionButton(
                label: appTexts.shoppingListJoinAction,
                onTap: context.read<JoinShoppingListController>().join,
              ),
      ),
    );
  }
}
