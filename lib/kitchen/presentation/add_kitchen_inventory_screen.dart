import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/presentation/add_kitchen_inventory_controller.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

class AddKitchenInventoryScreen extends StatefulWidget {
  const AddKitchenInventoryScreen({super.key});

  @override
  State<AddKitchenInventoryScreen> createState() =>
      _AddKitchenInventoryScreenState();
}

class _AddKitchenInventoryScreenState extends State<AddKitchenInventoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();

  void _handleIngredient(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Add ingredient

      context.read<AddKitchenInventoryController>().addKitchenInventory(
          name: _nameController.text,
          quantity: _quantityController.text,
          timestamp: DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddKitchenInventoryController(
          di<IKitchenInventoryRepository>(), di<IAuthUserService>()),
      child: BlocListener<AddKitchenInventoryController, AddKitchenState?>(
        listener: (context, state) {
          if (state is AddKitchenSuccess) {
            context.pop();
            showSnackBar(
              context,
              AppText.addIngredientSuccess,
            );
          } else if (state is AddKitchenFailed) {
            showSnackBar(
              context,
              state.message!,
              isError: true,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const BackButton(
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
            title: Text(
              AppText.addKitchen,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                height: 30 / 20,
                color: Colors.black,
              ),
            ),
          ),
          body: Builder(builder: (context) {
            return SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: horizontalScreenPadding, vertical: 20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(20),
                      FormFieldWithLabel(
                        label: AppText.name,
                        hintText: AppText.enterName,
                        controller: _nameController,
                        validator: nonEmptyStringValidator,
                        keyboardType: TextInputType.name,
                      ),
                      const Gap(20),
                      FormFieldWithLabel(
                        label: AppText.quantity,
                        hintText: AppText.enterQuantity,
                        controller: _quantityController,
                        validator: nonEmptyStringValidator,
                        keyboardType: TextInputType.number,
                      ),
                      const Gap(20),
                      MainBtn(
                        isLoading: false,
                        text: AppText.validate,
                        onPressed: () {
                          // context
                          //     .read<AddKitchenInventoryController>()
                          //     .testEmit();
                          _handleIngredient(context);
                        },
                      ),
                    ],
                  )),
            ));
          }),
        ),
      ),
    );
  }
}
