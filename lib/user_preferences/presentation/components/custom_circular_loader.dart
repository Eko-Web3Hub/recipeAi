import 'package:flutter/material.dart';

class CustomCircularLoader extends StatelessWidget {
  const CustomCircularLoader({
    super.key,
    this.size = 50.0,
    this.value,
  });

  final double size;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator.adaptive(
        value: value,
        valueColor: AlwaysStoppedAnimation<Color?>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
