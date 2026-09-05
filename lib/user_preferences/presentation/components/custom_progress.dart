import 'package:flutter/material.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';

class CustomProgress extends StatelessWidget {
  final Color? color;

  const CustomProgress({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return CustomCircularLoader(size: 30, color: color);
  }
}
