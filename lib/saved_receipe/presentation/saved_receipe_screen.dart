import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/saved_receipe/presentation/remove_saved_receipe_controller.dart';
import 'package:recipe_ai/saved_receipe/presentation/saved_receipe_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/constant.dart';

class SavedReceipeScreen extends StatelessWidget {
  const SavedReceipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavedReceipeController(
        di<IUserReceipeRepository>(),
        di<IAuthUserService>(),
      ),
      child: Builder(builder: (context) {
        return SafeArea(
            child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            title: Text(
              'Saved Receipes',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 17),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalScreenPadding,
            ),
            child: BlocBuilder<SavedReceipeController, SavedReceipeState>(
              builder: (context, state) {
                if (state is SavedReceipeStateLoading) {
                  return const Center(
                    child: CustomProgress(
                      color: Colors.black,
                    ),
                  );
                }

                if (state is SavedReceipeStateError) {
                  return Center(
                    child: Text(state.message),
                  );
                }

                if (state is SavedReceipeStateLoaded) {
                  return state.savedReceipes.isEmpty
                      ? const Center(
                          child: Text(AppText.noSavedReceipes),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20, top: 15),
                          itemBuilder: (context, index) {
                            final data = state.savedReceipes[index];
                            return BlocProvider(
                              create: (context) => RemoveSavedReceipeController(
                               
                                di<IUserReceipeRepository>(),
                                di<IAuthUserService>(),
                              ),
                              child: BlocListener<RemoveSavedReceipeController,
                                  ReceipeItemState>(
                                listener: (context, state) {
                                  if (state is ReceipeItemStateError) {
                                    showSnackBar(context, state.message,
                                        isError: true);
                                  }
                                },
                                child: BlocBuilder<RemoveSavedReceipeController,
                                    ReceipeItemState>(
                                  builder: (context, state) {
                                    return ReceipeItem(
                                      receipe: data,
                                      isSaved: state is ReceipeItemStateSaved,
                                      onTap: () {
                                        context
                                            .read<
                                                RemoveSavedReceipeController>()
                                            .removeReceipe(data.name
                                                .toLowerCase()
                                                .replaceAll(' ', ''));
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          itemCount: state.savedReceipes.length,
                        );
                }

                return const SizedBox();
              },
            ),
          ),
        ));
      }),
    );
  }
}
