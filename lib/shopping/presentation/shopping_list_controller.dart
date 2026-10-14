import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/application/fridge_stock_service.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/ingredient_search.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_category.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/shopping/application/member_name.dart';
import 'package:recipe_ai/shopping/application/shopping_list_links.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/shopping/domain/shopping_aisles.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

/// [deleted]: the list no longer exists. [removed]: the user is no longer
/// one of its members.
enum ShoppingListStatus { loading, loaded, error, deleted, removed }

/// One-shot message shown by the screen (snackbar). [id] makes two identical
/// messages in a row distinct states.
sealed class ShoppingListFeedback extends Equatable {
  const ShoppingListFeedback(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class ShoppingItemRemovedFeedback extends ShoppingListFeedback {
  const ShoppingItemRemovedFeedback(super.id, this.item);

  final ShoppingItem item;

  @override
  List<Object?> get props => [id, item];
}

class ShoppingItemMergedFeedback extends ShoppingListFeedback {
  const ShoppingItemMergedFeedback(super.id, this.item, this.outcome);

  final FridgeItem item;
  final MergeOutcome outcome;

  @override
  List<Object?> get props => [id, item, outcome];
}

/// [item] was bought: it left the list and [change] put it in the fridge.
class ShoppingItemBoughtFeedback extends ShoppingListFeedback {
  const ShoppingItemBoughtFeedback(super.id, this.item, this.change);

  final ShoppingItem item;
  final FridgeStockChange change;

  @override
  List<Object?> get props => [id, item, change];
}

class ShoppingListErrorFeedback extends ShoppingListFeedback {
  const ShoppingListErrorFeedback(super.id);
}

final class ShoppingListState extends Equatable {
  const ShoppingListState({
    this.status = ShoppingListStatus.loading,
    this.list,
    this.items = const [],
    this.categories = const [],
    this.usuals = const [],
    this.query = '',
    this.suggestions = const [],
    this.queryHasAmount = false,
    this.highlightedId,
    this.highlightToken = 0,
    this.feedback,
  });

  final ShoppingListStatus status;
  final ShoppingList? list;
  final List<ShoppingItem> items;

  /// Catalog categories, the aisles [sections] are ordered by.
  final List<CatalogCategory> categories;

  /// Usual ingredients to offer as chips, already filtered out of [items].
  final List<FridgeItem> usuals;
  final String query;
  final List<IngredientSuggestion> suggestions;

  /// The query holds a quantity ("500 g tomates"): Enter adds it directly.
  final bool queryHasAmount;
  final String? highlightedId;
  final int highlightToken;
  final ShoppingListFeedback? feedback;

  List<AisleSection> get sections => groupByAisle(items, categories);

  ShoppingListState copyWith({
    ShoppingListStatus? status,
    ShoppingList? list,
    List<ShoppingItem>? items,
    List<CatalogCategory>? categories,
    List<FridgeItem>? usuals,
    String? query,
    List<IngredientSuggestion>? suggestions,
    bool? queryHasAmount,
    String? highlightedId,
    int? highlightToken,
    ShoppingListFeedback? feedback,
  }) => ShoppingListState(
    status: status ?? this.status,
    list: list ?? this.list,
    items: items ?? this.items,
    categories: categories ?? this.categories,
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
    list,
    items,
    categories,
    usuals,
    query,
    suggestions,
    queryHasAmount,
    highlightedId,
    highlightToken,
    feedback,
  ];
}

/// One shopping list: its items grouped by aisle, added like in the fridge,
/// and moved to the fridge once bought.
class ShoppingListController extends Cubit<ShoppingListState> {
  ShoppingListController(
    this._listId,
    this._repository,
    this._catalogRepository,
    this._fridgeRepository,
    this._fridgeStockService,
    this._authUserService,
    this._userPersonnalInfoService,
  ) : super(const ShoppingListState()) {
    _listen();
    _loadCatalog();
  }

  static const _maxUsuals = 5;

  final EntityId _listId;
  final IShoppingListRepository _repository;
  final IIngredientCatalogRepository _catalogRepository;
  final IFridgeRepository _fridgeRepository;
  final FridgeStockService _fridgeStockService;
  final IAuthUserService _authUserService;
  final IUserPersonnalInfoService _userPersonnalInfoService;

  StreamSubscription<ShoppingList?>? _listSubscription;
  StreamSubscription<List<ShoppingItem>>? _itemsSubscription;
  StreamSubscription<List<FridgeItem>>? _usualsSubscription;
  IngredientSearch _search = const IngredientSearch();
  List<FridgeItem> _usualsHistory = const [];

  /// Items being moved to the fridge: a second tap must not buy them twice.
  final _buying = <EntityId>{};
  int _feedbackCount = 0;
  bool _memberNameChecked = false;

  EntityId get _uid => _authUserService.currentUser!.uid;

  EntityId get currentUserId => _uid;

  bool get isOwner => state.list?.isOwnedBy(_uid) ?? false;

  bool get _isGone =>
      state.status == ShoppingListStatus.deleted ||
      state.status == ShoppingListStatus.removed;

  void _onLoadError(Object error) {
    if (error is ShoppingListAccessLost) {
      safeEmit(state.copyWith(status: ShoppingListStatus.removed));
    } else if (!_isGone) {
      safeEmit(state.copyWith(status: ShoppingListStatus.error));
    }
  }

  void _listen() {
    _listSubscription = _repository
        .watchList(_listId)
        .listen(
          (list) {
            if (list == null) {
              safeEmit(state.copyWith(status: ShoppingListStatus.deleted));
              return;
            }
            safeEmit(state.copyWith(list: list));
            _ensureMemberName(list);
          },
          onError: (Object error) {
            log('Shopping list failed to load: $error');
            _onLoadError(error);
          },
        );

    _itemsSubscription = _repository
        .watchItems(_listId)
        .listen(
          (items) {
            safeEmit(
              state.copyWith(
                status: _isGone ? null : ShoppingListStatus.loaded,
                items: items,
                usuals: _usualsToOffer(items),
              ),
            );
            if (state.query.isNotEmpty) onQueryChanged(state.query);
          },
          onError: (Object error) {
            log('Shopping items failed to load: $error');
            _onLoadError(error);
          },
        );

    // The fridge usuals: what the user adds to the fridge is what they buy.
    _usualsSubscription = _fridgeRepository.watchUsuals(_uid).listen((usuals) {
      _usualsHistory = usuals;
      safeEmit(state.copyWith(usuals: _usualsToOffer(state.items)));
    }, onError: (Object error) => log('Usuals failed to load: $error'));
  }

  /// Lists created before collaboration have no member names: the user
  /// writes theirs once, for the other members to see it.
  Future<void> _ensureMemberName(ShoppingList list) async {
    if (_memberNameChecked) return;
    _memberNameChecked = true;
    if (list.nameOf(_uid)?.isNotEmpty ?? false) return;
    final name = await currentMemberName(_userPersonnalInfoService);
    if (name.isEmpty) return;
    try {
      await _repository.ensureMemberName(_listId, _uid, name);
    } catch (error) {
      log('Shopping list member name failed to save: $error');
    }
  }

  Future<void> _loadCatalog() async {
    try {
      _search = IngredientSearch(await _catalogRepository.loadCatalog());
      final categories = await _catalogRepository.loadCategories();
      safeEmit(state.copyWith(categories: categories));
      if (state.query.isNotEmpty) onQueryChanged(state.query);
    } catch (error) {
      // Search still works with free-text entries, all in "Others".
      log('Ingredient catalog failed to load: $error');
    }
  }

  List<FridgeItem> _usualsToOffer(List<ShoppingItem> items) =>
      (_usualsHistory.isEmpty ? defaultFridgeUsuals : _usualsHistory)
          .where(
            (usual) =>
                !items.any((item) => item.ingredient.sameIngredientAs(usual)),
          )
          .take(_maxUsuals)
          .toList();

  ShoppingItem? existingFor(FridgeItem draft) {
    for (final item in state.items) {
      if (item.ingredient.sameIngredientAs(draft)) return item;
    }
    return null;
  }

  /// Units offered first in the quantity sheet of [item], starting with its
  /// current unit.
  List<FridgeUnit> unitsFor(FridgeItem item) => _search.unitsFor(item);

  /// A usual chip turned into a draft, completed with the catalog when the
  /// ingredient is found in it.
  FridgeItem draftForUsual(FridgeItem usual) => _search.draftForUsual(usual);

  void onQueryChanged(String query) {
    final result = _search.search(
      query,
      isAlreadyAdded: (draft) => existingFor(draft) != null,
    );
    safeEmit(
      state.copyWith(
        query: query,
        suggestions: result.suggestions,
        queryHasAmount: result.hasAmount,
      ),
    );
  }

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
  /// list.
  Future<void> add(FridgeItem draft) async {
    try {
      final existing = existingFor(draft);
      if (existing != null) {
        final (merged, outcome) = mergeAdd(existing.ingredient, draft);
        if (outcome != MergeOutcome.alreadyIn) {
          await _repository.updateItem(
            _listId,
            existing.withIngredient(merged),
          );
        }
        safeEmit(
          state.copyWith(
            highlightedId: merged.id?.value,
            highlightToken: state.highlightToken + 1,
            feedback: ShoppingItemMergedFeedback(
              ++_feedbackCount,
              merged,
              outcome,
            ),
          ),
        );
        return;
      }

      final added = await _repository.addItem(
        _listId,
        ShoppingItem(
          ingredient: draft,
          categoryId: _search.catalogFor(draft)?.categoryId,
          addedBy: _uid,
        ),
      );
      safeEmit(
        state.copyWith(
          highlightedId: added.id?.value,
          highlightToken: state.highlightToken + 1,
        ),
      );
    } catch (error) {
      log('Shopping item add failed: $error');
      _failed();
    }
  }

  Future<void> save(ShoppingItem item) async {
    try {
      await _repository.updateItem(_listId, item);
      safeEmit(
        state.copyWith(
          highlightedId: item.id?.value,
          highlightToken: state.highlightToken + 1,
        ),
      );
    } catch (error) {
      log('Shopping item save failed: $error');
      _failed();
    }
  }

  Future<void> remove(ShoppingItem item) async {
    if (item.id == null) return;
    try {
      await _repository.removeItem(_listId, item.id!);
      safeEmit(
        state.copyWith(
          feedback: ShoppingItemRemovedFeedback(++_feedbackCount, item),
        ),
      );
    } catch (error) {
      log('Shopping item remove failed: $error');
      _failed();
    }
  }

  Future<void> undoRemove(ShoppingItem item) => _restore(item);

  /// Checks [item] as bought: it goes to the fridge with its quantity and
  /// leaves the list.
  Future<void> buy(ShoppingItem item) async {
    final id = item.id;
    if (id == null || !_buying.add(id)) return;
    try {
      final change = await _fridgeStockService.addOrMerge(
        _uid,
        item.fridgeDraft,
      );
      try {
        await _repository.removeItem(_listId, id);
      } catch (_) {
        // Still in the list: take it back out of the fridge.
        await _fridgeStockService.undo(_uid, change);
        rethrow;
      }
      safeEmit(
        state.copyWith(
          feedback: ShoppingItemBoughtFeedback(++_feedbackCount, item, change),
        ),
      );
    } catch (error) {
      log('Shopping item buy failed: $error');
      _failed();
    } finally {
      _buying.remove(id);
    }
  }

  /// Puts a bought [item] back in the list and takes it out of the fridge.
  Future<void> undoBuy(ShoppingItem item, FridgeStockChange change) async {
    try {
      await _fridgeStockService.undo(_uid, change);
    } catch (error) {
      log('Fridge undo failed: $error');
      _failed();
      return;
    }
    await _restore(item);
  }

  Future<void> _restore(ShoppingItem item) async {
    try {
      await _repository.restoreItem(_listId, item);
      safeEmit(
        state.copyWith(
          highlightedId: item.id?.value,
          highlightToken: state.highlightToken + 1,
        ),
      );
    } catch (error) {
      log('Shopping item restore failed: $error');
      _failed();
    }
  }

  /// The invitation link to share, null when it could not be made.
  Future<String?> invite() async {
    final list = state.list;
    if (list == null) return null;
    try {
      final token = await _repository.inviteToken(
        list,
        await currentMemberName(_userPersonnalInfoService),
      );
      return shoppingListInviteUrl(token);
    } catch (error) {
      log('Shopping list invitation failed: $error');
      _failed();
      return null;
    }
  }

  /// Takes [uid] out of the list. Only the owner can.
  Future<void> removeMember(EntityId uid) async {
    final list = state.list;
    if (list == null || !isOwner || uid == _uid) return;
    try {
      await _repository.removeMember(list, uid);
    } catch (error) {
      log('Shopping list member removal failed: $error');
      _failed();
    }
  }

  /// Takes the user out of the list. Returns false when it failed.
  Future<bool> leave() async {
    if (isOwner) return false;
    try {
      await _repository.leave(_listId, _uid);
      return true;
    } catch (error) {
      log('Shopping list leave failed: $error');
      _failed();
      return false;
    }
  }

  void _failed() => safeEmit(
    state.copyWith(feedback: ShoppingListErrorFeedback(++_feedbackCount)),
  );

  @override
  Future<void> close() async {
    await _listSubscription?.cancel();
    await _itemsSubscription?.cancel();
    await _usualsSubscription?.cancel();
    return super.close();
  }
}
