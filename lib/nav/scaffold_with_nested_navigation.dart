import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_bottom_nav.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/generate_recipe_with_ingredient_photo_controller.dart';
import 'package:recipe_ai/nav/hide_nav_bar.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/utils/constant.dart';

class NavigationItem extends Equatable {
  const NavigationItem({
    required this.icon,
  });

  final String icon;

  @override
  List<Object?> get props => [icon];
}

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
    required this.hideNavBar,
    this.actions,
    this.appBarTitle,
  }) : super(
          key: key ?? const ValueKey<String>("ScaffoldWithNestedNavigation"),
        );
  final StatefulNavigationShell navigationShell;
  final bool hideNavBar;
  final String? appBarTitle;
  final List<Widget>? actions;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: appBarTitle != null
          ? AppBar(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              title: Text(
                appBarTitle!,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 17),
              ),
              actions: actions,
            )
          : null,
      resizeToAvoidBottomInset: false,
      body: navigationShell,
      floatingActionButton:
          hideNavBar || context.watch<HideNavBar>().isNavBarHidden
              ? null
              : ChefFab(
                  iconAsset: 'assets/icon/chef_hat.svg', // le pictogramme blanc
                  onPressed: () {
                    // ton action existante
                    _showAiActionRecipeBottomSheet(context);
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Consumer<HideNavBar>(
        builder: (context, hideNavBar, child) {
          return (hideNavBar.isNavBarHidden ||
                  MediaQuery.of(context).viewInsets.bottom != 0 ||
                  context.watch<HideNavBar>().isNavBarHidden)
              ? SizedBox.shrink()
              : FancyBottomBar(
                  items: const [
                    BarItemData('assets/images/homeInactifIcon.svg'),
                    BarItemData('assets/images/favorite_outlined.svg'),
                    BarItemData('assets/images/list_add.svg'),
                    BarItemData('assets/images/profilInactifIcon.svg'),
                  ],
                  currentIndex: navigationShell.currentIndex,
                  onTap: (i) => _goBranch(i),
                );
        },
      ),
    );
  }
}

final modalBottomSheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  ),
);

void _showAiActionRecipeBottomSheet(BuildContext context) =>
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => _AiGenRecipeBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: modalBottomSheetShape,
    );

class _AiGenRecipeBottomSheet extends StatefulWidget {
  const _AiGenRecipeBottomSheet();

  @override
  State<_AiGenRecipeBottomSheet> createState() =>
      _AiGenRecipeBottomSheetState();
}

class _AiGenRecipeBottomSheetState extends State<_AiGenRecipeBottomSheet> {
  File? _ingredientsImage;

  void _takeCameraPicture() async {
    final ImagePicker picker = ImagePicker();
    // change to ImageSource.camera
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (photo != null) {
      setState(() {
        _ingredientsImage = File(photo.path);
      });
    }
  }

  void _takeLivePicture() async {
    final ImagePicker picker = ImagePicker();
    // change to ImageSource.camera
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (photo != null) {
      setState(() {
        _ingredientsImage = File(photo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appText = di<TranslationController>().currentLanguage;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(5),
            Center(
              child:
                  SvgPicture.asset('assets/images/rectangleSeparationBar.svg'),
            ),
            const Gap(7),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _ingredientsImage != null
                      ? appText.generateRecipeWithGroceriePhoto
                      : appText.generateRecipe,
                  style: TextStyle(
                    fontFamily: poppinsFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: SvgPicture.asset(
                    'assets/images/carbon_close-outline.svg',
                  ),
                ),
              ],
            ),
            const Gap(32),
            Visibility(
              visible: _ingredientsImage == null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionBtn(
                    'assets/images/grocery_icon.svg',
                    appText.generateRecipeWithGroceriePhoto,
                    onTap: () {
                      _takeCameraPicture();
                    },
                  ),
                  const Gap(12),
                  _ActionBtn(
                    'assets/images/grocery_icon.svg',
                    appText.generateRecipeWithLiveGroceriePhoto,
                    onTap: () {
                      _takeLivePicture();
                    },
                  ),
                  const Gap(12),
                  _ActionBtn(
                    'assets/images/groceryList.svg',
                    appText.generateRecipeWithGrocerieList,
                    onTap: () {
                      context.push(
                          '/display-receipes-based-on-ingredient-user-preference');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            if (_ingredientsImage != null)
              Center(
                child: _GenRecipeFromIngredientPicture(_ingredientsImage!),
              ),
            const Gap(50),
          ],
        ),
      ),
    );
  }
}

class RecipeIdeasNavigation implements IRecipeIdeasNavigation {
  RecipeIdeasNavigation(
    this.context,
    this.analyticsRepository,
  );

  @override
  void goToRecipeIdeas(List<UserReceipeV2> recipes) {
    analyticsRepository.logEvent(RecipesGeneratedWithIngredientPictureEvent());
    context.push('/receipe-idea-with-ingredient-photo', extra: {
      'recipes': recipes,
    });
    Navigator.of(context).pop();
  }

  final BuildContext context;
  final IAnalyticsRepository analyticsRepository;
}

class _GenRecipeFromIngredientPicture extends StatelessWidget {
  const _GenRecipeFromIngredientPicture(this.file);

  final File file;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Color(0xffFFAD30),
            ),
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Gap(30),
        BlocProvider(
          lazy: false,
          create: (context) => GenerateRecipeWithIngredientPhotoController(
            RecipeIdeasNavigation(
              context,
              di<IAnalyticsRepository>(),
            ),
            di<IUserReceipeRepositoryV2>(),
            di<IAuthUserService>(),
            file,
          ),
          child: CustomCircularLoader(
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
    this.icon,
    this.title, {
    this.onTap,
  });

  final String icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 8,
          right: 19,
          bottom: 8,
          left: 19,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xffD9D9D9),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
            ),
            const Gap(10),
            Text(
              title,
              style: TextStyle(
                fontFamily: poppinsFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xff333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
