import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';

class KitchenInventoryScreen extends StatelessWidget {
  const KitchenInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: KitchenInventoryAppBar(
          arrowLeftOnPressed: () => context.go('/home'),
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              Gap(10.0),
              _EmptyKitchenInventoryView(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The appBar for every screen in the kitchen inventory section
class KitchenInventoryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const KitchenInventoryAppBar({
    super.key,
    this.arrowLeftOnPressed,
  });

  final VoidCallback? arrowLeftOnPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // InkWell(
          //   onTap: arrowLeftOnPressed,
          //   child: SvgPicture.asset('assets/images/arrow-black-left.svg'),
          // ),
          // const Gap(25),
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

class _EmptyKitchenInventoryView extends StatefulWidget {
  const _EmptyKitchenInventoryView();

  @override
  State<_EmptyKitchenInventoryView> createState() =>
      _EmptyKitchenInventoryViewState();
}

class _EmptyKitchenInventoryViewState
    extends State<_EmptyKitchenInventoryView> {
  File? _receiptPicture;

  void _uploadReceiptPicture() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _receiptPicture = File(result.files.single.path!);
      });
    }
  }

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
        const Gap(116),
        Container(
          width: 243,
          height: 371,
          decoration: BoxDecoration(
            color: greyVariantColor,
            borderRadius: BorderRadius.circular(10),
            image: _receiptPicture != null
                ? DecorationImage(
                    image: FileImage(
                      _receiptPicture!,
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        const Gap(21),
        GestureDetector(
          onTap: () {
            context.push("/add-kitchen-inventory");
          },
          child: Text(
            AppText.clickHereToAdd,
            style: smallTextStyle.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const Gap(3),
        Text(
          AppText.or,
          style: smallTextStyle,
        ),
        const Gap(3),
        GestureDetector(
          onTap: _uploadReceiptPicture,
          child: Text(
            AppText.takeYourReceiptPicture,
            style: smallTextStyle.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const Gap(50),
        // KitchenInventoryActionWidget(
        //   icon: 'assets/images/cameraLogo.svg',
        //   onPressed: _uploadReceiptPicture,
        // ),
      ],
    );
  }
}

class KitchenInventoryActionWidget extends StatelessWidget {
  const KitchenInventoryActionWidget({
    super.key,
    required this.icon,
    this.onPressed,
  });

  final String icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
          ),
        ),
      ),
    );
  }
}
