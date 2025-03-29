import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/%20inventory/domain/repositories/inventory_repository.dart';
import 'package:recipe_ai/%20inventory/presentation/components/category_item.dart';
import 'package:recipe_ai/%20inventory/presentation/components/ingredient_category_item.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_text_form_field.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'inventory_controller.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    return BlocProvider(
      create: (context) => InventoryController(di<IInventoryRepository>(),
          di<IKitchenInventoryRepository>(), di<IAuthUserService>()),
      child: BlocBuilder<InventoryController, InventoryState>(
        builder: (context, state) {
          final controller = context.read<InventoryController>();
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  appTexts.yourKitchenInventory,
                  style: mediumTextStyle,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: horizontalScreenPadding,
                    vertical: verticalScreenPadding),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Autocomplete<Ingredient>(
                              displayStringForOption: (option) {
                                return option.name;
                              },
                              optionsBuilder: (textEditingValue) async {
                                await controller.searchIngredients(
                                    textEditingValue.text.toLowerCase());
                                // final test = state.ingredientsSuggested;
                                return state.ingredientsSuggested;
                              },
                              onSelected: (ingredient) {
                                if (!controller
                                    .isIngredientSelected(ingredient)) {
                                  controller.addIngredient(ingredient);
                                }
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    height: 200,
                                    child: Material(
                                      child: ListView.builder(
                                        itemBuilder: (context, index) {
                                          final ingredient =
                                              options.elementAt(index);

                                          return IngredientCategoryItem(
                                              isSelected: controller
                                                  .isIngredientSelected(
                                                      ingredient),
                                              onTap: () {},
                                              ingredient: ingredient);
                                        },
                                        itemCount: options.length,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                return CustomTextFormField(
                                  hintText: appTexts.searchForIngredients,
                                  inputType: InputType.text,
                                  onChange: (value) {
                                    controller
                                        .searchIngredients(value.toLowerCase());
                                  },
                                  validator: (_) {
                                    return;
                                  },
                                  controller: textEditingController,
                                );
                              },
                            ),
                          ),
                          const Gap(11),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    if (state.ingredientsSuggested.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 20),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 7),
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                final ingredient =
                                    state.ingredientsSuggested[index];
                                return IngredientCategoryItem(
                                    isSelected: controller
                                        .isIngredientSelected(ingredient),
                                    onTap: () {
                                      if (!controller
                                          .isIngredientSelected(ingredient)) {
                                        controller.addIngredient(ingredient);
                                      }
                                    },
                                    ingredient: ingredient);
                              },
                              itemCount: state.ingredientsSuggested.length,
                            ),
                          ),
                        ),
                      )
                    ],
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          appTexts.myItems,
                          style: normalTextStyle,
                        ),
                      ),
                    ),
                    state.ingredientsAddedByUser.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/placeholder_inventory.png',
                                    width: 180,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                  const Gap(5),
                                  Text(
                                    appTexts.fillKitchen,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.only(bottom: 50),
                            sliver: SliverList.builder(
                              itemBuilder: (context, index) {
                                final ingredient =
                                    state.ingredientsAddedByUser[index];
                                return IngredientCategoryItem(
                                    isSelected: true,
                                    onTap: () {
                                      controller.removeIngredient(ingredient);
                                    },
                                    ingredient: ingredient);
                              },
                              itemCount: state.ingredientsAddedByUser.length,
                            ),
                          ),
                    if (MediaQuery.of(context).viewInsets.bottom == 0) ...[
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 20),
                        sliver: SliverToBoxAdapter(
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final category = state.categories[index];
                                return CategoryItem(
                                  isSelected: state.categoryIdSelected ==
                                      category.id?.value,
                                  onTap: () {
                                    controller.onSelectCategory(
                                        category.id?.value ?? '');
                                  },
                                  category: state.categories[index],
                                );
                              },
                              itemCount: state.categories.length,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 50.h,
                          child: PageView.builder(
                            onPageChanged: (value) {
                              final category = state.categories[value];
                              controller
                                  .onSelectCategory(category.id?.value ?? '');
                            },
                            itemBuilder: (context, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      "A to Z",
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Gap(15),
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(
                                          bottom: 40, left: 10, right: 10),
                                      itemBuilder: (context, index) {
                                        final ingredient =
                                            state.ingredients[index];
                                        return IngredientCategoryItem(
                                          isSelected: controller
                                              .isIngredientSelected(ingredient),
                                          onTap: () {
                                            if (!controller
                                                .isIngredientSelected(
                                                    ingredient)) {
                                              controller
                                                  .addIngredient(ingredient);
                                            }
                                          },
                                          ingredient: ingredient,
                                        );
                                      },
                                      itemCount: state.ingredients.length,
                                    ),
                                  )
                                ],
                              );
                            },
                            itemCount: state.categories.length,
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
