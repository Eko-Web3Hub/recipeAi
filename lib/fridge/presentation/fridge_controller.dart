import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_ingredient.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

enum FridgeStatus { loading, loaded, error }

/// One-shot message shown by the screen (snackbar). [id] makes two identical
/// messages in a row distinct states.
sealed class FridgeFeedback extends Equatable {
  const FridgeFeedback(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class FridgeItemRemovedFeedback extends FridgeFeedback {
  const FridgeItemRemovedFeedback(super.id, this.item);

  final FridgeItem item;

  @override
  List<Object?> get props => [id, item];
}

class FridgeItemMergedFeedback extends FridgeFeedback {
  const FridgeItemMergedFeedback(super.id, this.item, this.outcome);

  final FridgeItem item;
  final MergeOutcome outcome;

  @override
  List<Object?> get props => [id, item, outcome];
}

class FridgeErrorFeedback extends FridgeFeedback {
  const FridgeErrorFeedback(super.id);
}

class FridgeSuggestion extends Equatable {
  const FridgeSuggestion({
    required this.draft,
    required this.isCustom,
    required this.isInFridge,
  });

  final FridgeItem draft;

  /// "Add « xxx »": no catalog ingredient matches the typed name.
  final bool isCustom;
  final bool isInFridge;

  @override
  List<Object?> get props => [draft, isCustom, isInFridge];
}

final class FridgeState extends Equatable {
  const FridgeState({
    this.status = FridgeStatus.loading,
    this.items = const [],
    this.usuals = const [],
    this.query = '',
    this.suggestions = const [],
    this.queryHasAmount = false,
    this.highlightedId,
    this.highlightToken = 0,
    this.feedback,
  });

  final FridgeStatus status;
  final List<FridgeItem> items;

  /// Usual ingredients to offer as chips, already filtered out of [items].
  final List<FridgeItem> usuals;
  final String query;
  final List<FridgeSuggestion> suggestions;

  /// The query holds a quantity ("500 g tomates"): Enter adds it directly.
  final bool queryHasAmount;
  final String? highlightedId;
  final int highlightToken;
  final FridgeFeedback? feedback;

  FridgeState copyWith({
    FridgeStatus? status,
    List<FridgeItem>? items,
    List<FridgeItem>? usuals,
    String? query,
    List<FridgeSuggestion>? suggestions,
    bool? queryHasAmount,
    String? highlightedId,
    int? highlightToken,
    FridgeFeedback? feedback,
  }) => FridgeState(
    status: status ?? this.status,
    items: items ?? this.items,
    usuals: usuals ?? this.usuals,
    query: query ?? this.query,
    suggestions: suggestions ?? this.suggestions,
    queryHasAmount: queryHasAmount ?? this.queryHasAmount,
    highlightedId: highlightedId ?? this.highlightedId,
    highlightToken: highlightToken ?? this.highlightToken,
    feedback: feedback ?? this.feedback,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    usuals,
    query,
    suggestions,
    queryHasAmount,
    highlightedId,
    highlightToken,
    feedback,
  ];
}

/// Offered while the user has no history of added ingredients.
final defaultFridgeUsuals = [
  FridgeItem.draft(name: 'Milk', nameFr: 'Lait', amount: 1, unit: FridgeUnit.l),
  FridgeItem.draft(
    name: 'Eggs',
    nameFr: 'Œufs',
    amount: 6,
    unit: FridgeUnit.piece,
  ),
  FridgeItem.draft(
    name: 'Chicken',
    nameFr: 'Poulet',
    amount: 1,
    unit: FridgeUnit.kg,
  ),
  FridgeItem.draft(
    name: 'Chili pepper',
    nameFr: 'Piment',
    amount: 5,
    unit: FridgeUnit.piece,
  ),
  FridgeItem.draft(
    name: 'Okra',
    nameFr: 'Gombo',
    amount: 1,
    unit: FridgeUnit.tas,
  ),
  FridgeItem.draft(
    name: 'Peanut oil',
    nameFr: "Huile d'arachide",
    amount: 1,
    unit: FridgeUnit.l,
  ),
];

class FridgeController extends Cubit<FridgeState> {
  FridgeController(
    this._fridgeRepository,
    this._catalogRepository,
    this._authUserService,
    this._analyticsRepository,
  ) : super(const FridgeState()) {
    _listen();
    _loadCatalog();
  }

  static const _maxSuggestions = 4;
  static const _maxUsuals = 5;

  final IFridgeRepository _fridgeRepository;
  final IIngredientCatalogRepository _catalogRepository;
  final IAuthUserService _authUserService;
  final IAnalyticsRepository _analyticsRepository;

  StreamSubscription<List<FridgeItem>>? _itemsSubscription;
  StreamSubscription<List<FridgeItem>>? _usualsSubscription;
  List<CatalogIngredient> _catalog = const [];
  List<FridgeItem> _usualsHistory = const [];
  int _feedbackCount = 0;

  EntityId get _uid => _authUserService.currentUser!.uid;

  void _listen() {
    _itemsSubscription = _fridgeRepository
        .watchItems(_uid)
        .listen(
          (items) {
            safeEmit(
              state.copyWith(
                status: FridgeStatus.loaded,
                items: items,
                usuals: _usualsToOffer(items),
              ),
            );
            if (state.query.isNotEmpty) onQueryChanged(state.query);
          },
          onError: (Object error) {
            log('Fridge items failed to load: $error');
            safeEmit(state.copyWith(status: FridgeStatus.error));
          },
        );

    _usualsSubscription = _fridgeRepository.watchUsuals(_uid).listen((usuals) {
      _usualsHistory = usuals;
      safeEmit(state.copyWith(usuals: _usualsToOffer(state.items)));
    }, onError: (Object error) => log('Fridge usuals failed to load: $error'));
  }

  Future<void> _loadCatalog() async {
    try {
      _catalog = await _catalogRepository.loadCatalog();
      if (state.query.isNotEmpty) onQueryChanged(state.query);
    } catch (error) {
      // Search still works with free-text entries.
      log('Ingredient catalog failed to load: $error');
    }
  }

  List<FridgeItem> _usualsToOffer(List<FridgeItem> items) =>
      (_usualsHistory.isEmpty ? defaultFridgeUsuals : _usualsHistory)
          .where((usual) => !items.any((item) => item.sameIngredientAs(usual)))
          .take(_maxUsuals)
          .toList();

  FridgeItem? existingFor(FridgeItem draft) {
    for (final item in state.items) {
      if (item.sameIngredientAs(draft)) return item;
    }
    return null;
  }

  CatalogIngredient? _catalogFor(FridgeItem item) {
    for (final ingredient in _catalog) {
      if (item.catalogId != null && ingredient.id == item.catalogId) {
        return ingredient;
      }
    }
    for (final ingredient in _catalog) {
      if (ingredient.searchKeys.any(item.matchKeys.contains)) {
        return ingredient;
      }
    }
    return null;
  }

  CatalogIngredient? _exactMatch(String key) {
    for (final ingredient in _catalog) {
      if (ingredient.searchKeys.contains(key)) return ingredient;
    }
    return null;
  }

  /// Units offered first in the quantity sheet of [item], starting with its
  /// current unit.
  List<FridgeUnit> unitsFor(FridgeItem item) {
    final units =
        _catalogFor(item)?.suggestedUnits ?? FridgeUnit.related(item.unit);
    return [item.unit, ...units.where((unit) => unit != item.unit)];
  }

  /// A usual chip turned into a draft, completed with the catalog when the
  /// ingredient is found in it.
  FridgeItem draftForUsual(FridgeItem usual) {
    final ingredient = _catalogFor(usual);
    if (ingredient == null) return usual;
    return FridgeItem.draft(
      name: ingredient.name,
      nameFr: ingredient.nameFr ?? usual.nameFr,
      amount: usual.amount,
      unit: usual.unit,
      catalogId: ingredient.id,
    );
  }

  void onQueryChanged(String query) {
    final parsed = parseExpress(query);
    final key = normalizeKey(parsed.name);
    if (key.isEmpty) {
      safeEmit(
        state.copyWith(query: query, suggestions: [], queryHasAmount: false),
      );
      return;
    }

    final exact = _exactMatch(key);
    final startsWith = <CatalogIngredient>[];
    final wordStartsWith = <CatalogIngredient>[];
    for (final ingredient in _catalog) {
      if (ingredient == exact) continue;
      final keys = ingredient.searchKeys;
      if (keys.any((name) => name.startsWith(key))) {
        startsWith.add(ingredient);
      } else if (keys.any(
        (name) => name.split(' ').any((word) => word.startsWith(key)),
      )) {
        wordStartsWith.add(ingredient);
      }
    }

    final matches = [
      if (exact != null) exact,
      ...startsWith,
      ...wordStartsWith,
    ].take(_maxSuggestions);

    final suggestions = [
      for (final ingredient in matches)
        _suggestion(resolveDraft(parsed, ingredient), isCustom: false),
      if (exact == null && parsed.name.trim().length > 1)
        _suggestion(resolveDraft(parsed, null), isCustom: true),
    ];

    safeEmit(
      state.copyWith(
        query: query,
        suggestions: suggestions,
        queryHasAmount: parsed.hasAmount,
      ),
    );
  }

  FridgeSuggestion _suggestion(FridgeItem draft, {required bool isCustom}) =>
      FridgeSuggestion(
        draft: draft,
        isCustom: isCustom,
        isInFridge: existingFor(draft) != null,
      );

  void clearQuery() => safeEmit(
    state.copyWith(query: '', suggestions: [], queryHasAmount: false),
  );

  /// Enter / "+" on the field. With a typed quantity the first suggestion is
  /// added right away and null is returned, otherwise the draft to open in
  /// the quantity sheet is returned.
  Future<FridgeItem?> submitQuery() async {
    if (state.query.trim().isEmpty) return null;
    final draft = state.suggestions.isNotEmpty
        ? state.suggestions.first.draft
        : resolveDraft(parseExpress(state.query), null);
    final addDirectly = state.queryHasAmount;
    clearQuery();
    if (!addDirectly) return draft;
    await add(draft);
    return null;
  }

  /// Adds [draft], or merges it into the same ingredient already in the
  /// fridge.
  Future<void> add(FridgeItem draft) async {
    try {
      final existing = existingFor(draft);
      if (existing != null) {
        final (merged, outcome) = mergeAdd(existing, draft);
        if (outcome != MergeOutcome.alreadyIn) {
          await _fridgeRepository.update(_uid, merged);
        }
        safeEmit(
          state.copyWith(
            highlightedId: merged.id?.value,
            highlightToken: state.highlightToken + 1,
            feedback: FridgeItemMergedFeedback(
              ++_feedbackCount,
              merged,
              outcome,
            ),
          ),
        );
        return;
      }

      final added = await _fridgeRepository.add(_uid, draft);
      _analyticsRepository.logEvent(IngredientManuallyAddedEvent());
      safeEmit(
        state.copyWith(
          highlightedId: added.id?.value,
          highlightToken: state.highlightToken + 1,
        ),
      );
    } catch (error) {
      log('Fridge add failed: $error');
      safeEmit(state.copyWith(feedback: FridgeErrorFeedback(++_feedbackCount)));
    }
  }

  Future<void> save(FridgeItem item) async {
    try {
      await _fridgeRepository.update(_uid, item);
      safeEmit(
        state.copyWith(
          highlightedId: item.id?.value,
          highlightToken: state.highlightToken + 1,
        ),
      );
    } catch (error) {
      log('Fridge save failed: $error');
      safeEmit(state.copyWith(feedback: FridgeErrorFeedback(++_feedbackCount)));
    }
  }

  Future<void> remove(FridgeItem item) async {
    if (item.id == null) return;
    try {
      await _fridgeRepository.remove(_uid, item.id!);
      safeEmit(
        state.copyWith(
          feedback: FridgeItemRemovedFeedback(++_feedbackCount, item),
        ),
      );
    } catch (error) {
      log('Fridge remove failed: $error');
      safeEmit(state.copyWith(feedback: FridgeErrorFeedback(++_feedbackCount)));
    }
  }

  Future<void> undoRemove(FridgeItem item) async {
    try {
      await _fridgeRepository.restore(_uid, item);
      safeEmit(
        state.copyWith(
          highlightedId: item.id?.value,
          highlightToken: state.highlightToken + 1,
        ),
      );
    } catch (error) {
      log('Fridge undo failed: $error');
      safeEmit(state.copyWith(feedback: FridgeErrorFeedback(++_feedbackCount)));
    }
  }

  @override
  Future<void> close() async {
    await _itemsSubscription?.cancel();
    await _usualsSubscription?.cancel();
    return super.close();
  }
}
