import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recipe_ai/shopping/presentation/shopping_controller.dart';
import 'package:recipe_ai/shopping/presentation/shopping_state.dart';
import 'package:recipe_ai/shopping/presentation/widgets/add_item_field.dart';
import 'package:recipe_ai/shopping/presentation/widgets/category_filter_chips.dart';
import 'package:recipe_ai/shopping/presentation/widgets/empty_shopping_list.dart';
import 'package:recipe_ai/shopping/presentation/widgets/inventory_item_card.dart';
import 'package:recipe_ai/shopping/presentation/widgets/search_bar_widget.dart';
import 'package:recipe_ai/shopping/presentation/widgets/shopping_item_card.dart';
import 'package:recipe_ai/shopping/presentation/widgets/shopping_progress_bar.dart';
import 'package:recipe_ai/shopping/presentation/widgets/shopping_tab_bar.dart';
import 'package:recipe_ai/shopping/presentation/widgets/store_mode_header.dart';
import 'package:recipe_ai/shopping/presentation/widgets/suggestions_section.dart';
import 'package:recipe_ai/shopping/presentation/widgets/transfer_button.dart';
import 'package:recipe_ai/shopping/presentation/widgets/green_curved_header.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShoppingController(),
      child: BlocBuilder<ShoppingController, ShoppingState>(
        builder: (context, state) {
          final controller = context.read<ShoppingController>();

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: Column(
              children: [
                // Header (includes tab bar inside the green area)
                if (state.isStoreMode)
                  StoreModeHeader(
                    onToggleStoreMode: controller.toggleStoreMode,
                  )
                else
                  _NormalHeader(
                    activeTab: state.activeTab,
                    onSwitchTab: controller.switchTab,
                    onToggleStoreMode: controller.toggleStoreMode,
                  ),

                const SizedBox(height: 12),

                // Body
                Expanded(
                  child: state.activeTab == ShoppingTab.inventory &&
                          !state.isStoreMode
                      ? _InventoryTabView(state: state, controller: controller)
                      : _ShoppingListTabView(
                          state: state, controller: controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NormalHeader extends StatelessWidget {
  const _NormalHeader({
    required this.activeTab,
    required this.onSwitchTab,
    required this.onToggleStoreMode,
  });

  final ShoppingTab activeTab;
  final ValueChanged<ShoppingTab> onSwitchTab;
  final VoidCallback onToggleStoreMode;

  @override
  Widget build(BuildContext context) {
    return GreenCurvedHeader(
      title: 'Ma cuisine',
      actions: [
        _HeaderIconButton(
           asset: 'system-uicons_share',
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
         asset: 'magazin',
          onTap: onToggleStoreMode,
        ),
      ],
      bottom: ShoppingTabBar(
        activeTab: activeTab,
        onSwitch: onSwitchTab,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.asset,
    required this.onTap,
  });

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset('assets/icon/$asset.svg',
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _InventoryTabView extends StatefulWidget {
  const _InventoryTabView({
    required this.state,
    required this.controller,
  });

  final ShoppingState state;
  final ShoppingController controller;

  @override
  State<_InventoryTabView> createState() => _InventoryTabViewState();
}

class _InventoryTabViewState extends State<_InventoryTabView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.state.filteredInventoryItems;

    return Column(
      children: [
        SearchBarWidget(
          controller: _searchController,
          onChanged: (query) {
            widget.controller.updateSearchQuery(query);
            setState(() {});
          },
          onClear: () {
            widget.controller.updateSearchQuery('');
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        CategoryFilterChips(
          categories: widget.state.categories,
          selectedCategoryId: widget.state.selectedCategoryId,
          onSelect: widget.controller.selectCategory,
        ),
        const SizedBox(height: 30),
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('\u{1F371}', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        'Inventaire vide',
                        style: TextStyle(
                          fontFamily: poppinsFontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: neutralBlackColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des articles avec le champ\nci-dessus ou depuis l\'inventaire.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: poppinsFontFamily,
                          fontSize: 13,
                          color: neutralGreyColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                   left: 24,
                   right: 24,
                   bottom: 200
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return InventoryItemCard(
                      item: item,
                      onIncrement: () =>
                          widget.controller.incrementInventoryQuantity(item.id),
                      onDecrement: () =>
                          widget.controller.decrementInventoryQuantity(item.id),
                      onSendToShoppingList: () =>
                          widget.controller.sendToShoppingList(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ShoppingListTabView extends StatelessWidget {
  const _ShoppingListTabView({
    required this.state,
    required this.controller,
  });

  final ShoppingState state;
  final ShoppingController controller;

  @override
  Widget build(BuildContext context) {
    final groupedItems = state.shoppingItemsByCategory;
    final isStoreMode = state.isStoreMode;

    return Stack(
      children: [
        Column(
          children: [
            // Add item field (hidden in store mode)
            if (!isStoreMode) ...[
              AddItemField(onAdd: controller.addShoppingItem),
              const SizedBox(height: 12),
            ],
        
            // Progress bar
            if (state.totalShoppingCount > 0) ...[
              ShoppingProgressBar(
                checked: state.checkedCount,
                total: state.totalShoppingCount,
                progress: state.progressPercent,
                isStoreMode: isStoreMode,
              ),
              const SizedBox(height: 20),
            ],
        
            // Shopping list or empty state
            Expanded(
              child: state.shoppingItems.isEmpty
                  ? const EmptyShoppingList()
                  : ListView(
                    
                      padding: const EdgeInsets.only(
                       left: 30,
                       right: 30,
                       bottom: 150
                      ),
                      children: [
                        for (final entry in groupedItems.entries) ...[
                          // Category header
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              entry.key.toUpperCase(),
                              style: TextStyle(
                                fontFamily: poppinsFontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: greenPrimaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Items
                          for (final item in entry.value)
                            ShoppingItemCard(
                              item: item,
                              isStoreMode: isStoreMode,
                              onToggleChecked: () =>
                                  controller.toggleShoppingItemChecked(item.id),
                              onIncrement: () =>
                                  controller.incrementShoppingQuantity(item.id),
                              onDecrement: () =>
                                  controller.decrementShoppingQuantity(item.id),
                            ),
                        ],
                        // Suggestions (hidden in store mode)
                        if (!isStoreMode)
                          SuggestionsSection(
                            suggestions: state.suggestions,
                            onAdd: controller.addSuggestionToList,
                          ),
                        const SizedBox(height: 120),
                      ],
                    ),
            ),
            
        
           
          ],
        ),

        // Transfer button pinned to bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: TransferButton(
            checkedCount: state.checkedCount,
            allChecked: state.allChecked,
            onTransfer: controller.transferCheckedToInventory,
            isStoreMode: isStoreMode,
          ),
        ),
      ],
    );
  }
}
