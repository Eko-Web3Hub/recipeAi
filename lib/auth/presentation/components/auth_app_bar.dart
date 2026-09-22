import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/utils/styles.dart';

/// The transparent app bar shared by the auth screens: a back arrow that
/// navigates to [redirectPath] and a [title].
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({
    super.key,
    required this.title,
    required this.redirectPath,
  });

  final String title;
  final String redirectPath;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(title, style: appBarTextStyle),
      leading: AppBackIcon(
        arrowLeftOnPressed: () => context.go(redirectPath),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
