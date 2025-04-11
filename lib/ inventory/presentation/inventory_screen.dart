import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_ai/%20inventory/domain/repositories/inventory_repository.dart';
import 'package:recipe_ai/%20inventory/presentation/components/category_item.dart';
import 'package:recipe_ai/%20inventory/presentation/components/ingredient_category_item.dart';
import 'package:recipe_ai/%20inventory/presentation/components/ingredient_selected_item.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/custom_text_form_field.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/translated_text.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/presentation/receipt_ticket_scan_controller.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'inventory_controller.dart';

class InventoryScreen extends StatelessWidget {
  InventoryScreen({super.key});

  void _takeCameraPicture(ReceiptTicketScanController controller) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      controller.scanReceiptTicket(File(photo.path));
    }
  }

  void _uploadReceiptPicture(ReceiptTicketScanController controller) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      controller.scanReceiptTicket(File(photo.path));
    }
  }

  void _showBottomSheet(BuildContext context) {
    final controller = context.read<ReceiptTicketScanController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: TranslatedText(
                  textSelector: (lang) => lang.selectPicture,
                  style: smallTextStyle.copyWith(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  _uploadReceiptPicture(controller);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: TranslatedText(
                  textSelector: (lang) => lang.takePhoto,
                  style: smallTextStyle.copyWith(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  _takeCameraPicture(controller);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryController(
        di<IInventoryRepository>(),
        di<IKitchenInventoryRepository>(),
        di<IAuthUserService>(),
        di<IAnalyticsRepository>(),
      ),
      child: BlocBuilder<InventoryController, InventoryState>(
        builder: (context, state) {
          final controller = context.read<InventoryController>();

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: TranslatedText(
                  textSelector: (lang) => lang.yourKitchenInventory,
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
                      child: Builder(builder: (context) {
                        return ListenableBuilder(
                            listenable: di<TranslationController>(),
                            builder: (context, _) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: RawAutocomplete<Ingredient>(
                                      displayStringForOption: (option) {
                                        return option.name;
                                      },
                                      optionsBuilder: (textEditingValue) {
                                        return [];
                                      },
                                      onSelected: (ingredient) {},
                                      optionsViewBuilder:
                                          (context, onSelected, options) {
                                        return Align(
                                          alignment: Alignment.topCenter,
                                          child: Material(
                                            child: SizedBox(
                                              width: 100.w,
                                              child: ListView.builder(
                                                itemBuilder: (context, index) {
                                                  final ingredient =
                                                      options.elementAt(index);

                                                  return IngredientCategoryItem(
                                                      onTap: () {},
                                                      ingredient: ingredient);
                                                },
                                                itemCount: options.length,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      fieldViewBuilder: (context,
                                          textEditingController,
                                          focusNode,
                                          onFieldSubmitted) {
                                        return CustomTextFormField(
                                          hintText: di<TranslationController>()
                                              .currentLanguage
                                              .searchForIngredients,
                                          inputType: InputType.text,
                                          onChange: (value) {
                                            controller.searchIngredients(
                                                value.toLowerCase());
                                          },
                                          validator: (_) {
                                            return;
                                          },
                                          controller: queryController,
                                        );
                                      },
                                    ),
                                  ),
                                  const Gap(11),
                                  BlocProvider(
                                    create: (context) =>
                                        ReceiptTicketScanController(
                                      di<IReceiptTicketScanRepository>(),
                                      di<IAnalyticsRepository>(),
                                      di<IAuthUserService>(),
                                    ),
                                    child: BlocConsumer<
                                        ReceiptTicketScanController,
                                        ReceiptTicketScanState>(
                                      listener: (context, state) {
                                        if (state is ReceiptTicketScanLoaded) {
                                          //A retravailler
                                          context.push(
                                            "/home/kitchen-inventory/receipt-ticket-scan-result",
                                            extra: {
                                              "ingredients": (state)
                                                  .receiptTicket
                                                  .products
                                                  .map(
                                                    (product) => Ingredient(
                                                      name: product.name,
                                                      quantity:
                                                          product.quantity,
                                                      date: null,
                                                      id: null,
                                                    ),
                                                  )
                                                  .toList(),
                                            },
                                          );
                                        } else if (state
                                            is ReceiptTicketScanError) {
                                          showSnackBar(
                                            context,
                                            di<TranslationController>()
                                                .currentLanguage
                                                .somethingWentWrong,
                                            isError: true,
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        return GestureDetector(
                                          onTap:
                                              state is! ReceiptTicketScanLoading
                                                  ? () {
                                                      _showBottomSheet(context);
                                                    }
                                                  : null,
                                          child: state
                                                  is ReceiptTicketScanLoading
                                              ? Center(
                                                  child: CustomProgress(
                                                    color: Colors.black,
                                                  ),
                                                )
                                              : Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  child: Icon(
                                                    Icons.camera_alt_rounded,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              );
                            });
                      }),
                    ),
                    if (state.ingredientsSuggested.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 20),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            height: state.ingredientsSuggested.length * 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  bottom: 90, left: 5, right: 5, top: 5),
                              itemBuilder: (context, index) {
                                final ingredient =
                                    state.ingredientsSuggested[index];
                                return IngredientSelectedItem(
                                    isSelected: controller
                                        .isIngredientSelected(ingredient),
                                    onTap: () {
                                      if (!controller
                                          .isIngredientSelected(ingredient)) {
                                        queryController.clear();
                                        controller.addIngredient(ingredient);
                                        controller.closeIngredientsSuggested();

                                        FocusScope.of(context).unfocus();
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
                    SliverToBoxAdapter(
                      child: Gap(20),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 10),
                      sliver: SliverToBoxAdapter(
                        child: TranslatedText(
                          textSelector: (lang) => lang.ingredients,
                          style: normalTextStyle,
                        ),
                      ),
                    ),
                    state.ingredientsAddedByUser.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                children: [
                                  const Gap(20),
                                  Image.asset(
                                    'assets/images/placeholder_inventory.png',
                                    width: 200,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  const Gap(10),
                                  TranslatedText(
                                    textSelector: (lang) => lang.fillKitchen,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const Gap(30),
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
                                return IngredientSelectedItem(
                                    isSelected: true,
                                    onTap: () {
                                      controller.removeIngredient(ingredient);
                                    },
                                    ingredient: ingredient);
                              },
                              itemCount: state.ingredientsAddedByUser.length,
                            ),
                          ),
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
                    SliverPadding(
                        padding: const EdgeInsets.only(
                            bottom: 40, left: 10, right: 10),
                        sliver: SliverToBoxAdapter(
                          child: Wrap(
                            direction: Axis.horizontal,
                            spacing: 10,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            runSpacing: 20,
                            children: List.generate(
                              state.ingredients.length,
                              (index) {
                                return IngredientCategoryItem(
                                  onTap: () {
                                    if (!controller.isIngredientSelected(
                                        state.ingredients[index])) {
                                      controller.addIngredient(
                                          state.ingredients[index]);
                                    }
                                  },
                                  ingredient: state.ingredients[index],
                                );
                              },
                            ),
                          ),
                        ))
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
