import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalScreenPadding,
          ),
          child: Column(
            children: [
              Gap(20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeadLeftSection(),
                  _HeadRightSection(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeadLeftSection extends StatelessWidget {
  const _HeadLeftSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _UserTitleWidget(),
        const Gap(5.0),
        Text(
          AppText.letCreateMealToday,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _UserTitleWidget extends StatelessWidget {
  const _UserTitleWidget();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserPersonnalInfo?>(
      stream: di<IUserPersonnalInfoService>().watch(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            '${AppText.hello} ${capitalizeFirtLetter(snapshot.data!.name)}',
            style: Theme.of(context).textTheme.displayLarge,
          );
        }

        return Text(
          '${AppText.hello} !',
          style: Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

class _HeadRightSection extends StatelessWidget {
  const _HeadRightSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(
          12.0,
        ),
      ),
    );
  }
}
