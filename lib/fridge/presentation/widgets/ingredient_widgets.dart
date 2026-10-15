import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/ingredient_search.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/presentation/fridge_labels.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

// Widgets shared by the fridge and the shopping list screens.

const ingredientFieldTop = 16.0;
const ingredientFieldHeight = 46.0;

/// Dark floating snack bar of the fridge and the shopping lists.
SnackBar inkSnackBar(
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

/// Search field of the fridge and the shopping lists, with its "+" button.
class IngredientAddField extends StatelessWidget {
  const IngredientAddField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmit,
    required this.submitLabel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  /// Semantic label of the "+" button.
  final String submitLabel;

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
                height: ingredientFieldHeight,
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
                    width: ingredientFieldHeight,
                    height: ingredientFieldHeight,
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      semanticLabel: submitLabel,
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

/// Dropdown under [IngredientAddField]: the catalog suggestions for the
/// query, or the usual ingredients while the query is empty.
class IngredientSuggestionsDropdown extends StatelessWidget {
  const IngredientSuggestionsDropdown({
    super.key,
    required this.query,
    required this.suggestions,
    required this.queryHasAmount,
    required this.usuals,
    required this.showUsuals,
    required this.alreadyAddedLabel,
    required this.onPickSuggestion,
    required this.onPickUsual,
  });

  final String query;
  final List<IngredientSuggestion> suggestions;
  final bool queryHasAmount;
  final List<FridgeItem> usuals;

  /// Usuals are offered in the dropdown only when the list is not empty: the
  /// empty state already shows them.
  final bool showUsuals;

  /// Shown on the suggestions already in the fridge / the list.
  final String alreadyAddedLabel;
  final ValueChanged<IngredientSuggestion> onPickSuggestion;
  final ValueChanged<FridgeItem> onPickUsual;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final lang = appTexts.localeName;
    final List<Widget> children;

    if (query.trim().isEmpty) {
      if (!showUsuals || usuals.isEmpty) {
        return const SizedBox.shrink();
      }
      children = [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Text(
            appTexts.fridgeUsuals,
            style: ingredientMutedStyle(11.5, FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
          child: UsualChips(usuals: usuals, onPick: onPickUsual),
        ),
      ];
    } else {
      if (suggestions.isEmpty) return const SizedBox.shrink();
      final first = suggestions.first.draft;
      children = [
        for (final suggestion in suggestions)
          _SuggestionTile(
            suggestion: suggestion,
            alreadyAddedLabel: alreadyAddedLabel,
            query: parseExpress(query).name,
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
            queryHasAmount
                ? appTexts.fridgeExpressHint(
                    '${first.displayName(lang)} · '
                    '${appTexts.fridgeQuantityLabel(first.amount, first.unit)}',
                  )
                : appTexts.fridgePickHint,
            style: ingredientMutedStyle(11.5, FontWeight.w400),
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
    required this.alreadyAddedLabel,
    required this.query,
    required this.onTap,
  });

  final IngredientSuggestion suggestion;
  final String alreadyAddedLabel;
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
            if (suggestion.isAlreadyAdded) ...[
              const SizedBox(width: 8),
              Text(
                alreadyAddedLabel,
                style: ingredientMutedStyle(11, FontWeight.w400),
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

/// A line of the fridge or of a shopping list: name and quantity pill.
/// Tapping it opens the quantity sheet.
class IngredientRow extends StatefulWidget {
  const IngredientRow({
    super.key,
    required this.item,
    required this.flashToken,
    required this.onTap,
    this.leading,
    this.crossedOut = false,
  });

  final FridgeItem item;

  /// Struck through and dimmed (an item already in the cart).
  final bool crossedOut;

  /// Replaces the green dot in front of the name (e.g. a checkbox).
  final Widget? leading;

  /// Changes each time the row must flash (just added or edited).
  final int? flashToken;
  final VoidCallback onTap;

  @override
  State<IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends State<IngredientRow>
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
  void didUpdateWidget(covariant IngredientRow oldWidget) {
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
                widget.leading ??
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
                    style: TextStyle(
                      fontFamily: robotoFontFamily,
                      fontWeight: FontWeight.w500,
                      // Roboto ships as a variable font: the weight axis has
                      // to be set explicitly.
                      fontVariations: const [FontVariation.weight(500)],
                      fontSize: 14,
                      color: widget.crossedOut
                          ? recipeLoaderInkColor.withValues(alpha: 0.45)
                          : recipeLoaderInkColor,
                      decoration: widget.crossedOut
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: recipeLoaderInkColor.withValues(
                        alpha: 0.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Opacity(
                  opacity: widget.crossedOut ? 0.55 : 1,
                  child: _QuantityPill(appTexts: appTexts, item: item),
                ),
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

/// "+ Lait" chips of the user's usual ingredients.
class UsualChips extends StatelessWidget {
  const UsualChips({
    super.key,
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

/// Three muted bars, the list glyph of the empty state.
class ListGlyph extends StatelessWidget {
  const ListGlyph({super.key});

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

TextStyle ingredientMutedStyle(double size, FontWeight weight) => TextStyle(
  fontFamily: robotoFontFamily,
  fontWeight: weight,
  fontSize: size,
  color: recipeLoaderInkColor.withValues(alpha: 0.55),
);
