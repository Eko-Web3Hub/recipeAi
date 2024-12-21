import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/firebase_options.dart';
import 'package:recipe_ai/nav/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  di.registerModule(AppModule());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthNavigationController(
            di<IAuthUserService>(),
          ),
        ),
      ],
      child: BlocListener<AuthNavigationController, AuthNavigationState>(
        listener: (context, state) {
          log('AuthNavigationState: $state');
          _router.refresh();
        },
        child: MaterialApp.router(
          title: 'Recipe AI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: const Color(0xff129575),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            textTheme: TextTheme(
              displayLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
                height: 30 / 20,
                color: Colors.black,
              ),
              labelSmall: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 11.0,
                height: 16.5 / 11,
                color: const Color(0xffA9A9A9),
              ),
            ),
            useMaterial3: true,
          ),
          routerConfig: _router,
        ),
      ),
    );
  }
}