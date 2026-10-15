import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/fridge/presentation/widgets/ingredient_widgets.dart';
import 'package:recipe_ai/receipe/presentation/widget/primary_action_button.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/shopping/presentation/shopping_lists_controller.dart';
import 'package:recipe_ai/shopping/presentation/shopping_widgets.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/widgets/empty_state_view.dart';

/// "Mes listes de courses": every list of the user, most recent first.
class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShoppingListsController(
        di<IShoppingListRepository>(),
        di<IAuthUserService>(),
        di<IUserPersonnalInfoService>(),
      ),
      child: ListenableBuilder(
        listenable: di<TranslationController>(),
        builder: (context, _) => const _ShoppingListsView(),
      ),
    );
  }
}

class _ShoppingListsView extends StatelessWidget {
  const _ShoppingListsView();

  Future<void> _create(BuildContext context) async {
    final controller = context.read<ShoppingListsController>();
    final details = await showShoppingListSheet(context);
    if (details == null) return;
    final list = await controller.create(details.name, details.date);
    if (list != null && context.mounted) {
      context.push('/shopping-lists/${list.id.value}');
    }
  }

  Future<void> _edit(BuildContext context, ShoppingList list) async {
    final controller = context.read<ShoppingListsController>();
    final details = await showShoppingListSheet(context, list: list);
    if (details == null) return;
    await controller.update(list, details.name, details.date);
  }

  Future<void> _delete(BuildContext context, ShoppingList list) async {
    final controller = context.read<ShoppingListsController>();
    final appTexts = di<TranslationController>().currentLanguage;
    final confirmed = await showShoppingConfirmDialog(
      context,
      title: appTexts.shoppingListDeleteTitle(list.name),
      body: appTexts.shoppingListDeleteBody,
      actionLabel: appTexts.shoppingListDelete,
    );
    if (confirmed) await controller.delete(list);
  }

  Future<void> _leave(BuildContext context, ShoppingList list) async {
    final controller = context.read<ShoppingListsController>();
    final appTexts = di<TranslationController>().currentLanguage;
    final confirmed = await showShoppingConfirmDialog(
      context,
      title: appTexts.shoppingListLeaveTitle(list.name),
      body: appTexts.shoppingListLeaveBody,
      actionLabel: appTexts.shoppingListLeaveAction,
    );
    if (confirmed) await controller.leave(list);
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      body: BlocListener<ShoppingListsController, ShoppingListsState>(
        listenWhen: (previous, current) =>
            previous.errorCount != current.errorCount,
        listener: (context, _) =>
            showSnackBar(context, appTexts.fridgeError, isError: true),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShoppingHeader(
                title: appTexts.shoppingListsTitle,
                trailing: _AddListButton(onTap: () => _create(context)),
              ),
              Expanded(
                child: BlocBuilder<ShoppingListsController, ShoppingListsState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case ShoppingListsStatus.loading:
                        return const Center(child: CustomProgress());
                      case ShoppingListsStatus.error:
                        return Center(
                          child: Text(
                            appTexts.shoppingListsLoadError,
                            style: shoppingMutedStyle(13),
                          ),
                        );
                      case ShoppingListsStatus.loaded:
                        break;
                    }

                    if (state.lists.isEmpty) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
                        child: EmptyStateView(
                          iconSize: 60,
                          icon: const ListGlyph(),
                          title: appTexts.shoppingListsEmptyTitle,
                          subtitle: appTexts.shoppingListsEmptySubtitle,
                          child: PrimaryActionButton(
                            label: appTexts.shoppingListNew,
                            onTap: () => _create(context),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      itemCount: state.lists.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final list = state.lists[index];
                        final controller = context
                            .read<ShoppingListsController>();
                        return _ListCard(
                          key: ValueKey(list.id.value),
                          list: list,
                          isOwner: controller.isOwner(list),
                          onTap: () =>
                              context.push('/shopping-lists/${list.id.value}'),
                          onEdit: () => _edit(context, list),
                          onDelete: () => _delete(context, list),
                          onLeave: () => _leave(context, list),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "+" of the header, same look as the fridge add button.
class _AddListButton extends StatelessWidget {
  const _AddListButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Material(
      color: recipeLoaderGreenColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            semanticLabel: appTexts.shoppingListNew,
          ),
        ),
      ),
    );
  }
}

enum _ListAction { edit, delete, leave }

class _ListCard extends StatelessWidget {
  const _ListCard({
    super.key,
    required this.list,
    required this.isOwner,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onLeave,
  });

  final ShoppingList list;

  /// The owner deletes the list, the other members leave it.
  final bool isOwner;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: recipeLoaderMintColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_basket_outlined,
                  size: 20,
                  color: recipeLoaderGreenColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: robotoSlabFontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: recipeLoaderInkColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formatShoppingDate(list.date, appTexts.localeName)}'
                      ' · ${appTexts.shoppingListItemCount(list.itemCount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: shoppingMutedStyle(12.5),
                    ),
                  ],
                ),
              ),
              if (list.isShared)
                Semantics(
                  label: appTexts.shoppingListShared,
                  child: ExcludeSemantics(
                    child: ShoppingAvatarStack(
                      names: list.memberIds.take(3).map(list.nameOf).toList(),
                      size: 24,
                    ),
                  ),
                ),
              PopupMenuButton<_ListAction>(
                tooltip: appTexts.shoppingListMore,
                color: Colors.white,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: recipeLoaderInkColor.withValues(alpha: 0.55),
                ),
                onSelected: (action) => switch (action) {
                  _ListAction.edit => onEdit(),
                  _ListAction.delete => onDelete(),
                  _ListAction.leave => onLeave(),
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _ListAction.edit,
                    child: Text(appTexts.shoppingListRename),
                  ),
                  PopupMenuItem(
                    value: isOwner ? _ListAction.delete : _ListAction.leave,
                    child: Text(
                      isOwner
                          ? appTexts.shoppingListDelete
                          : appTexts.shoppingListLeave,
                      style: const TextStyle(color: shoppingDangerColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
