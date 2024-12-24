import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_text_form_field.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_controller.dart';
import 'package:recipe_ai/kitchen/presentation/receipt_ticket_scan_controller.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipt_ticket_scan/application/repositories/receipt_ticket_scan_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';

class KitchenInventoryScreen extends StatelessWidget {
  const KitchenInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KitchenInventoryController(
        di<IKitchenInventoryRepository>(),
        di<IAuthUserService>(),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: KitchenInventoryAppBar(
            arrowLeftOnPressed: () => context.go('/home'),
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
  });

  final VoidCallback? arrowLeftOnPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // InkWell(
          //   onTap: arrowLeftOnPressed,
          //   child: SvgPicture.asset('assets/images/arrow-black-left.svg'),
          // ),
          // const Gap(25),
          Text(
            AppText.yourKitchenInventory,
            style: mediumTextStyle,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  hintText: AppText.searchForIngredients,
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
              const Gap(20),
              GestureDetector(
                onTap: () {
                  context.push("/add-kitchen-inventory");
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
            AppText.myItems,
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemBuilder: (context, index) {
                      return _IngredientItem(
                          ingredient: widget.ingredients[index]);
                    },
                    itemCount: widget.ingredients.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final Ingredient ingredient;
  const _IngredientItem({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4), // décalage de l'ombre
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        child: Row(
          children: [
            Text(
              ingredient.name,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const Spacer(),
            Text("${ingredient.quantity}")
          ],
        ),
      ),
    );
  }
}

class _EmptyKitchenInventoryView extends StatefulWidget {
  const _EmptyKitchenInventoryView();

  @override
  State<_EmptyKitchenInventoryView> createState() =>
      _EmptyKitchenInventoryViewState();
}

class _EmptyKitchenInventoryViewState
    extends State<_EmptyKitchenInventoryView> {
  File? _receiptPicture;

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Gap(10.0),
          Center(
            child: Text(
              AppText.emptyKitchenText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Colors.black,
                  ),
            ),
          ),
          const Gap(30),
          BlocProvider(
            create: (context) => ReceiptTicketScanController(
              di<IReceiptTicketScanRepository>(),
            ),
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
                    context.push("/add-kitchen-inventory");
                  },
                  child: Text(
                    AppText.clickHereToAdd,
                    style: smallTextStyle.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const Gap(3),
                Text(
                  AppText.or,
                  style: smallTextStyle,
                ),
                const Gap(3),
                GestureDetector(
                  onTap: _uploadReceiptPicture,
                  child: Text(
                    AppText.takeYourReceiptPicture,
                    style: smallTextStyle.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                BlocBuilder<ReceiptTicketScanController,
                    ReceiptTicketScanState>(
                  builder: (context, receiptTicketScanState) {
                    if (receiptTicketScanState is ReceiptTicketScanLoading) {
                      return const Center(
                        child: CustomProgress(
                          color: Colors.black,
                        ),
                      );
                    }

                    if (_receiptPicture != null &&
                        (receiptTicketScanState is ReceiptTicketScanInitial ||
                            receiptTicketScanState is ReceiptTicketScanError)) {
                      if (receiptTicketScanState is ReceiptTicketScanError) {
                        return Center(
                          child: Text(receiptTicketScanState.message),
                        );
                      }
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          left: 40,
                          right: 40,
                        ),
                        child: MainBtn(
                          text: AppText.scanReceiptTicket,
                          onPressed: () {},
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          const Gap(50),
        ],
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
