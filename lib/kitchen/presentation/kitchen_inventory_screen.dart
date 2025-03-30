import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/custom_text_form_field.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/presentation/ingredient_controller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_controller.dart';
import 'package:recipe_ai/kitchen/presentation/receipt_ticket_scan_controller.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';
import 'package:recipe_ai/receipt_ticket_scan/presentation/receipt_ticket_scan_result_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';

class ReceipeTicketScanScreen extends StatelessWidget {
  const ReceipeTicketScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return SafeArea(
      child: Scaffold(
        appBar: KitchenInventoryAppBar(
          title: appTexts.yourKitchenInventory,
          arrowLeftOnPressed: () => context.go('/home/kitchen-inventory'),
        ),
        body: const _EmptyKitchenInventoryView(
          showDescription: false,
        ),
      ),
    );
  }
}

class KitchenInventoryScreen extends StatelessWidget {
  const KitchenInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (context) => KitchenInventoryController(
        di<IKitchenInventoryRepository>(),
        di<IAuthUserService>(),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: KitchenInventoryAppBar(
            title: appTexts.yourKitchenInventory,
            arrowLeftOnPressed: () => context.go('/home'),
            action: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  onTap: () => context.go(
                    "/home/kitchen-inventory/receipt-ticket-scan",
                  ),
                  child: const Icon(Icons.qr_code_scanner),
                ),
                const Gap(8),
                InkWell(
                  onTap: () => context.go(
                    "/home/kitchen-inventory/display-receipes-based-on-ingredient-user-preference",
                  ),
                  child: SvgPicture.asset(
                    'assets/images/generateIcon.svg',
                  ),
                ),
                const Gap(8),
              ],
            ),
          ),
          body: Builder(builder: (context) {
            return BlocBuilder<KitchenInventoryController, KitchenState>(
              builder: (context, state) {
                if (state is KitchenStateLoading) {
                  return const Center(
                    child: CustomProgress(
                      color: Colors.black,
                    ),
                  );
                }
                if (state is KitchenStateError) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                if (state is KitchenStateLoaded) {
                  return state.ingredients.isEmpty
                      ? const _EmptyKitchenInventoryView()
                      : _InventoryContentView(
                          ingredients: state.ingredientsFiltered,
                        );
                }

                return Container();
              },
            );
          }),
        ),
      ),
    );
  }
}

/// The appBar for every screen in the kitchen inventory section
class KitchenInventoryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const KitchenInventoryAppBar({
    super.key,
    this.arrowLeftOnPressed,
    required this.title,
    this.action,
    this.showBackBtn = true,
  });

  final String title;

  final VoidCallback? arrowLeftOnPressed;

  final Widget? action;
  final bool showBackBtn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 14.0,
        left: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showBackBtn) ...[
                InkWell(
                  onTap: arrowLeftOnPressed,
                  child: SvgPicture.asset('assets/images/arrow-black-left.svg'),
                ),
                const Gap(25),
              ],
              Text(
                title,
                style: mediumTextStyle,
              ),
            ],
          ),
          if (action != null) action!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}

class _InventoryContentView extends StatefulWidget {
  final List<Ingredient> ingredients;
  const _InventoryContentView({required this.ingredients});

  @override
  State<_InventoryContentView> createState() => _InventoryContentViewState();
}

class _InventoryContentViewState extends State<_InventoryContentView> {
  final TextEditingController searchController = TextEditingController();

  // Debounce duration
  final Duration _debouceDuration = const Duration(milliseconds: 500);

  Timer? _debounce;

  onSearchChanged(BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(_debouceDuration, () {
      context
          .read<KitchenInventoryController>()
          .searchForIngredients(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  hintText: appTexts.searchForIngredients,
                  controller: searchController,
                  onChange: (query) => onSearchChanged(context),
                  validator: (_) {
                    return;
                  },
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : InkWell(
                          onTap: () {
                            searchController.clear();
                            onSearchChanged(context);
                          },
                          child: const Icon(Icons.close),
                        ),
                ),
              ),
            ],
          ),
          const Gap(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appTexts.addItem,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.push(
                    "/home/kitchen-inventory/add-kitchen-inventory",
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: greenPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
          const Gap(20),
          Text(
            appTexts.myItems,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: widget.ingredients.isEmpty
                ? Center(
                    child: Text(
                      "No ingredients",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
                    itemBuilder: (context, index) {
                      return IngredientItem(
                          readOnly: false,
                          ingredient: widget.ingredients[index],
                          onDismissed: (_) {
                            context
                                .read<KitchenInventoryController>()
                                .removeIngredient(
                                  widget.ingredients[index].id!,
                                );
                            // Hide the current snackbar
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            showSnackBar(context, appTexts.ingredientRemoved);
                          });
                    },
                    itemCount: widget.ingredients.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class IngredientItem extends StatefulWidget {
  final Ingredient ingredient;
  const IngredientItem({
    super.key,
    required this.ingredient,
    this.getIngredientQuantity,
    required this.onDismissed,
    this.readOnly = false,
    this.getIngredientName,
  });
  final Function(String? value)? getIngredientQuantity;
  final Function(String? value)? getIngredientName;
  final Function(DismissDirection)? onDismissed;
  final bool readOnly;

  @override
  State<IngredientItem> createState() => _IngredientItemState();
}

class _IngredientItemState extends State<IngredientItem> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.ingredient.quantity.toString();
    _nameController.text = widget.ingredient.name.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IngredientController(
        widget.ingredient,
        di<IKitchenInventoryRepository>(),
        di<IAuthUserService>(),
      ),
      child: Builder(builder: (context) {
        return IngredientDismissedWidget(
          onDismissed: widget.onDismissed,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFBA4D)),
            ),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              // padding: const EdgeInsets.only(
              //   left: 10,
              //   right: 10,
              //   top: 20,
              //   bottom: 20,
              // ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: TextFormField(
                        readOnly: widget.readOnly,
                        controller: _nameController,
                        onChanged: (String name) {
                          if (widget.getIngredientName != null) {
                            widget.getIngredientName!(name);
                          }
                        },
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          // filled: true,
                          // fillColor: const Color(0xffEEEEEE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Text(
                  //   widget.ingredient.name,
                  //   style: GoogleFonts.poppins(
                  //     fontWeight: FontWeight.w600,
                  //     fontSize: 14,
                  //   ),
                  // ),

                  // SizedBox(
                  //   width: 50,
                  //   height: 30,
                  //   child: TextFormField(
                  //     readOnly: widget.readOnly,
                  //     controller: _quantityController,
                  //     onChanged: (String quantity) {
                  //       if (widget.getIngredientQuantity != null) {
                  //         widget.getIngredientQuantity!(quantity);
                  //       }
                  //       if (widget.ingredient.id != null) {
                  //         context
                  //             .read<IngredientController>()
                  //             .updateIngredient(quantity);
                  //       }
                  //     },
                  //     textAlign: TextAlign.center,
                  //     inputFormatters: [
                  //       FilteringTextInputFormatter.allow(
                  //         RegExp(r'[0-9]'),
                  //       ),
                  //     ],
                  //     decoration: InputDecoration(
                  //       contentPadding: const EdgeInsets.symmetric(
                  //         horizontal: 2,
                  //       ),
                  //       filled: true,
                  //       fillColor: const Color(0xffEEEEEE),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(5),
                  //         borderSide: BorderSide.none,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyKitchenInventoryView extends StatefulWidget {
  const _EmptyKitchenInventoryView({this.showDescription = true});

  final bool showDescription;

  @override
  State<_EmptyKitchenInventoryView> createState() =>
      _EmptyKitchenInventoryViewState();
}

class _EmptyKitchenInventoryViewState
    extends State<_EmptyKitchenInventoryView> {
  File? _receiptPicture;

  void _takeCameraPicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _receiptPicture = File(photo.path);
      });
    }
  }

  void _uploadReceiptPicture() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _receiptPicture = File(result.files.single.path!);
      });
    }
  }

  void _showBottomSheet() {
    final appTexts = di<TranslationController>().currentLanguage;
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
                title: Text(
                  appTexts.selectPicture,
                  style: smallTextStyle.copyWith(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  _uploadReceiptPicture();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(
                  appTexts.takePhoto,
                  style: smallTextStyle.copyWith(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  _takeCameraPicture();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const Gap(10.0),
            Visibility(
              visible: widget.showDescription,
              child: Center(
                child: Text(
                  appTexts.emptyKitchenText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Colors.black,
                      ),
                ),
              ),
            ),
            const Gap(40),
            BlocProvider(
              create: (context) => ReceiptTicketScanController(
                di<IReceiptTicketScanRepository>(),
              ),
              child: BlocListener<ReceiptTicketScanController,
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
                                quantity: product.quantity,
                                date: null,
                                id: null,
                              ),
                            )
                            .toList(),
                      },
                    );
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 243,
                      height: 371,
                      decoration: BoxDecoration(
                        color: greyVariantColor,
                        borderRadius: BorderRadius.circular(10),
                        image: _receiptPicture != null
                            ? DecorationImage(
                                image: FileImage(
                                  _receiptPicture!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                    const Gap(21),
                    GestureDetector(
                      onTap: () {
                        context.push(
                            "/home/kitchen-inventory/add-kitchen-inventory");
                      },
                      child: Text(
                        appTexts.clickHereToAdd,
                        style: smallTextStyle.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const Gap(3),
                    Text(
                      appTexts.or,
                      style: smallTextStyle,
                    ),
                    const Gap(3),
                    GestureDetector(
                      onTap: _showBottomSheet,
                      child: Text(
                        appTexts.takeYourReceiptPicture,
                        style: smallTextStyle.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    BlocBuilder<ReceiptTicketScanController,
                        ReceiptTicketScanState>(
                      builder: (context, receiptTicketScanState) {
                        if (receiptTicketScanState
                            is ReceiptTicketScanLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: CustomProgress(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }

                        if (_receiptPicture != null &&
                            (receiptTicketScanState
                                    is ReceiptTicketScanInitial ||
                                receiptTicketScanState
                                    is ReceiptTicketScanError)) {
                          return Column(
                            children: [
                              Builder(
                                builder: (context) {
                                  if (receiptTicketScanState
                                      is ReceiptTicketScanError) {
                                    return Center(
                                      child: Text(
                                        appTexts.receiptTicketScanError,
                                      ),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20.0,
                                  left: 40,
                                  right: 40,
                                ),
                                child: MainBtn(
                                  text: appTexts.scanReceiptTicket,
                                  onPressed: () => context
                                      .read<ReceiptTicketScanController>()
                                      .scanReceiptTicket(_receiptPicture!),
                                ),
                              ),
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Gap(50),
          ],
        ),
      ),
    );
  }
}

class KitchenInventoryActionWidget extends StatelessWidget {
  const KitchenInventoryActionWidget({
    super.key,
    required this.icon,
    this.onPressed,
  });

  final String icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
          ),
        ),
      ),
    );
  }
}
