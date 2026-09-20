import 'package:recipe_ai/fridge/domain/model/catalog_ingredient.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';

// Pure helpers of the "Mon frigo" tab: name normalization, the express entry
// parser ("500 g tomates"), unit conversion and the merge of a new entry into
// an ingredient already in the fridge.

const _accents = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', //
  'ç': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ÿ': 'y',
  'œ': 'oe', 'æ': 'ae', '’': "'",
};

/// Lowercase, accent-free, whitespace-collapsed form of [value], where
/// words longer than 3 letters lose a trailing "s" or "x", so "Tomates" and
/// "tomate" share the same key.
String normalizeKey(String value) {
  final buffer = StringBuffer();
  for (final char in value.toLowerCase().split('')) {
    buffer.write(_accents[char] ?? char);
  }
  return buffer
      .toString()
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            word.length > 3 ? word.replaceFirst(RegExp(r'[sx]$'), '') : word,
      )
      .join(' ');
}

double roundAmount(double value) => (value * 100).round() / 100;

/// "1.5" / "1,5" (French), without trailing zeros.
String formatAmount(double value, {String decimalSeparator = '.'}) {
  final rounded = roundAmount(value);
  final text = rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
  return text.replaceAll('.', decimalSeparator);
}

/// Language neutral label written in the legacy `quantity` field, read by the
/// recipe generation backend.
String backendQuantityLabel(double? amount, FridgeUnit unit) {
  if (amount == null) return 'as needed';
  if (unit == FridgeUnit.piece) return formatAmount(amount);
  return '${formatAmount(amount)} ${unit.backendLabel}';
}

double? convertAmount(double? amount, FridgeUnit from, FridgeUnit to) {
  if (amount == null) return null;
  if (from == to) return amount;
  if (from.dimension != to.dimension || !from.isMeasure) return null;
  return amount * from.factor! / to.factor!;
}

/// Step of the − / + buttons: finer under 100 g or 1 kg / 1 L.
double stepFor(FridgeUnit unit, double value, {required bool increase}) {
  switch (unit) {
    case FridgeUnit.g:
      return (increase ? value < 100 : value <= 100) ? 25 : 50;
    case FridgeUnit.kg:
    case FridgeUnit.l:
      return (increase ? value < 1 : value <= 1) ? 0.1 : 0.25;
    default:
      return unit.step;
  }
}

class ParsedEntry {
  const ParsedEntry({required this.name, this.amount, this.unit});

  final String name;
  final double? amount;
  final FridgeUnit? unit;

  bool get hasAmount => amount != null;
}

const _number = r'(\d+\/\d+|\d+(?:[.,]\d+)?)';
const _unit =
    r'(kilogrammes?|kilogram(?:me)?s?|kilos?|kg|grammes?|grams?|gr|g|'
    r'millilitres?|milliliters?|ml|cl|litres?|liters?|l|bols?|bowls?|'
    r'bottes?|bunch(?:es)?|tas|heaps?|sachets?|bags?|bo[iî]tes?|cans?|'
    r'c\.?\s?[aà]\.?\s?s\.?|cuill[eè]res?|tbsp|pi[eè]ces?|pieces?|pcs?)';
final _quantityFirst = RegExp(
  '^$_number\\s*(?:$_unit(?=\\s|\$))?\\s*(?:de\\s+|d[\'’]\\s*|of\\s+)?(.+)\$',
  caseSensitive: false,
);
final _quantityLast = RegExp(
  '^(.+?)\\s+(?:x\\s*)?$_number\\s*(?:$_unit)?\$',
  caseSensitive: false,
);
final _quantityOnly = RegExp(
  '^$_number\\s*(?:$_unit)?\$',
  caseSensitive: false,
);
final _hasLetter = RegExp(r'[a-zà-ÿœ]', caseSensitive: false);

double? _parseNumber(String raw) {
  if (raw.contains('/')) {
    final parts = raw.split('/');
    final denominator = double.tryParse(parts[1]) ?? 0;
    if (denominator == 0) return null;
    return (double.tryParse(parts[0]) ?? 0) / denominator;
  }
  return double.tryParse(raw.replaceAll(',', '.'));
}

/// Maps a typed unit to a [FridgeUnit] and the factor to apply to the amount
/// (only "cl", stored as ml).
(FridgeUnit, double)? _parseUnit(String? raw) {
  if (raw == null) return null;
  final unit = normalizeKey(raw).replaceAll(RegExp(r'[\s.]'), '');
  if (RegExp(r'^(kg|kilo|kilogram|kilogramme)$').hasMatch(unit)) {
    return (FridgeUnit.kg, 1);
  }
  if (RegExp(r'^(g|gr|gram|gramme)$').hasMatch(unit)) return (FridgeUnit.g, 1);
  if (RegExp(r'^(ml|millilitre|milliliter)$').hasMatch(unit)) {
    return (FridgeUnit.ml, 1);
  }
  if (unit == 'cl') return (FridgeUnit.ml, 10);
  if (RegExp(r'^(l|litre|liter)$').hasMatch(unit)) return (FridgeUnit.l, 1);
  if (RegExp(r'^(bol|bowl)$').hasMatch(unit)) return (FridgeUnit.bol, 1);
  if (RegExp(r'^(ta|tas|heap)$').hasMatch(unit)) return (FridgeUnit.tas, 1);
  if (RegExp(r'^(botte|bunch|bunche)$').hasMatch(unit)) {
    return (FridgeUnit.botte, 1);
  }
  if (RegExp(r'^(sachet|bag)$').hasMatch(unit)) return (FridgeUnit.sachet, 1);
  if (RegExp(r'^(boite|can)$').hasMatch(unit)) return (FridgeUnit.boite, 1);
  if (RegExp(r'^(cas|cuillere|tbsp)$').hasMatch(unit)) {
    return (FridgeUnit.cas, 1);
  }
  if (RegExp(r'^(piece|pc|pcs)$').hasMatch(unit)) return (FridgeUnit.piece, 1);
  return null;
}

ParsedEntry _entry(String name, String rawAmount, String? rawUnit) {
  final amount = _parseNumber(rawAmount);
  final unit = _parseUnit(rawUnit);
  return ParsedEntry(
    name: name.trim(),
    amount: amount == null ? null : roundAmount(amount * (unit?.$2 ?? 1)),
    unit: unit?.$1,
  );
}

/// Parses an express entry such as "500 g tomates", "tomates 2" or
/// "½ kg de riz". Without a quantity, the whole text is the name.
ParsedEntry parseExpress(String raw) {
  final text = raw
      .replaceAll('½', '1/2')
      .replaceAll('¼', '1/4')
      .replaceAll('¾', '3/4')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final first = _quantityFirst.firstMatch(text);
  if (first != null && _hasLetter.hasMatch(first.group(3)!)) {
    return _entry(first.group(3)!, first.group(1)!, first.group(2));
  }
  final last = _quantityLast.firstMatch(text);
  if (last != null && _hasLetter.hasMatch(last.group(1)!)) {
    return _entry(last.group(1)!, last.group(2)!, last.group(3));
  }
  return ParsedEntry(name: text);
}

/// Reads the legacy free-text `quantity` field ("2", "500 g", "3pcs").
/// Anything unreadable falls back on 1 piece.
(double?, FridgeUnit) parseLegacyQuantity(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return (1, FridgeUnit.piece);
  if (text == 'as needed' || text == 'au besoin') {
    return (null, FridgeUnit.piece);
  }
  final match = _quantityOnly.firstMatch(text);
  if (match == null) return (1, FridgeUnit.piece);
  final entry = _entry('', match.group(1)!, match.group(2));
  if (entry.amount == null || entry.amount! <= 0) return (1, FridgeUnit.piece);
  return (entry.amount, entry.unit ?? FridgeUnit.piece);
}

/// Builds the draft added for [parsed], using the catalog [match] defaults
/// when the user did not type a quantity.
FridgeItem resolveDraft(ParsedEntry parsed, CatalogIngredient? match) {
  final name = match?.name ?? _capitalize(parsed.name);
  final nameFr = match?.nameFr ?? (match == null ? name : null);
  if (parsed.amount != null && parsed.amount! > 0) {
    final defaultUnit = match?.defaultUnit;
    final unit =
        parsed.unit ??
        (defaultUnit != null && !defaultUnit.isMeasure
            ? defaultUnit
            : FridgeUnit.piece);
    return FridgeItem.draft(
      name: name,
      nameFr: nameFr,
      amount: parsed.amount,
      unit: unit,
      catalogId: match?.id,
    );
  }
  if (match != null) {
    final unit = match.defaultUnit ?? FridgeUnit.piece;
    return FridgeItem.draft(
      name: name,
      nameFr: nameFr,
      amount: match.defaultAmount ?? unit.defaultAmount,
      unit: unit,
      catalogId: match.id,
    );
  }
  return FridgeItem.draft(name: name, nameFr: nameFr);
}

String _capitalize(String value) {
  final text = value.trim();
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

enum MergeOutcome {
  /// The new entry had no quantity: nothing changed.
  alreadyIn,

  /// The ingredient was "as needed": it now has the new quantity.
  quantitySet,

  /// Same or convertible unit: the quantities were added up.
  total,

  /// Units that cannot be converted: the new quantity replaced the old one.
  replaced,
}

/// Adds [incoming] to [existing], an entry for the same ingredient.
(FridgeItem, MergeOutcome) mergeAdd(FridgeItem existing, FridgeItem incoming) {
  if (incoming.amount == null) return (existing, MergeOutcome.alreadyIn);
  if (existing.amount == null) {
    return (
      existing.copyWith(amount: () => incoming.amount, unit: incoming.unit),
      MergeOutcome.quantitySet,
    );
  }
  final converted = convertAmount(
    incoming.amount,
    incoming.unit,
    existing.unit,
  );
  if (converted != null) {
    return (
      existing.copyWith(
        amount: () => roundAmount(existing.amount! + converted),
      ),
      MergeOutcome.total,
    );
  }
  return (
    existing.copyWith(amount: () => incoming.amount, unit: incoming.unit),
    MergeOutcome.replaced,
  );
}
