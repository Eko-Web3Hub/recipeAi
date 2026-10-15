import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/presentation/widget/primary_action_button.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';

/// "mardi 14 octobre", with the year when it is not the current one.
String formatShoppingDate(DateTime date, String languageCode) {
  final pattern = date.year == DateTime.now().year
      ? 'EEEE d MMMM'
      : 'EEEE d MMMM y';
  final label = DateFormat(pattern, languageCode).format(date);
  return label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);
}

/// Back button, title (and subtitle) and an optional trailing action, at
/// the top of the shopping screens.
class ShoppingHeader extends StatelessWidget {
  const ShoppingHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: appTexts.shoppingListBack,
            // Opened from a link (invitation), the screen can be the first
            // of the stack: back then goes home.
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: recipeLoaderInkColor,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appBarTitleStyle,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: shoppingMutedStyle(12.5),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

TextStyle shoppingMutedStyle(double size) => TextStyle(
  fontFamily: robotoFontFamily,
  fontWeight: FontWeight.w400,
  fontSize: size,
  color: recipeLoaderInkColor.withValues(alpha: 0.55),
);

/// Name and date typed in [ShoppingListSheet].
typedef ShoppingListDetails = ({String name, DateTime date});

/// Opens the sheet to create a list, or to edit [list] when given.
Future<ShoppingListDetails?> showShoppingListSheet(
  BuildContext context, {
  ShoppingList? list,
}) => showModalBottomSheet<ShoppingListDetails>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: Colors.white,
  barrierColor: const Color(0x6B141C12),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
  ),
  builder: (context) => ShoppingListSheet(list: list),
);

class ShoppingListSheet extends StatefulWidget {
  const ShoppingListSheet({super.key, this.list});

  final ShoppingList? list;

  @override
  State<ShoppingListSheet> createState() => _ShoppingListSheetState();
}

class _ShoppingListSheetState extends State<ShoppingListSheet> {
  late final _nameController = TextEditingController(text: widget.list?.name);
  late DateTime _date = widget.list?.date ?? DateUtils.dateOnly(DateTime.now());

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, 12, 31),
      locale: Locale(di<TranslationController>().currentLanguage.localeName),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop((name: name, date: _date));
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: recipeLoaderInkColor.withValues(alpha: 0.18),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom:
            22 +
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
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
            widget.list == null
                ? appTexts.shoppingListNew
                : appTexts.shoppingListEdit,
            style: const TextStyle(
              fontFamily: robotoSlabFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: recipeLoaderInkColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            autofocus: widget.list == null,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) => setState(() {}),
            cursorColor: recipeLoaderGreenColor,
            style: const TextStyle(
              fontFamily: robotoFontFamily,
              fontSize: 14,
              color: recipeLoaderInkColor,
            ),
            decoration: InputDecoration(
              hintText: appTexts.shoppingListNameHint,
              hintStyle: TextStyle(
                fontFamily: robotoFontFamily,
                fontSize: 14,
                color: recipeLoaderInkColor.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: const BorderSide(color: recipeLoaderGreenColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: recipeLoaderCreamColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: recipeLoaderGreenColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        appTexts.shoppingListDateLabel,
                        style: shoppingMutedStyle(13),
                      ),
                    ),
                    Text(
                      formatShoppingDate(_date, appTexts.localeName),
                      style: const TextStyle(
                        fontFamily: robotoFontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                        color: recipeLoaderInkColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryActionButton(
            label: widget.list == null
                ? appTexts.shoppingListCreate
                : appTexts.fridgeSave,
            onTap: _nameController.text.trim().isEmpty ? null : _submit,
          ),
        ],
      ),
    );
  }
}

/// Asks to confirm a destructive action ([actionLabel], in red). Returns
/// true when confirmed.
Future<bool> showShoppingConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String actionLabel,
}) async {
  final appTexts = di<TranslationController>().currentLanguage;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: robotoSlabFontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: recipeLoaderInkColor,
        ),
      ),
      content: Text(body, style: shoppingMutedStyle(14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: recipeLoaderInkColor),
          child: Text(appTexts.shoppingListCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: shoppingDangerColor),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

const shoppingDangerColor = Color(0xFFB5533A);

/// Round avatar of a list member: the initial of [name], or a generic icon.
class ShoppingMemberAvatar extends StatelessWidget {
  const ShoppingMemberAvatar({super.key, required this.name, this.size = 30});

  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name?.trim().characters.firstOrNull?.toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: recipeLoaderGreenColor,
        shape: BoxShape.circle,
        border: Border.all(color: recipeLoaderCreamColor, width: 2),
      ),
      child: initial == null
          ? Icon(Icons.person_rounded, size: size * 0.55, color: Colors.white)
          : Text(
              initial,
              style: TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: size * 0.43,
                color: Colors.white,
              ),
            ),
    );
  }
}

/// Overlapping avatars of [names], the first one on top of the stack.
class ShoppingAvatarStack extends StatelessWidget {
  const ShoppingAvatarStack({super.key, required this.names, this.size = 30});

  final List<String?> names;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, name) in names.indexed)
          Align(
            widthFactor: index == names.length - 1 ? 1 : 0.72,
            child: ShoppingMemberAvatar(name: name, size: size),
          ),
      ],
    );
  }
}
