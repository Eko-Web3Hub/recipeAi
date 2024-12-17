import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';
import 'package:recipe_ai/auth/presentation/login_view.dart';
import 'package:recipe_ai/auth/presentation/register/register_view.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/nav/splash_screen.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_view.dart';
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
        GoRoute(
          name: 'Home',
          path: '/home',
          redirect: _guardAuth,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          name: 'RecipeDetails',
          path: '/recipe-details',
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
      ],
    );
