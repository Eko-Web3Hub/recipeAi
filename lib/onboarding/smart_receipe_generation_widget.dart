import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/utils/colors.dart';

const _ingredientsOne = [
  _Ingredient(
    icon: '',
    ingredient: 'Avocado',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Tomatoes',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Chicken',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Pepper',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Onions',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Garlic',
  ),
];

const _ingredientsTwo = [
  _Ingredient(
    icon: '',
    ingredient: 'Potatoes',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Pasta',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Olive oil',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Cheese',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Basil',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Parsley',
  ),
];

const _ingredientsThree = [
  _Ingredient(
    icon: '',
    ingredient: 'Salt',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Pepper',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Sugar',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Flour',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Milk',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Eggs',
  ),
];

class SmartReceipeGenerationWidget extends StatelessWidget {
  const SmartReceipeGenerationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(41),
        _IngredientList(
          _ingredientsOne,
          (index) => index % 2 == 0,
          70,
        ),
        const Gap(14),
        _IngredientList(_ingredientsTwo, (index) => false, 30),
        const Gap(14),
        _IngredientList(_ingredientsThree, (index) => index % 2 == 0, 5),
      ],
    );
  }
}

class _IngredientList extends StatefulWidget {
  const _IngredientList(
    this.ingredients,
    this.buildCondition,
    this.initialJumpValue,
  );

  final List<_Ingredient> ingredients;
  final bool Function(int index) buildCondition;
  final double initialJumpValue;

  @override
  State<_IngredientList> createState() => __IngredientListState();
}

class __IngredientListState extends State<_IngredientList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Inside the post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(widget.initialJumpValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          final ingredient =
              widget.ingredients[index % widget.ingredients.length];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _IngredientDisplay(
              icon: ingredient.icon,
              ingredient: ingredient.ingredient,
              isActive: widget.buildCondition(index),
            ),
          );
        },
        itemCount: widget.ingredients.length * 6,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class _IngredientDisplay extends StatelessWidget {
  const _IngredientDisplay({
    required this.icon,
    required this.ingredient,
    this.isActive = false,
  });

  final String icon;
  final String ingredient;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        color: !isActive ? const Color(0xffD9D9D9) : orangeVariantColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          ingredient,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 24 / 16,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _Ingredient extends Equatable {
  const _Ingredient({
    required this.icon,
    required this.ingredient,
  });

  final String icon;
  final String ingredient;

  @override
  List<Object?> get props => [
        icon,
        ingredient,
      ];
}
