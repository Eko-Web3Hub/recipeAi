import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomProgress extends StatefulWidget {
  final Color? color;

  const CustomProgress({super.key, this.color = Colors.white});

  @override
  State<CustomProgress> createState() => _CustomProgressState();
}

class _CustomProgressState extends State<CustomProgress> {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoActivityIndicator(
            color: widget.color,
          )
        : SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              color: widget.color,
              strokeWidth: 1.5,
            ),
          );
  }
}
