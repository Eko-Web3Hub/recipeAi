import 'package:flutter/material.dart';

class CustomCircularLoader extends StatelessWidget {
  const CustomCircularLoader({super.key, this.size = 50.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color?>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
