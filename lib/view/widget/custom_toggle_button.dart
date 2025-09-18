import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  const CustomToggleButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String title;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    offset: Offset(0, 5),
                    blurRadius: 15,
                    color: kSecondaryColor.withValues(alpha: .25),
                  ),
                ]
                : [],
        gradient:
            isSelected
                ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffFF774D), Color(0xffFC5A5A)],
                )
                : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.transparent],
                ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 1.0,
          color: isSelected ? Colors.transparent : kBorderColor,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon!.isNotEmpty)
            Image.asset(
              icon!,
              height: 19,
              color: isSelected ? kPrimaryColor : kSecondaryColor,
            ),
          MyText(
            paddingLeft: icon!.isNotEmpty ? 8 : 0,
            paddingRight: icon!.isNotEmpty ? 8 : 0,
            text: title,
            size: 14,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            color: isSelected ? kPrimaryColor : kTertiaryColor,
          ),
        ],
      ),
    );
  }
}
