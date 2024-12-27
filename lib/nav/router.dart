import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';
import 'package:recipe_ai/auth/presentation/login_view.dart';
import 'package:recipe_ai/auth/presentation/register/register_view.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/house_screen.dart';
import 'package:recipe_ai/kitchen/presentation/add_kitchen_inventory_screen.dart';
import 'package:recipe_ai/kitchen/presentation/display_receipes_based_on_ingredient_user_preference.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/nav/scaffold_with_nested_navigation.dart';
import 'package:recipe_ai/nav/splash_screen.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_view.dart';
import 'package:recipe_ai/receipt_ticket_scan/presentation/receipt_ticket_scan_result_screen.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preferences_view.dart';

FutureOr<String?> _guardAuth(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthNavigationController>().state;

  switch (authState) {
    case AuthNavigationState.loading:
      return '/';
    case AuthNavigationState.loggedIn:
      return null;
    case AuthNavigationState.loggedOut:
      return '/login';
  }
}

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

            return authState == AuthNavigationState.loggedIn
                ? '/home'
                : '/login';
          },
        ),
        GoRoute(
          name: 'Login',
          path: '/login',
          builder: (BuildContext context, _) => const LoginView(),
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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ScaffoldWithNestedNavigation(
            navigationShell: navigationShell,
            hideNavBar: false,
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
                      name: 'RecipeDetails',
                      path: 'recipe-details',
                      redirect: _guardAuth,
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        final receipeId = extra['receipeId'] as EntityId?;
                        final receipe = extra['receipe'] as Receipe?;

                        return ReceipeDetailsView(
                          receipeId: receipeId,
                          receipe: receipe,
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
                        GoRoute(
                          name:
                              'DisplayReceipesBasedOnIngredientUserPreferenceScreen',
                          path:
                              'display-receipes-based-on-ingredient-user-preference',
                          redirect: _guardAuth,
                          builder: (context, state) =>
                              const DisplayReceipesBasedOnIngredientUserPreferenceScreen(),
                        ),
                      ],
                    ),
                  ],
                  builder: (context, state) => const HouseScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  name: 'SaveRecipesScreen',
                  path: '/save-recipes',
                  redirect: _guardAuth,
                  builder: (context, state) => const Center(
                    child: Text('Save Recipes'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  name: 'NotificationScreen',
                  path: '/notification-screen',
                  redirect: _guardAuth,
                  builder: (context, state) => const Center(
                    child: Text(
                      'Notification Screen',
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  name: 'ProfilScreen',
                  path: '/profil-screen',
                  redirect: _guardAuth,
                  builder: (context, state) => const Center(
                    child: Text(
                      'Profil Screen',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
