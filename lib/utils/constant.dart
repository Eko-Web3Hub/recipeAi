import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/utils/colors.dart';

const baseApiUrl = 'https://langchain-server-819430206108.europe-west1.run.app';

const horizontalScreenPadding = 30.0;

enum InputType { text, password }

final receipeSample = Receipe(
  name: ' Burger Healthy',
  ingredients: [
    Ingredient(
      name: 'Tomatoes',
      quantity: '3pcs',
      date: DateTime.now(),
    ),
    Ingredient(name: 'Water', quantity: null, date: DateTime.now()),
    Ingredient(name: 'Steak', quantity: null, date: DateTime.now()),
    Ingredient(name: 'Egg', quantity: '10pcs', date: DateTime.now()),
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
