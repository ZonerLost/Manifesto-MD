import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomDropDown extends StatelessWidget {
  CustomDropDown({
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.bgColor,
    this.marginBottom,
    this.width,
    this.labelText,
    this.hintColor,
    this.radius,
    this.border,
    this.height,
    this.labelPrefix,
    this.labelSuffix,
    this.labelSize,
    this.onLabelSuffixTap,
  });

  final List<dynamic>? items;
  final String selectedValue;
  final ValueChanged<dynamic>? onChanged;
  final String hint;
  final String? labelText;
  final String? labelPrefix;
  final String? labelSuffix;
  final double? radius;
  final double? border;
  final double? labelSize;
  final VoidCallback? onLabelSuffixTap;
  final Color? bgColor;
  final Color? hintColor;
  final double? marginBottom, width, height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom ?? 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (labelText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  if (labelPrefix != null)
                    Image.asset(labelPrefix ?? '', height: 24),
                  Expanded(
                    child: MyText(
                      paddingLeft: labelPrefix != null ? 8 : 0,
                      text: labelText ?? '',
                      size: labelSize ?? 12,
                      color: kTertiaryColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                  if (labelSuffix != null)
                    GestureDetector(
                      onTap: onLabelSuffixTap,
                      child: Image.asset(labelSuffix ?? '', height: 20),
                    ),
                ],
              ),
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              items:
                  items!
                      .map(
                        (item) => DropdownMenuItem<dynamic>(
                          value: item,
                          child: MyText(
                            text: item,
                            size: 13,
                            weight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
              value: selectedValue,
              onChanged: onChanged,
              iconStyleData: IconStyleData(icon: SizedBox()),
              isDense: true,
              isExpanded: false,
              customButton: Container(
                height: height ?? 48,
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: bgColor ?? kFillColor,
                  border: Border.all(width: border ?? 1, color: kBorderColor),
                  borderRadius: BorderRadius.circular(radius ?? 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MyText(
                        text: selectedValue == hint ? hint : selectedValue,
                        size: 14,
                        weight: FontWeight.w600,
                        color:
                            selectedValue == hint ? kHintColor : kTertiaryColor,
                      ),
                    ),
                    Image.asset(Assets.imagesDropdown, height: 16),
                  ],
                ),
              ),
              menuItemStyleData: MenuItemStyleData(height: 30),
              dropdownStyleData: DropdownStyleData(
                elevation: 3,
                maxHeight: 300,
                offset: Offset(0, -5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
