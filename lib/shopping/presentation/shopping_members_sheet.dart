import 'package:flutter/material.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/presentation/widget/primary_action_button.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/presentation/shopping_widgets.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

sealed class ShoppingMembersAction {
  const ShoppingMembersAction();
}

class ShoppingMembersInvite extends ShoppingMembersAction {
  const ShoppingMembersInvite();
}

class ShoppingMembersLeave extends ShoppingMembersAction {
  const ShoppingMembersLeave();
}

class ShoppingMembersRemove extends ShoppingMembersAction {
  const ShoppingMembersRemove(this.uid, this.name);

  final EntityId uid;
  final String name;
}

/// Opens the members of [list]. The owner can remove the others, the other
/// members can leave; everyone can invite.
Future<ShoppingMembersAction?> showShoppingMembersSheet(
  BuildContext context, {
  required ShoppingList list,
  required EntityId currentUserId,
}) => showModalBottomSheet<ShoppingMembersAction>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: Colors.white,
  barrierColor: const Color(0x6B141C12),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
  ),
  builder: (context) =>
      _ShoppingMembersSheet(list: list, currentUserId: currentUserId),
);

class _ShoppingMembersSheet extends StatelessWidget {
  const _ShoppingMembersSheet({
    required this.list,
    required this.currentUserId,
  });

  final ShoppingList list;
  final EntityId currentUserId;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final isOwner = list.isOwnedBy(currentUserId);
    // The owner first, then the others in their joining order.
    final members = [
      list.ownerId,
      ...list.memberIds.where((uid) => uid != list.ownerId),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 22 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: recipeLoaderInkColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            appTexts.shoppingListMembers,
            style: const TextStyle(
              fontFamily: robotoSlabFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: recipeLoaderInkColor,
            ),
          ),
          Text(
            appTexts.shoppingListMemberCount(members.length),
            style: shoppingMutedStyle(12.5),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final uid in members)
                  _MemberTile(
                    name: list.nameOf(uid),
                    isYou: uid == currentUserId,
                    isOwner: uid == list.ownerId,
                    onRemove: isOwner && uid != currentUserId
                        ? () => Navigator.of(context).pop(
                            ShoppingMembersRemove(
                              uid,
                              list.nameOf(uid) ??
                                  appTexts.shoppingListMemberUnknown,
                            ),
                          )
                        : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryActionButton(
            label: appTexts.shoppingListInvite,
            onTap: () =>
                Navigator.of(context).pop(const ShoppingMembersInvite()),
          ),
          if (!isOwner) ...[
            const SizedBox(height: 6),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(const ShoppingMembersLeave()),
              style: TextButton.styleFrom(foregroundColor: shoppingDangerColor),
              child: Text(
                appTexts.shoppingListLeave,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.name,
    required this.isYou,
    required this.isOwner,
    required this.onRemove,
  });

  final String? name;
  final bool isYou;
  final bool isOwner;

  /// Null when the member cannot be removed by the current user.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final label = name?.isNotEmpty ?? false
        ? name!
        : appTexts.shoppingListMemberUnknown;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ShoppingMemberAvatar(name: name, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isYou ? '$label (${appTexts.shoppingListYou})' : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: recipeLoaderInkColor,
              ),
            ),
          ),
          if (isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: recipeLoaderMintColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                appTexts.shoppingListOwner,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: recipeLoaderGreenColor,
                ),
              ),
            ),
          if (onRemove != null)
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                foregroundColor: shoppingDangerColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: Text(
                appTexts.shoppingListRemoveMember,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
