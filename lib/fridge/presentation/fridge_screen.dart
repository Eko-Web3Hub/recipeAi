import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/fridge/presentation/fridge_controller.dart';
import 'package:recipe_ai/fridge/presentation/fridge_labels.dart';
import 'package:recipe_ai/fridge/presentation/fridge_quantity_sheet.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/receipe/presentation/widget/primary_action_button.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/widgets/empty_state_view.dart';

const _fieldTop = 16.0;
const _fieldHeight = 46.0;
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

  void _pickSuggestion(FridgeSuggestion suggestion) {
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
          _inkSnackBar(
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
          _inkSnackBar(switch (outcome) {
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

  SnackBar _inkSnackBar(
    String message, {
    Duration duration = const Duration(milliseconds: 2200),
    SnackBarAction? action,
  }) => SnackBar(
    content: Text(
      message,
      style: const TextStyle(
        fontFamily: robotoFontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: Colors.white,
      ),
    ),
    backgroundColor: recipeLoaderInkColor,
    behavior: SnackBarBehavior.floating,
    duration: duration,
    // Flutter keeps a snack bar with an action on screen until it is tapped
    // (`persist` defaults to `action != null`): "Undo" must leave on its own.
    persist: false,
    action: action,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

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
      child: ColoredBox(
        color: Colors.white,
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
                      style: const TextStyle(
                        fontFamily: robotoSlabFontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: recipeLoaderInkColor,
                      ),
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
                                _fieldTop,
                                20,
                                4,
                              ),
                              child: _AddField(
                                controller: _queryController,
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
                                onEdit: (item) =>
                                    _openSheet(item, isEdit: true),
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
                            top: _fieldTop + _fieldHeight + 4,
                            child: TextFieldTapRegion(
                              child: _SuggestionsDropdown(
                                state: state,
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

class _AddField extends StatelessWidget {
  const _AddField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: _fieldHeight,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmit(),
                  onTapOutside: (_) => focusNode.unfocus(),
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: recipeLoaderGreenColor,
                  style: const TextStyle(
                    fontFamily: robotoFontFamily,
                    fontSize: 14,
                    color: recipeLoaderInkColor,
                  ),
                  decoration: InputDecoration(
                    hintText: appTexts.fridgeAddHint,
                    hintStyle: TextStyle(
                      fontFamily: robotoFontFamily,
                      fontSize: 14,
                      color: recipeLoaderInkColor.withValues(alpha: 0.4),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    suffixIcon: hasText
                        ? IconButton(
                            tooltip: appTexts.fridgeClear,
                            onPressed: () {
                              controller.clear();
                              onChanged('');
                            },
                            icon: Icon(
                              Icons.cancel_rounded,
                              size: 20,
                              color: recipeLoaderInkColor.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: recipeLoaderInkColor.withValues(alpha: 0.18),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: recipeLoaderGreenColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Opacity(
              opacity: hasText ? 1 : 0.4,
              child: Material(
                color: recipeLoaderGreenColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: hasText ? onSubmit : null,
                  child: SizedBox(
                    width: _fieldHeight,
                    height: _fieldHeight,
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      semanticLabel: appTexts.fridgeAddToFridge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestionsDropdown extends StatelessWidget {
  const _SuggestionsDropdown({
    required this.state,
    required this.onPickSuggestion,
    required this.onPickUsual,
  });

  final FridgeState state;
  final ValueChanged<FridgeSuggestion> onPickSuggestion;
  final ValueChanged<FridgeItem> onPickUsual;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final lang = appTexts.localeName;
    final List<Widget> children;

    if (state.query.trim().isEmpty) {
      // Usuals are offered in the dropdown only when the list is not empty:
      // the empty state already shows them.
      if (state.items.isEmpty || state.usuals.isEmpty) {
        return const SizedBox.shrink();
      }
      children = [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Text(
            appTexts.fridgeUsuals,
            style: _mutedStyle(11.5, FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
          child: _UsualChips(usuals: state.usuals, onPick: onPickUsual),
        ),
      ];
    } else {
      if (state.suggestions.isEmpty) return const SizedBox.shrink();
      final first = state.suggestions.first.draft;
      children = [
        for (final suggestion in state.suggestions)
          _SuggestionTile(
            suggestion: suggestion,
            query: parseExpress(state.query).name,
            onTap: () => onPickSuggestion(suggestion),
          ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: recipeLoaderInkColor.withValues(alpha: 0.07),
              ),
            ),
          ),
          child: Text(
            state.queryHasAmount
                ? appTexts.fridgeExpressHint(
                    '${first.displayName(lang)} · '
                    '${appTexts.fridgeQuantityLabel(first.amount, first.unit)}',
                  )
                : appTexts.fridgePickHint,
            style: _mutedStyle(11.5, FontWeight.w400),
          ),
        ),
      ];
    }

    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: recipeLoaderInkColor.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.query,
    required this.onTap,
  });

  final FridgeSuggestion suggestion;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final name = suggestion.draft.displayName(appTexts.localeName);
    const style = TextStyle(
      fontFamily: robotoFontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: recipeLoaderInkColor,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: suggestion.isCustom
                  ? Text(
                      appTexts.fridgeAddCustom(name),
                      style: style,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text.rich(
                      _highlight(name, query, style),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            if (suggestion.isInFridge) ...[
              const SizedBox(width: 8),
              Text(
                appTexts.fridgeAlreadyIn,
                style: _mutedStyle(11, FontWeight.w400),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: recipeLoaderInkColor.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  /// Bolds the part of [name] matching [query], ignoring case and accents.
  static TextSpan _highlight(String name, String query, TextStyle style) {
    final key = normalizeKey(query);
    if (key.isEmpty) return TextSpan(text: name, style: style);
    // normalizeKey keeps the length of each letter except œ / æ, rare enough
    // to fall back on a plain label.
    final plain = name.toLowerCase();
    var start = -1;
    for (var i = 0; i + key.length <= plain.length; i++) {
      if (normalizeKey(plain.substring(i, i + key.length)) == key) {
        start = i;
        break;
      }
    }
    if (start < 0) return TextSpan(text: name, style: style);
    final end = start + key.length;
    return TextSpan(
      style: style,
      children: [
        TextSpan(text: name.substring(0, start)),
        TextSpan(
          text: name.substring(start, end),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(text: name.substring(end)),
      ],
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
            style: _mutedStyle(13, FontWeight.w400),
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
          icon: const _ListGlyph(),
          title: appTexts.fridgeEmptyTitle,
          subtitle: appTexts.fridgeEmptySubtitle,
          child: _UsualChips(
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
        return _FridgeRow(
          key: ValueKey(item.id?.value ?? item.nameKey),
          item: item,
          flashToken: isHighlighted ? state.highlightToken : null,
          onTap: () => onEdit(item),
        );
      },
    );
  }
}

class _FridgeRow extends StatefulWidget {
  const _FridgeRow({
    super.key,
    required this.item,
    required this.flashToken,
    required this.onTap,
  });

  final FridgeItem item;

  /// Changes each time the row must flash (just added or edited).
  final int? flashToken;
  final VoidCallback onTap;

  @override
  State<_FridgeRow> createState() => _FridgeRowState();
}

class _FridgeRowState extends State<_FridgeRow>
    with SingleTickerProviderStateMixin {
  late final _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
    value: 1,
  );

  bool _initialFlashChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Not in initState: _startFlash reads MediaQuery.
    if (_initialFlashChecked) return;
    _initialFlashChecked = true;
    if (widget.flashToken != null) _startFlash();
  }

  @override
  void didUpdateWidget(covariant _FridgeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flashToken != null &&
        widget.flashToken != oldWidget.flashToken) {
      _startFlash();
    }
  }

  void _startFlash() {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: const Duration(milliseconds: 200),
      );
    });
    _flash.forward(from: 0);
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final item = widget.item;
    final name = item.displayName(appTexts.localeName);

    return AnimatedBuilder(
      animation: _flash,
      builder: (context, child) => ColoredBox(
        color: Color.lerp(
          recipeLoaderMintColor,
          recipeLoaderMintColor.withValues(alpha: 0),
          Curves.easeOut.transform(_flash.value),
        )!,
        child: child,
      ),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: recipeLoaderInkColor.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: recipeLoaderGreenColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: robotoFontFamily,
                      fontWeight: FontWeight.w500,
                      // Roboto ships as a variable font: the weight axis has
                      // to be set explicitly.
                      fontVariations: [FontVariation.weight(500)],
                      fontSize: 14,
                      color: recipeLoaderInkColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _QuantityPill(appTexts: appTexts, item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityPill extends StatelessWidget {
  const _QuantityPill({required this.appTexts, required this.item});

  final AppLocalizations appTexts;
  final FridgeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 5, 8, 5),
      decoration: BoxDecoration(
        color: recipeLoaderCreamColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appTexts.fridgeQuantityLabel(item.amount, item.unit),
            style: TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: item.isAsNeeded ? FontWeight.w500 : FontWeight.w600,
              fontVariations: [
                FontVariation.weight(item.isAsNeeded ? 500 : 600),
              ],
              fontSize: 12.5,
              color: item.isAsNeeded
                  ? recipeLoaderInkColor.withValues(alpha: 0.5)
                  : recipeLoaderInkColor,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: recipeLoaderInkColor.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

class _UsualChips extends StatelessWidget {
  const _UsualChips({
    required this.usuals,
    required this.onPick,
    this.alignment = WrapAlignment.start,
  });

  final List<FridgeItem> usuals;
  final ValueChanged<FridgeItem> onPick;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final lang = di<TranslationController>().currentLanguage.localeName;

    return Wrap(
      alignment: alignment,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final usual in usuals)
          Material(
            color: recipeLoaderCreamColor,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => onPick(usual),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: '+ ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: recipeLoaderGreenColor,
                        ),
                      ),
                      TextSpan(text: usual.displayName(lang)),
                    ],
                  ),
                  style: const TextStyle(
                    fontFamily: robotoFontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                    color: recipeLoaderInkColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0.66, 1],
          colors: [Colors.white, Colors.white.withValues(alpha: 0)],
        ),
      ),
      child: Padding(
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
      ),
    );
  }
}

/// Three muted bars, the list glyph of the empty state.
class _ListGlyph extends StatelessWidget {
  const _ListGlyph();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 20,
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 2),
            color: recipeLoaderInkColor.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

TextStyle _mutedStyle(double size, FontWeight weight) => TextStyle(
  fontFamily: robotoFontFamily,
  fontWeight: weight,
  fontSize: size,
  color: recipeLoaderInkColor.withValues(alpha: 0.55),
);
