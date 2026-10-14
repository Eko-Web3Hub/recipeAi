import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/fridge/application/fridge_stock_service.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/ingredient_search.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/fridge/presentation/fridge_labels.dart';
import 'package:recipe_ai/fridge/presentation/fridge_quantity_sheet.dart';
import 'package:recipe_ai/fridge/presentation/widgets/ingredient_widgets.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/shopping/domain/shopping_aisles.dart';
import 'package:recipe_ai/shopping/presentation/shopping_list_controller.dart';
import 'package:recipe_ai/shopping/presentation/shopping_members_sheet.dart';
import 'package:recipe_ai/shopping/presentation/shopping_widgets.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/widgets/empty_state_view.dart';

/// One shopping list: its members at the top, then its items grouped by
/// aisle, added and edited like in the fridge. Checking an item moves it to
/// the fridge.
class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key, required this.listId});

  final EntityId listId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShoppingListController(
        listId,
        di<IShoppingListRepository>(),
        di<IIngredientCatalogRepository>(),
        di<IFridgeRepository>(),
        di<FridgeStockService>(),
        di<IAuthUserService>(),
        di<IUserPersonnalInfoService>(),
      ),
      child: ListenableBuilder(
        listenable: di<TranslationController>(),
        builder: (context, _) => const _ShoppingListView(),
      ),
    );
  }
}

class _ShoppingListView extends StatefulWidget {
  const _ShoppingListView();

  @override
  State<_ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<_ShoppingListView> {
  final _queryController = TextEditingController();
  final _queryFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _queryFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _queryController.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  ShoppingListController get _controller =>
      context.read<ShoppingListController>();

  Future<void> _openNewSheet(FridgeItem draft) async {
    final controller = _controller;
    final appTexts = di<TranslationController>().currentLanguage;
    _queryFocus.unfocus();
    final result = await showFridgeQuantitySheet(
      context,
      item: draft,
      units: controller.unitsFor(draft),
      mergesIntoExisting: controller.existingFor(draft) != null,
      addLabel: appTexts.shoppingListAddToList,
    );
    if (result case FridgeSheetSaved(:final item)) controller.add(item);
  }

  Future<void> _openEditSheet(ShoppingItem item) async {
    final controller = _controller;
    _queryFocus.unfocus();
    final result = await showFridgeQuantitySheet(
      context,
      item: item.ingredient,
      units: controller.unitsFor(item.ingredient),
      isEdit: true,
    );
    switch (result) {
      case FridgeSheetSaved(item: final ingredient):
        controller.save(item.withIngredient(ingredient));
      case FridgeSheetRemoved():
        controller.remove(item);
      case null:
        break;
    }
  }

  Future<void> _invite() async {
    final appTexts = di<TranslationController>().currentLanguage;
    final controller = _controller;
    final url = await controller.invite();
    final list = controller.state.list;
    if (url == null || list == null) return;
    await SharePlus.instance.share(
      ShareParams(text: appTexts.shoppingListInviteShareText(list.name, url)),
    );
  }

  Future<void> _openMembers() async {
    final controller = _controller;
    final list = controller.state.list;
    if (list == null) return;
    _queryFocus.unfocus();
    final action = await showShoppingMembersSheet(
      context,
      list: list,
      currentUserId: controller.currentUserId,
    );
    if (!mounted) return;
    final appTexts = di<TranslationController>().currentLanguage;
    switch (action) {
      case ShoppingMembersInvite():
        await _invite();
      case ShoppingMembersRemove(:final uid, :final name):
        final confirmed = await showShoppingConfirmDialog(
          context,
          title: appTexts.shoppingListRemoveMemberTitle(name),
          body: appTexts.shoppingListRemoveMemberBody(name),
          actionLabel: appTexts.shoppingListRemoveMember,
        );
        if (confirmed) await controller.removeMember(uid);
      case ShoppingMembersLeave():
        final confirmed = await showShoppingConfirmDialog(
          context,
          title: appTexts.shoppingListLeaveTitle(list.name),
          body: appTexts.shoppingListLeaveBody,
          actionLabel: appTexts.shoppingListLeaveAction,
        );
        if (!confirmed) return;
        final left = await controller.leave();
        if (left && mounted) context.pop();
      case null:
        break;
    }
  }

  Future<void> _submitQuery() async {
    final draft = await _controller.submitQuery();
    _queryController.clear();
    if (draft != null) {
      await _openNewSheet(draft);
    } else {
      _queryFocus.requestFocus();
    }
  }

  void _pickSuggestion(IngredientSuggestion suggestion) {
    _controller.clearQuery();
    _queryController.clear();
    _openNewSheet(suggestion.draft);
  }

  void _pickUsual(FridgeItem usual) =>
      _openNewSheet(_controller.draftForUsual(usual));

  void _showFeedback(ShoppingListFeedback feedback) {
    final appTexts = di<TranslationController>().currentLanguage;
    final lang = appTexts.localeName;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    SnackBarAction undo(VoidCallback onPressed) => SnackBarAction(
      label: appTexts.fridgeUndo,
      textColor: const Color(0xFF9AD97A),
      onPressed: onPressed,
    );

    switch (feedback) {
      case ShoppingItemRemovedFeedback(:final item):
        messenger.showSnackBar(
          inkSnackBar(
            appTexts.fridgeRemoved(item.ingredient.displayName(lang)),
            duration: const Duration(milliseconds: 4500),
            action: undo(() => _controller.undoRemove(item)),
          ),
        );
      case ShoppingItemBoughtFeedback(:final item, :final change):
        messenger.showSnackBar(
          inkSnackBar(
            appTexts.shoppingListBought(item.ingredient.displayName(lang)),
            duration: const Duration(milliseconds: 4500),
            action: undo(() => _controller.undoBuy(item, change)),
          ),
        );
      case ShoppingItemMergedFeedback(:final item, :final outcome):
        final name = item.displayName(lang);
        final quantity = appTexts.fridgeQuantityLabel(item.amount, item.unit);
        messenger.showSnackBar(
          inkSnackBar(switch (outcome) {
            MergeOutcome.alreadyIn => appTexts.shoppingListAlreadyInToast(name),
            MergeOutcome.quantitySet => appTexts.fridgeQuantitySet(
              name,
              quantity,
            ),
            MergeOutcome.total => appTexts.fridgeTotal(name, quantity),
            MergeOutcome.replaced => appTexts.fridgeReplaced(name),
          }),
        );
      case ShoppingListErrorFeedback():
        showSnackBar(context, appTexts.fridgeError, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final bottomInset = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      body: BlocListener<ShoppingListController, ShoppingListState>(
        listenWhen: (previous, current) =>
            current.feedback != null && previous.feedback != current.feedback,
        listener: (context, state) => _showFeedback(state.feedback!),
        child: SafeArea(
          bottom: false,
          child: BlocBuilder<ShoppingListController, ShoppingListState>(
            builder: (context, state) {
              final list = state.list;
              final isReady =
                  state.status == ShoppingListStatus.loaded && list != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShoppingHeader(
                    title: list?.name ?? '',
                    subtitle: list == null
                        ? null
                        : formatShoppingDate(list.date, appTexts.localeName),
                  ),
                  if (isReady)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _MembersRow(
                        list: list,
                        currentUserId: _controller.currentUserId,
                        onOpen: _openMembers,
                        onInvite: _invite,
                      ),
                    ),
                  Expanded(
                    child: !isReady
                        ? _StatusView(status: state.status)
                        : Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      ingredientFieldTop,
                                      20,
                                      4,
                                    ),
                                    child: IngredientAddField(
                                      controller: _queryController,
                                      focusNode: _queryFocus,
                                      submitLabel:
                                          appTexts.shoppingListAddToList,
                                      onChanged: _controller.onQueryChanged,
                                      onSubmit: _submitQuery,
                                    ),
                                  ),
                                  Expanded(
                                    child: _ShoppingContent(
                                      state: state,
                                      bottomPadding: bottomInset,
                                      onEdit: _openEditSheet,
                                      onBuy: _controller.buy,
                                      onPickUsual: _pickUsual,
                                    ),
                                  ),
                                ],
                              ),
                              if (_queryFocus.hasFocus)
                                Positioned(
                                  left: 20,
                                  right: 20,
                                  top:
                                      ingredientFieldTop +
                                      ingredientFieldHeight +
                                      4,
                                  child: TextFieldTapRegion(
                                    child: IngredientSuggestionsDropdown(
                                      query: state.query,
                                      suggestions: state.suggestions,
                                      queryHasAmount: state.queryHasAmount,
                                      usuals: state.usuals,
                                      showUsuals: state.items.isNotEmpty,
                                      alreadyAddedLabel:
                                          appTexts.shoppingListAlreadyIn,
                                      onPickSuggestion: _pickSuggestion,
                                      onPickUsual: _pickUsual,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({required this.status});

  final ShoppingListStatus status;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final message = switch (status) {
      ShoppingListStatus.error => appTexts.shoppingListLoadError,
      ShoppingListStatus.deleted => appTexts.shoppingListDeleted,
      ShoppingListStatus.removed => appTexts.shoppingListRemoved,
      _ => null,
    };
    if (message == null) return const Center(child: CustomProgress());
    return Center(child: Text(message, style: shoppingMutedStyle(13)));
  }
}

/// The members of the list, at the very top: their avatars (tap to see
/// and manage them) and the "+ Inviter" chip.
class _MembersRow extends StatelessWidget {
  const _MembersRow({
    required this.list,
    required this.currentUserId,
    required this.onOpen,
    required this.onInvite,
  });

  static const _maxAvatars = 4;

  final ShoppingList list;
  final EntityId currentUserId;
  final VoidCallback onOpen;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    // The current user first.
    final members = [
      ...list.memberIds.where((uid) => uid == currentUserId),
      ...list.memberIds.where((uid) => uid != currentUserId),
    ];

    return Row(
      children: [
        Flexible(
          child: Semantics(
            button: true,
            label: appTexts.shoppingListMembers,
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(100),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: ShoppingAvatarStack(
                        names: members
                            .take(_maxAvatars)
                            .map(list.nameOf)
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        members.length == 1
                            ? appTexts.shoppingListYou
                            : appTexts.shoppingListMemberCount(members.length),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: shoppingMutedStyle(12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: recipeLoaderMintColor,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            onTap: onInvite,
            borderRadius: BorderRadius.circular(100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                '+ ${appTexts.shoppingListInvite}',
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: recipeLoaderGreenColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShoppingContent extends StatelessWidget {
  const _ShoppingContent({
    required this.state,
    required this.bottomPadding,
    required this.onEdit,
    required this.onBuy,
    required this.onPickUsual,
  });

  final ShoppingListState state;
  final double bottomPadding;
  final ValueChanged<ShoppingItem> onEdit;
  final Future<void> Function(ShoppingItem item) onBuy;
  final ValueChanged<FridgeItem> onPickUsual;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    if (state.items.isEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 44, 16, bottomPadding),
        child: EmptyStateView(
          iconSize: 60,
          icon: const ListGlyph(),
          title: appTexts.shoppingListEmptyTitle,
          subtitle: appTexts.shoppingListEmptySubtitle,
          child: UsualChips(
            usuals: state.usuals,
            onPick: onPickUsual,
            alignment: WrapAlignment.center,
          ),
        ),
      );
    }

    final sections = state.sections;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 6, 20, bottomPadding),
      children: [
        for (final section in sections) ...[
          _AisleTitle(section: section),
          for (final item in section.items)
            IngredientRow(
              key: ValueKey(item.id?.value ?? item.ingredient.nameKey),
              item: item.ingredient,
              flashToken: item.id?.value == state.highlightedId
                  ? state.highlightToken
                  : null,
              onTap: () => onEdit(item),
              leading: _BuyCheck(
                label: appTexts.shoppingListMarkBought(
                  item.ingredient.displayName(appTexts.localeName),
                ),
                onBuy: () => onBuy(item),
              ),
            ),
        ],
      ],
    );
  }
}

class _AisleTitle extends StatelessWidget {
  const _AisleTitle({required this.section});

  final AisleSection section;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final name =
        section.category?.displayName(appTexts.localeName) ??
        appTexts.shoppingListOtherAisle;

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 2),
      child: Semantics(
        header: true,
        child: Text(
          name.toUpperCase(),
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            letterSpacing: 0.8,
            color: recipeLoaderInkColor.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

/// Round checkbox in front of an item: ticks, then the item leaves the list
/// for the fridge.
class _BuyCheck extends StatefulWidget {
  const _BuyCheck({required this.label, required this.onBuy});

  final String label;
  final Future<void> Function() onBuy;

  @override
  State<_BuyCheck> createState() => _BuyCheckState();
}

class _BuyCheckState extends State<_BuyCheck> {
  bool _checked = false;

  Future<void> _onTap() async {
    if (_checked) return;
    setState(() => _checked = true);
    await widget.onBuy();
    // Bought, the row is gone; still here, the purchase failed: untick.
    if (mounted) setState(() => _checked = false);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: _checked,
      label: widget.label,
      child: InkResponse(
        onTap: _onTap,
        radius: 20,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: _checked ? recipeLoaderGreenColor : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: _checked
                  ? recipeLoaderGreenColor
                  : onboardingCheckBorderColor,
              width: 1.6,
            ),
          ),
          child: _checked
              ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
