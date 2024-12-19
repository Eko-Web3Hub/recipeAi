import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';

class KitchenInventoryScreen extends StatelessWidget {
  const KitchenInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        appBar: KitchenInventoryAppBar(),
        body: Column(
          children: [
            Gap(10.0),
            _EmptyKitchenInventoryView(),
          ],
        ),
      ),
    );
  }
}

class KitchenInventoryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const KitchenInventoryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 30,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/arrow-black-left.svg'),
          const Gap(25),
          Text(
            AppText.yourKitchenInventory,
            style: mediumTextStyle,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _EmptyKitchenInventoryView extends StatelessWidget {
  const _EmptyKitchenInventoryView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            AppText.emptyKitchenText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
        const Gap(112),
        Container(
          width: 243,
          height: 371,
          decoration: BoxDecoration(
            color: greyVariantColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Gap(21),
        Text(
          AppText.clickHereToAdd,
          style: smallTextStyle.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Gap(3),
        Text(
          AppText.or,
          style: smallTextStyle,
        ),
        const Gap(3),
        Text(
          AppText.takeYourReceiptPicture,
          style: smallTextStyle.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
