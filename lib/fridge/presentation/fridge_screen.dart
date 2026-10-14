import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/ingredient_search.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/fridge/presentation/fridge_controller.dart';
import 'package:recipe_ai/fridge/presentation/fridge_labels.dart';
import 'package:recipe_ai/fridge/presentation/fridge_quantity_sheet.dart';
import 'package:recipe_ai/fridge/presentation/widgets/ingredient_widgets.dart';
import 'package:recipe_ai/receipe/presentation/widget/primary_action_button.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/styles.dart';
import 'package:recipe_ai/utils/widgets/empty_state_view.dart';

const _ctaHeight = 52.0;
const _fabOverhang = 40.0;

/// "Mon frigo" tab: the ingredients the user has at home, used to generate
/// recipes (see the "Ma liste" proposition 2 mockup, titled "Mon frigo").
class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FridgeController(
        di<IFridgeRepository>(),
        di<IIngredientCatalogRepository>(),
        di<IAuthUserService>(),
        di<IAnalyticsRepository>(),
      ),
      child: ListenableBuilder(
        listenable: di<TranslationController>(),
        builder: (context, _) => const _FridgeView(),
      ),
    );
  }
}

class _FridgeView extends StatefulWidget {
  const _FridgeView();

  @override
  State<_FridgeView> createState() => _FridgeViewState();
}

class _FridgeViewState extends State<_FridgeView> {
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

  FridgeController get _controller => context.read<FridgeController>();

  Future<void> _openSheet(FridgeItem item, {bool isEdit = false}) async {
    final controller = _controller;
    _queryFocus.unfocus();
    final result = await showFridgeQuantitySheet(
      context,
      item: item,
      units: controller.unitsFor(item),
      isEdit: isEdit,
      mergesIntoExisting: !isEdit && controller.existingFor(item) != null,
    );

    switch (result) {
      case FridgeSheetSaved(:final item):
        isEdit ? controller.save(item) : controller.add(item);
      case FridgeSheetRemoved():
        controller.remove(item);
      case null:
        break;
    }
  }

  Future<void> _submitQuery() async {
    final draft = await _controller.submitQuery();
    _queryController.clear();
    if (draft != null) {
      await _openSheet(draft);
    } else {
      _queryFocus.requestFocus();
    }
  }

  void _pickSuggestion(IngredientSuggestion suggestion) {
    _controller.clearQuery();
    _queryController.clear();
    _openSheet(suggestion.draft);
  }

  void _pickUsual(FridgeItem usual) =>
      _openSheet(_controller.draftForUsual(usual));

  void _showFeedback(FridgeFeedback feedback) {
    final appTexts = di<TranslationController>().currentLanguage;
    final lang = appTexts.localeName;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

    switch (feedback) {
      case FridgeItemRemovedFeedback(:final item):
        messenger.showSnackBar(
          inkSnackBar(
            appTexts.fridgeRemoved(item.displayName(lang)),
            duration: const Duration(milliseconds: 4500),
            action: SnackBarAction(
              label: appTexts.fridgeUndo,
              textColor: const Color(0xFF9AD97A),
              onPressed: () => _controller.undoRemove(item),
            ),
          ),
        );
      case FridgeItemMergedFeedback(:final item, :final outcome):
        final name = item.displayName(lang);
        final quantity = appTexts.fridgeQuantityLabel(item.amount, item.unit);
        messenger.showSnackBar(
          inkSnackBar(switch (outcome) {
            MergeOutcome.alreadyIn => appTexts.fridgeAlreadyInToast(name),
            MergeOutcome.quantitySet => appTexts.fridgeQuantitySet(
              name,
              quantity,
            ),
            MergeOutcome.total => appTexts.fridgeTotal(name, quantity),
            MergeOutcome.replaced => appTexts.fridgeReplaced(name),
          }),
        );
      case FridgeErrorFeedback():
        showSnackBar(context, appTexts.fridgeError, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    // Scaffold.extendBody puts the nav bar height in the bottom padding; the
    // docked chef FAB sticks out 27 px above it.
    final bottomInset = MediaQuery.paddingOf(context).bottom + _fabOverhang;

    return BlocListener<FridgeController, FridgeState>(
      listenWhen: (previous, current) =>
          current.feedback != null && previous.feedback != current.feedback,
      listener: (context, state) => _showFeedback(state.feedback!),
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<FridgeController, FridgeState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 36,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Text(
                    appTexts.homeQuickActionFridge,
                    style: appBarTitleStyle,
                  ),
                ),
                Expanded(
                  child: Stack(
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
                              submitLabel: appTexts.fridgeAddToFridge,
                              focusNode: _queryFocus,
                              onChanged: context
                                  .read<FridgeController>()
                                  .onQueryChanged,
                              onSubmit: _submitQuery,
                            ),
                          ),
                          Expanded(
                            child: _FridgeContent(
                              state: state,
                              bottomPadding: bottomInset + _ctaHeight + 36,
                              onEdit: (item) => _openSheet(item, isEdit: true),
                              onPickUsual: _pickUsual,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: bottomInset,
                        child: _GenerateButton(count: state.items.length),
                      ),
                      if (_queryFocus.hasFocus)
                        Positioned(
                          left: 20,
                          right: 20,
                          top: ingredientFieldTop + ingredientFieldHeight + 4,
                          child: TextFieldTapRegion(
                            child: IngredientSuggestionsDropdown(
                              query: state.query,
                              suggestions: state.suggestions,
                              queryHasAmount: state.queryHasAmount,
                              usuals: state.usuals,
                              showUsuals: state.items.isNotEmpty,
                              alreadyAddedLabel: appTexts.fridgeAlreadyIn,
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
    );
  }
}

class _FridgeContent extends StatelessWidget {
  const _FridgeContent({
    required this.state,
    required this.bottomPadding,
    required this.onEdit,
    required this.onPickUsual,
  });

  final FridgeState state;
  final double bottomPadding;
  final ValueChanged<FridgeItem> onEdit;
  final ValueChanged<FridgeItem> onPickUsual;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    switch (state.status) {
      case FridgeStatus.loading:
        return const Center(child: CustomProgress());
      case FridgeStatus.error:
        return Center(
          child: Text(
            appTexts.fridgeLoadError,
            style: ingredientMutedStyle(13, FontWeight.w400),
          ),
        );
      case FridgeStatus.loaded:
        break;
    }

    if (state.items.isEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 44, 16, bottomPadding),
        child: EmptyStateView(
          iconSize: 60,
          icon: const ListGlyph(),
          title: appTexts.fridgeEmptyTitle,
          subtitle: appTexts.fridgeEmptySubtitle,
          child: UsualChips(
            usuals: state.usuals,
            onPick: onPickUsual,
            alignment: WrapAlignment.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 6, 20, bottomPadding),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        final isHighlighted = item.id?.value == state.highlightedId;
        return IngredientRow(
          key: ValueKey(item.id?.value ?? item.nameKey),
          item: item,
          flashToken: isHighlighted ? state.highlightToken : null,
          onTap: () => onEdit(item),
        );
      },
    );
  }
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: PrimaryActionButton(
        label: appTexts.fridgeGenerate,
        badge: count > 0 ? appTexts.fridgeIngredientCount(count) : null,
        onTap: count == 0
            ? null
            : () => context.push(
                '/display-receipes-based-on-ingredient-user-preference',
              ),
      ),
    );
  }
}
