/// Number of portions the generated quantities are written for.
///
/// The generation backend does not say how many people a recipe feeds: the
/// quantities are taken as written for the portions the recipe screen opens
/// with.
const recipeBasePortions = 2;

const _vulgarFractions = {
  '½': 1 / 2,
  '¼': 1 / 4,
  '¾': 3 / 4,
  '⅓': 1 / 3,
  '⅔': 2 / 3,
  '⅛': 1 / 8,
};

const _fraction = '[½¼¾⅓⅔⅛]';

/// "1 1/2", "1½", "1/2", "1,5", "300", "½" — longest forms first.
const _amount =
    r'\d+\s+\d+/\d+|\d+\s*' +
    _fraction +
    r'|\d+/\d+|\d+(?:[.,]\d+)?|' +
    _fraction;

/// The first amount of the quantity, and the upper bound of a range
/// ("2-3", "2 à 3", "2 to 3", "2 ou 3").
final _amountPattern = RegExp(
  '($_amount)(?:(\\s*(?:-|–|à|to|or|ou)\\s*)($_amount))?',
);

/// Rewrites the amount of a free-text [quantity] ("300g", "2 cloves",
/// "1,5 L", "2-3 gousses") for [factor] times as many portions.
///
/// Only the first amount (and its range partner) is scaled, the unit and the
/// rest of the text are kept as they are. A quantity without any amount ("a
/// handful", "to taste", "une pincée") cannot be scaled and is returned
/// unchanged, as is every quantity when [factor] is 1.
///
/// Amounts of 10 and more are rounded to the unit, smaller ones to one
/// decimal written with [decimalSeparator] — unless the quantity already used
/// a comma.
String scaleQuantity(
  String quantity,
  double factor, {
  String decimalSeparator = '.',
}) {
  if (factor == 1) return quantity;

  final match = _amountPattern.firstMatch(quantity);
  if (match == null) return quantity;

  final separator = match.group(0)!.contains(',') ? ',' : decimalSeparator;
  String scaled(String amount) => _format(_parse(amount) * factor, separator);

  final upperBound = match.group(3);
  final replacement = upperBound == null
      ? scaled(match.group(1)!)
      : '${scaled(match.group(1)!)}${match.group(2)}${scaled(upperBound)}';

  return quantity.replaceRange(match.start, match.end, replacement);
}

double _parse(String amount) {
  final text = amount.trim();

  final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(text);
  if (mixed != null) {
    return int.parse(mixed.group(1)!) +
        int.parse(mixed.group(2)!) / int.parse(mixed.group(3)!);
  }

  final withVulgar = RegExp('^(\\d*)\\s*($_fraction)\$').firstMatch(text);
  if (withVulgar != null) {
    final whole = withVulgar.group(1)!;
    return (whole.isEmpty ? 0 : int.parse(whole)) +
        _vulgarFractions[withVulgar.group(2)]!;
  }

  final fraction = RegExp(r'^(\d+)/(\d+)$').firstMatch(text);
  if (fraction != null) {
    return int.parse(fraction.group(1)!) / int.parse(fraction.group(2)!);
  }

  return double.parse(text.replaceAll(',', '.'));
}

String _format(double value, String decimalSeparator) {
  if (value >= 10) return value.round().toString();

  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    // Never scale an amount down to nothing.
    return rounded == 0 ? '0${decimalSeparator}1' : rounded.toInt().toString();
  }
  return rounded.toStringAsFixed(1).replaceAll('.', decimalSeparator);
}
