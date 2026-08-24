import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recipe_ai/shopping/presentation/widgets/green_curved_header.dart';

class StoreModeHeader extends StatelessWidget {
  const StoreModeHeader({
    super.key,
    required this.onToggleStoreMode,
  });

  final VoidCallback onToggleStoreMode;

  @override
  Widget build(BuildContext context) {
    return GreenCurvedHeader(
      title: 'Mode Magasin',
      actions: [
        _HeaderIconButton(
          asset: 'system-uicons_share',

          onTap: () {},
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
          asset: 'magazin',
          onTap: onToggleStoreMode,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.asset,
    required this.onTap,
  });

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset('assets/icon/$asset.svg',
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
