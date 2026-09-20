enum FridgeUnitDimension { mass, volume, other }

/// Units offered in the fridge quantity sheet (see the "Mon frigo" mockup).
///
/// [key] is what is stored in Firestore, [backendLabel] is the language
/// neutral label written in the legacy `quantity` field read by the backend.
enum FridgeUnit {
  piece('piece', '', step: 1, min: 1, defaultAmount: 1),
  g(
    'g',
    'g',
    step: 50,
    min: 25,
    defaultAmount: 250,
    dimension: FridgeUnitDimension.mass,
    factor: 1,
  ),
  kg(
    'kg',
    'kg',
    step: 0.25,
    min: 0.1,
    defaultAmount: 1,
    dimension: FridgeUnitDimension.mass,
    factor: 1000,
  ),
  ml(
    'ml',
    'ml',
    step: 50,
    min: 50,
    defaultAmount: 250,
    dimension: FridgeUnitDimension.volume,
    factor: 1,
  ),
  l(
    'l',
    'L',
    step: 0.25,
    min: 0.1,
    defaultAmount: 1,
    dimension: FridgeUnitDimension.volume,
    factor: 1000,
  ),
  bol('bol', 'bowl', step: 1, min: 1, defaultAmount: 1),
  tas('tas', 'heap', step: 1, min: 1, defaultAmount: 1),
  botte('botte', 'bunch', step: 1, min: 1, defaultAmount: 1),
  sachet('sachet', 'bag', step: 1, min: 1, defaultAmount: 1),
  boite('boite', 'can', step: 1, min: 1, defaultAmount: 1),
  cas('cas', 'tbsp', step: 1, min: 1, defaultAmount: 1);

  const FridgeUnit(
    this.key,
    this.backendLabel, {
    required this.step,
    required this.min,
    required this.defaultAmount,
    this.dimension = FridgeUnitDimension.other,
    this.factor,
  });

  final String key;
  final String backendLabel;
  final double step;
  final double min;
  final double defaultAmount;
  final FridgeUnitDimension dimension;

  /// Factor to the base unit of [dimension] (g or ml), null when the unit
  /// cannot be converted.
  final double? factor;

  bool get isMeasure =>
      dimension == FridgeUnitDimension.mass ||
      dimension == FridgeUnitDimension.volume;

  static FridgeUnit? fromKey(String? key) {
    if (key == null) return null;
    for (final unit in FridgeUnit.values) {
      if (unit.key == key) return unit;
    }
    return null;
  }

  /// The 3 or 4 units offered first in the sheet for an ingredient whose
  /// default unit is [unit].
  static List<FridgeUnit> related(FridgeUnit unit) => switch (unit) {
    kg => const [kg, g, tas, piece],
    g => const [g, kg, piece],
    l => const [l, ml, bol],
    ml => const [ml, l, cas],
    piece => const [piece, tas, kg],
    tas => const [tas, bol, kg],
    bol => const [bol, tas, kg],
    botte => const [botte, g],
    sachet => const [sachet, g, kg],
    boite => const [boite, g],
    cas => const [cas, g, ml],
  };
}
