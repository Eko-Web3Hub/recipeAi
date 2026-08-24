import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
      child: Row(
        children: [
         
        
          Expanded(
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              
              style: TextStyle(
                fontFamily: poppinsFontFamily,
                fontSize: 16,
                color: neutralBlackColor,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                fillColor: Colors.white,
                filled: true,
                hintStyle: TextStyle(
                  fontFamily: poppinsFontFamily,
                  fontSize: 16,
                  color: neutralGreyColor,
                ),
                prefixIcon:  Icon(Icons.search, color: newNeutralBlackColor, size: 24),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: greyVariantColor
                  ,width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: neutralGrey4Color,width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: neutralGrey4Color,width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                //isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 8),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.clear();
                          onClear();
                        },
                        child: Icon(Icons.close, color: neutralGreyColor, size: 20),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
