import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
    ingredient: 'Rice',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Chicken',
  ),
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
    ingredient: 'Onions',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Garlic',
  ),
  _Ingredient(
    icon: '',
    ingredient: 'Parsley',
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
        _IngredientList(),
      ],
    );
  }
}

class _IngredientList extends StatefulWidget {
  const _IngredientList({super.key});

  @override
  State<_IngredientList> createState() => __IngredientListState();
}

class __IngredientListState extends State<_IngredientList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(); // Repeats infinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-_controller.value * screenWidth, 0),
          child: Row(
            children: _ingredientsOne
                .map<Widget>(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ),
                    child: _IngredientDisplay(
                      icon: ingredient.icon,
                      ingredient: ingredient.ingredient,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
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
      decoration: BoxDecoration(
        color: !isActive ? const Color(0xffD9D9D9) : orangeVariantColor,
        borderRadius: BorderRadius.circular(
          50,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            ingredient,
          ),
        ],
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
