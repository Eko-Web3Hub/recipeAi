import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/fridge/presentation/fridge_labels.dart';
import 'package:recipe_ai/receipe/presentation/widget/primary_action_button.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

const _removeColor = Color(0xFFB5533A);

sealed class FridgeSheetResult {
  const FridgeSheetResult();
}

class FridgeSheetSaved extends FridgeSheetResult {
  const FridgeSheetSaved(this.item);

  final FridgeItem item;
}

class FridgeSheetRemoved extends FridgeSheetResult {
  const FridgeSheetRemoved();
}

/// Opens the light quantity sheet of [item]. [isEdit] shows "Remove" and
/// saves in place, [mergesIntoExisting] tells the user the quantity will be
/// added to the line already in the fridge.
Future<FridgeSheetResult?> showFridgeQuantitySheet(
  BuildContext context, {
  required FridgeItem item,
  required List<FridgeUnit> units,
  bool isEdit = false,
  bool mergesIntoExisting = false,
}) => showModalBottomSheet<FridgeSheetResult>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: Colors.white,
  barrierColor: const Color(0x6B141C12),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
  ),
  builder: (context) => FridgeQuantitySheet(
    item: item,
    units: units,
    isEdit: isEdit,
    mergesIntoExisting: mergesIntoExisting,
  ),
);

class FridgeQuantitySheet extends StatefulWidget {
  const FridgeQuantitySheet({
    super.key,
    required this.item,
    required this.units,
    required this.isEdit,
    required this.mergesIntoExisting,
  });

  final FridgeItem item;
  final List<FridgeUnit> units;
  final bool isEdit;
  final bool mergesIntoExisting;

  @override
  State<FridgeQuantitySheet> createState() => _FridgeQuantitySheetState();
}

class _FridgeQuantitySheetState extends State<FridgeQuantitySheet> {
  late double? _amount = widget.item.amount;
  late FridgeUnit _unit = widget.item.unit;
  late double _lastAmount =
      widget.item.amount ?? widget.item.unit.defaultAmount;
  bool _showAllUnits = false;
  String _conversionNote = '';
  final _amountController = TextEditingController();
  final _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _syncAmountText();
    _amountFocus.addListener(() {
      if (!_amountFocus.hasFocus) _commitTypedAmount();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _syncAmountText() {
    if (_amount == null) return;
    _amountController.text = di<TranslationController>().currentLanguage
        .fridgeAmount(_amount!);
  }

  void _setAmount(double? amount, {FridgeUnit? unit, String note = ''}) {
    setState(() {
      _amount = amount;
      if (unit != null) _unit = unit;
      if (amount != null) _lastAmount = amount;
      _conversionNote = note;
    });
    _syncAmountText();
  }

  void _onAmountTyped(String text) {
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value != null && value > 0) {
      setState(() {
        _amount = roundAmount(value);
        _lastAmount = _amount!;
        _conversionNote = '';
      });
    }
  }

  void _commitTypedAmount() {
    if (_amount == null) return;
    final value = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      _setAmount(_unit.min);
    } else {
      _syncAmountText();
    }
  }

  void _increase() {
    if (_amount == null) {
      _setAmount(_lastAmount);
      return;
    }
    _setAmount(
      roundAmount(_amount! + stepFor(_unit, _amount!, increase: true)),
    );
  }

  void _decrease() {
    _setAmount(
      math.max(
        _unit.min,
        roundAmount(_amount! - stepFor(_unit, _amount!, increase: false)),
      ),
    );
  }

  void _toggleAsNeeded() {
    if (_amount == null) {
      _setAmount(_lastAmount);
    } else {
      _lastAmount = _amount!;
      _setAmount(null);
    }
  }

  void _selectUnit(FridgeUnit unit) {
    if (_amount == null) {
      _setAmount(unit.defaultAmount, unit: unit);
      return;
    }
    if (unit == _unit) return;

    final converted = convertAmount(_amount, _unit, unit);
    if (converted == null) {
      _setAmount(unit.defaultAmount, unit: unit);
      return;
    }
    final appTexts = di<TranslationController>().currentLanguage;
    final rounded = roundAmount(converted);
    _setAmount(
      rounded,
      unit: unit,
      note: appTexts.fridgeConverted(
        appTexts.fridgeQuantityLabel(_amount, _unit),
        appTexts.fridgeQuantityLabel(rounded, unit),
      ),
    );
  }

  void _save() {
    _commitTypedAmount();
    Navigator.of(context).pop(
      FridgeSheetSaved(
        widget.item.copyWith(amount: () => _amount, unit: _unit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final lang = appTexts.localeName;
    final units = _showAllUnits
        ? [
            ...widget.units,
            ...FridgeUnit.values.where((u) => !widget.units.contains(u)),
          ]
        : widget.units;
    final saveLabel = widget.isEdit
        ? appTexts.fridgeSave
        : widget.mergesIntoExisting
        ? appTexts.fridgeAddToExisting
        : appTexts.fridgeAddToFridge;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom:
            22 +
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: recipeLoaderInkColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.displayName(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: robotoSlabFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: recipeLoaderInkColor,
                  ),
                ),
              ),
              if (widget.isEdit)
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(const FridgeSheetRemoved()),
                  style: TextButton.styleFrom(
                    foregroundColor: _removeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                    appTexts.fridgeRemove,
                    style: const TextStyle(
                      fontFamily: robotoFontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              _RoundIconButton(
                size: 32,
                background: recipeLoaderInkColor.withValues(alpha: 0.06),
                semanticLabel: appTexts.fridgeClose,
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: recipeLoaderInkColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundIconButton(
                size: 44,
                background: recipeLoaderCreamColor,
                semanticLabel: appTexts.fridgeDecrease,
                onTap: _amount == null || _amount! <= _unit.min + 1e-9
                    ? null
                    : _decrease,
                child: const Icon(
                  Icons.remove_rounded,
                  color: recipeLoaderInkColor,
                ),
              ),
              SizedBox(
                width: 160,
                child: _amount == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Text(
                          appTexts.fridgeAsNeeded,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: robotoFontFamily,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: recipeLoaderInkColor.withValues(alpha: 0.55),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          IntrinsicWidth(
                            child: Semantics(
                              label: appTexts.fridgeQuantity,
                              child: TextField(
                                controller: _amountController,
                                focusNode: _amountFocus,
                                onChanged: _onAmountTyped,
                                onSubmitted: (_) => _commitTypedAmount(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.,]'),
                                  ),
                                ],
                                textAlign: TextAlign.right,
                                cursorColor: recipeLoaderGreenColor,
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontFamily: robotoSlabFontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 34,
                                  color: recipeLoaderInkColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            appTexts.fridgeUnitWord(_unit, _amount!),
                            style: TextStyle(
                              fontFamily: robotoFontFamily,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: recipeLoaderInkColor.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              _RoundIconButton(
                size: 44,
                background: recipeLoaderGreenColor,
                semanticLabel: appTexts.fridgeIncrease,
                onTap: _increase,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 18,
            child: Text(
              _conversionNote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: robotoFontFamily,
                fontSize: 11.5,
                color: Color(0xFF3D8A1F),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final unit in units)
                _UnitChip(
                  label: appTexts.fridgeUnitWord(unit),
                  selected: _amount != null && unit == _unit,
                  onTap: () => _selectUnit(unit),
                ),
              _UnitChip(
                label: appTexts.fridgeAsNeeded,
                selected: _amount == null,
                selectedColor: recipeLoaderInkColor,
                ghost: _amount != null,
                onTap: _toggleAsNeeded,
              ),
              if (!_showAllUnits)
                _UnitChip(
                  label: appTexts.fridgeMoreUnits,
                  selected: false,
                  ghost: true,
                  onTap: () => setState(() => _showAllUnits = true),
                ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryActionButton(
            label: saveLabel,
            badge: appTexts.fridgeQuantityLabel(_amount, _unit),
            onTap: _save,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.size,
    required this.background,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final double size;
  final Color background;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = recipeLoaderGreenColor,
    this.ghost = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? selectedColor
        : ghost
        ? Colors.transparent
        : onboardingOptionBorderColor;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor
                : ghost
                ? Colors.transparent
                : Colors.white,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: selected
                  ? Colors.white
                  : ghost
                  ? recipeLoaderInkColor.withValues(alpha: 0.6)
                  : recipeLoaderInkColor,
              decoration: ghost && !selected ? TextDecoration.underline : null,
              decorationColor: recipeLoaderInkColor.withValues(alpha: 0.25),
            ),
          ),
        ),
      ),
    );
  }
}
