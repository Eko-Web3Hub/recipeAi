import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class AddItemField extends StatefulWidget {
  const AddItemField({
    super.key,
    required this.onAdd,
  });

  final ValueChanged<String> onAdd;

  @override
  State<AddItemField> createState() => _AddItemFieldState();
}

class _AddItemFieldState extends State<AddItemField> {
  final _controller = TextEditingController();

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onAdd(_controller.text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
      child: Row(
        children: [
          const Icon(Icons.add, color: greenPrimaryColor, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: greyVariantColor),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _submit(),
                style: TextStyle(
                  fontFamily: poppinsFontFamily,
                  fontSize: 14,
                  color: neutralBlackColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Ajouter un article',
                  hintStyle: TextStyle(
                    fontFamily: poppinsFontFamily,
                    fontSize: 14,
                    color: neutralGreyColor,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: newNeutralBlackColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ajouter',
                style: TextStyle(
                  fontFamily: poppinsFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
