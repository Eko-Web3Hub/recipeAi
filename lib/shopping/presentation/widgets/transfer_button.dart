import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class TransferButton extends StatelessWidget {
  const TransferButton({
    super.key,
    required this.checkedCount,
    required this.allChecked,
    required this.onTransfer,
    this.isStoreMode = false,
  });

  final int checkedCount;
  final bool allChecked;
  final VoidCallback onTransfer;
  final bool isStoreMode;

  @override
  Widget build(BuildContext context) {
    if (checkedCount == 0) return const SizedBox.shrink();

    final fontSize = isStoreMode ? 16.0 : 15.0;
    final verticalPadding = isStoreMode ? 18.0 : 14.0;

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalScreenPadding,
        right: horizontalScreenPadding,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: GestureDetector(
        onTap: onTransfer,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          decoration: BoxDecoration(
            color: neutralGrey2ColorNight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              allChecked
                  ? 'Terminer - tout transferer'
                  : 'Transferer vers Inventaire',
              style: TextStyle(
                fontFamily: poppinsFontFamily,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
