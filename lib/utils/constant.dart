import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations_fr.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

const baseApiUrl = 'https://langchain-server-819430206108.europe-west1.run.app';

final appLanguages = <AppLanguage, AppLocalizations>{
  AppLanguage.fr: AppLocalizationsFr(),
  AppLanguage.en: AppLocalizationsEn(),
};

const horizontalScreenPadding = 30.0;

enum InputType { text, password }

final receipeSample = Receipe(
  name: 'Burger Healthy',
  ingredients: [
    Ingredient(
      id: const EntityId('1'),
      name: 'Tomatoes',
      quantity: '3pcs',
      date: DateTime.now(),
    ),
    Ingredient(
      name: 'Water',
      quantity: null,
      date: DateTime.now(),
      id: const EntityId('2'),
    ),
    Ingredient(
      name: 'Steak',
      quantity: null,
      date: DateTime.now(),
      id: const EntityId('3'),
    ),
    Ingredient(
      name: 'Egg',
      quantity: '10pcs',
      date: DateTime.now(),
      id: const EntityId('4'),
    ),
  ],
  steps: const [
    ReceipeStep(
      description: 'Mash black beans in a large bowl for 10min',
      duration: '10:00',
    ),
    ReceipeStep(
      description: 'Mash black beans in a large bowl for 15min',
      duration: '15:00',
    ),
    ReceipeStep(
      description: 'Mash black beans in a large bowl for 5min',
      duration: '5:00',
    ),
    ReceipeStep(
      description: 'Mash black beans in a large bowl and mixture with water',
      duration: null,
    ),
  ],
  imageUrl: 'https://images.unsplash.com/photo-1612838320302-4b3b3b3b3b3b',
  averageTime: '',
  totalCalories: '',
);

final normalTextStyle = GoogleFonts.poppins(
  fontWeight: FontWeight.w600,
  fontSize: 16,
  height: 24 / 16,
  color: blackVariantColor,
);

final mediumTextStyle = GoogleFonts.poppins(
  fontWeight: FontWeight.w600,
  fontSize: 18,
  height: 27 / 18,
  color: blackVariantColor,
);

final dioOption = BaseOptions(
  headers: {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  },
);

const localizationsDelegate = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const supportedLocales = [
  Locale('en'),
  Locale('fr'),
];

enum AppLanguage { en, fr }

AppLanguage appLanguageFromString(String language) {
  switch (language) {
    case 'en':
      return AppLanguage.en;
    case 'fr':
      return AppLanguage.fr;
    default:
      throw Exception('Language not supported yet');
  }
}

enum AuthError { userNotFound, somethingWentWrong }

const logoPath = 'assets/images/newLogo.png';
