import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';

/// What [FridgeStockService.addOrMerge] did to the fridge, kept to undo it.
class FridgeStockChange extends Equatable {
  const FridgeStockChange({required this.result, this.previous, this.outcome});

  /// The fridge line after the change.
  final FridgeItem result;

  /// The line before the change, null when [result] was a new line.
  final FridgeItem? previous;

  /// How the quantity was merged, null when [result] was a new line.
  final MergeOutcome? outcome;

  @override
  List<Object?> get props => [result, previous, outcome];
}

/// Puts ingredients in the fridge from outside the fridge screen (e.g. a
/// bought shopping list item), merging them into the same ingredient
/// already there.
class FridgeStockService {
  const FridgeStockService(this._fridgeRepository);

  final IFridgeRepository _fridgeRepository;

  Future<FridgeStockChange> addOrMerge(EntityId uid, FridgeItem draft) async {
    final items = await _fridgeRepository.watchItems(uid).first;
    for (final existing in items) {
      if (!existing.sameIngredientAs(draft)) continue;
      final (merged, outcome) = mergeAdd(existing, draft);
      if (outcome != MergeOutcome.alreadyIn) {
        await _fridgeRepository.update(uid, merged);
      }
      return FridgeStockChange(
        result: merged,
        previous: existing,
        outcome: outcome,
      );
    }

    final added = await _fridgeRepository.add(uid, draft);
    return FridgeStockChange(result: added);
  }

  /// Puts the fridge back as it was before [change].
  Future<void> undo(EntityId uid, FridgeStockChange change) async {
    final previous = change.previous;
    if (previous == null) {
      await _fridgeRepository.remove(uid, change.result.id!);
    } else if (change.outcome != MergeOutcome.alreadyIn) {
      await _fridgeRepository.update(uid, previous);
    }
  }
}
