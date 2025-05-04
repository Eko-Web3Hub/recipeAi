import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/%20inventory/presentation/inventory_screen.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';
import 'package:recipe_ai/auth/presentation/login_view.dart';
import 'package:recipe_ai/auth/presentation/register/register_view.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/account_screen.dart';
import 'package:recipe_ai/home/presentation/change_email_screen.dart';
import 'package:recipe_ai/home/presentation/change_password_screen.dart';
import 'package:recipe_ai/home/presentation/change_username.dart';
import 'package:recipe_ai/home/presentation/historic/historic_screen.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/profile/update_user_preference_screen.dart';
import 'package:recipe_ai/home/presentation/profile_screen.dart';
import 'package:recipe_ai/home/presentation/recipes_idea_with_ingredient_photo_screen.dart';
import 'package:recipe_ai/kitchen/presentation/add_kitchen_inventory_screen.dart';
import 'package:recipe_ai/kitchen/presentation/display_receipes_based_on_ingredient_user_preference.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/nav/scaffold_with_nested_navigation.dart';
import 'package:recipe_ai/nav/splash_screen.dart';
import 'package:recipe_ai/onboarding/presentation/onboarding_view.dart';
import 'package:recipe_ai/onboarding/presentation/start_screen.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_view.dart';
import 'package:recipe_ai/receipt_ticket_scan/presentation/receipt_ticket_scan_result_screen.dart';
import 'package:recipe_ai/saved_receipe/presentation/saved_receipe_screen.dart';
import 'package:recipe_ai/user_account/presentation/reset_password_screen.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preferences_view.dart';
import 'package:recipe_ai/utils/constant.dart';

FutureOr<String?> _guardAuth(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthNavigationController>().state;

  switch (authState) {
    case AuthNavigationState.loading:
      return '/';
    case AuthNavigationState.loggedIn:
      return null;
    case AuthNavigationState.loggedOutButHasSeenTheOnboarding:
      return '/onboarding/start';
    default:
      return '/onboarding';
  }
}

// FutureOr<String?> _guardOnboarding(
//     BuildContext context, GoRouterState state) async {
//   final onboardingState = context.read<OnboardingController>().state;

//   if (onboardingState is OnboardingCompleted) {
//     return '/onboarding/start';
//   }
//   return null;
// }

GoRouter createRouter() => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        // Add your routes here
        GoRoute(
          name: 'SplashScreen',
          path: '/',
          builder: (context, state) => const SplashScreen(),
          redirect: (BuildContext context, _) {
            final authState = context.read<AuthNavigationController>().state;
            if (authState == AuthNavigationState.loading) {
              return null;
            }

            switch (authState) {
              case AuthNavigationState.loggedIn:
                return '/home';
              case AuthNavigationState.loggedOutButHasSeenTheOnboarding:
                return '/onboarding/start';
              default:
                return '/onboarding';
            }
          },
        ),

        GoRoute(
          name: 'OnBoarding',
          path: '/onboarding',
          //  redirect: _guardOnboarding,
          builder: (context, state) => const OnboardingView(),
          routes: <RouteBase>[
            GoRoute(
              name: 'start',
              path: 'start',
              builder: (context, state) => const StartScreen(),
            ),
          ],
        ),
        GoRoute(
          name: 'Login',
          path: '/login',
          builder: (BuildContext context, _) => const LoginView(),
          routes: <RouteBase>[
            GoRoute(
              name: 'ResetPasswordScreen',
              path: 'reset-password',
              builder: (context, state) => const ResetPasswordScreen(),
            ),
          ],
        ),
        GoRoute(
          name: 'Register',
          path: '/register',
          builder: (context, state) => const RegisterView(),
        ),
        GoRoute(
          name: 'UserPreferences',
          path: '/user-preferences',
          builder: (context, state) => const UserPreferencesView(),
        ),
        GoRoute(
          name: 'ReceipeIdeaWithIngredientPhotoScreen',
          path: '/receipe-idea-with-ingredient-photo',
          builder: (context, state) {
            final recipes = (state.extra! as Map<String, dynamic>)['recipes']
                as List<UserReceipeV2>;

            return RecipesIdeaWithIngredientPhotoScreen(
              recipes: recipes,
            );
          },
        ),
        GoRoute(
          name: 'DisplayReceipesBasedOnIngredientUserPreferenceScreen',
          path: '/display-receipes-based-on-ingredient-user-preference',
          redirect: _guardAuth,
          builder: (context, state) =>
              const DisplayReceipesBasedOnIngredientUserPreferenceScreen(),
        ),
        GoRoute(
          name: 'RecipeDetailss',
          path: '/recipe-details',
          redirect: _guardAuth,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final receipeId = extra['receipeId'] as EntityId?;
            final receipe = extra['receipe'] as UserReceipeV2?;

            return ReceipeDetailsView(
              receipeId: receipeId,
              receipe: receipe,
              appLanguage: null,
              userSharingUid: null,
            );
          },
        ),

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ScaffoldWithNestedNavigation(
            appBarTitle: genAppBarTitle(
              state.fullPath,
              AppLocalizations.of(context)!,
            ),
            navigationShell: navigationShell,
            hideNavBar: hideNavBar(state.fullPath),
          ),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  name: 'Home',
                  path: '/home',
                  redirect: _guardAuth,
                  routes: <RouteBase>[
                    GoRoute(
                      name: 'HistoricScreen',
                      path: '/historic',
                      redirect: _guardAuth,
                      builder: (context, state) => HistoricScreen(),
                    ),
                    GoRoute(
                      name: 'RecipeDetailsWithReceipeId',
                      path:
                          'recipe-details/:language/:userSharingUid/:receipeId',
                      redirect: _guardAuth,
                      builder: (context, state) {
                        return ReceipeDetailsView(
                          appLanguage: appLanguageFromString(
                              state.pathParameters['language']!),
                          receipeId:
                              EntityId(state.pathParameters['receipeId']!),
                          receipe: null,
                          userSharingUid: EntityId(
                            state.pathParameters['userSharingUid']!,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      name: 'RecipeDetails',
                      path: 'recipe-details',
                      redirect: _guardAuth,
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        final receipeId = extra['receipeId'] as EntityId?;
                        final receipe = extra['receipe'] as UserReceipeV2?;

                        return ReceipeDetailsView(
                          appLanguage: null,
                          receipeId: receipeId,
                          receipe: receipe,
                          userSharingUid: null,
                        );
                      },
                    ),
                    GoRoute(
                      name: 'KitchenInventory',
                      path: '/kitchen-inventory',
                      redirect: _guardAuth,
                      builder: (context, state) =>
                          const KitchenInventoryScreen(),
                      routes: <RouteBase>[
                        GoRoute(
                          name: 'AddKitchenInventory',
                          path: 'add-kitchen-inventory',
                          redirect: _guardAuth,
                          builder: (context, state) =>
                              const AddKitchenInventoryScreen(),
                        ),
                        GoRoute(
                          name: 'ReceiptTicketScanResultScreen',
                          path: 'receipt-ticket-scan-result',
                          redirect: _guardAuth,
                          builder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            final ingredients =
                                extra['ingredients'] as List<Ingredient>;

                            return ReceiptTicketScanResultScreen(
                              ingredients: ingredients,
                            );
                          },
                        ),
                        GoRoute(
                          name: 'ReceipeTicketScanScreen',
                          path: 'receipt-ticket-scan',
                          redirect: _guardAuth,
                          builder: (context, state) =>
                              const ReceipeTicketScanScreen(),
                        ),
                      ],
                    ),
                  ],
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  name: 'SaveRecipesScreen',
                  path: '/save-recipes',
                  redirect: _guardAuth,
                  builder: (context, state) => const SavedReceipeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  name: 'InventoryScreen',
                  path: '/inventory-screen',
                  redirect: _guardAuth,
                  builder: (context, state) => InventoryScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  name: 'ProfilScreen',
                  path: '/profil-screen',
                  redirect: _guardAuth,
                  builder: (context, state) => const ProfileScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      name: 'MyAccountScreen',
                      path: 'my-account',
                      redirect: _guardAuth,
                      builder: (context, state) => const AccountScreen(),
                    ),
                    GoRoute(
                      name: 'UpdateUserPreference',
                      path: 'update-user-preference',
                      redirect: _guardAuth,
                      builder: (context, state) =>
                          const UpdateUserPreferenceScreen(),
                    ),
                    GoRoute(
                      name: 'ChangeUsernameScreen',
                      path: 'change-username',
                      redirect: _guardAuth,
                      builder: (context, state) => const ChangeUsername(),
                    ),
                    GoRoute(
                      name: 'ChangeEmailScreen',
                      path: 'change-email',
                      redirect: _guardAuth,
                      builder: (context, state) => const ChangeEmailScreen(),
                    ),
                    GoRoute(
                      name: 'ChangePasswordScreen',
                      path: 'change-password',
                      redirect: _guardAuth,
                      builder: (context, state) => const ChangePasswordScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

String? genAppBarTitle(String? path, AppLocalizations appTexts) {
  log('genAppBarTitle: $path');
  switch (path) {
    case '/save-recipes':
      return appTexts.favorite;
    case '/notification-screen':
      return 'Notifications';
    case '/profil-screen':
      return 'Profile';
    default:
      return null;
  }
}

bool hideNavBar(String? path) {
  switch (path) {
    case '/profil-screen/update-user-preference':
    case '/profil-screen/change-username':
    case '/profil-screen/change-email':
      return true;
    default:
      return false;
  }
}
