import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class OnboardingModel extends Equatable {
  final String title;
  final Widget child;
  final String description;
  final Color? textColor;
  final String? bgImage;
  final double horizontalPadding;
  final double paddingBetweenTitleAndChild;

  const OnboardingModel({
    required this.title,
    required this.child,
    required this.description,
    this.textColor,
    this.bgImage,
    this.horizontalPadding = 0,
    this.paddingBetweenTitleAndChild = 0,
  });

  @override
  List<Object?> get props => [
        title,
        child,
        description,
        textColor,
        bgImage,
        horizontalPadding,
        paddingBetweenTitleAndChild,
      ];
}
