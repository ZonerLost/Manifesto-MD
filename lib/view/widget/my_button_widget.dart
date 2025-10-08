import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'my_text_widget.dart';

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  MyButton({
    required this.buttonText,
    required this.onTap,
    this.height = 48,
    this.textSize,
    this.weight,
    this.radius,
    this.customChild,
    this.bgColor,
    this.textColor,
    this.isLoading = false,
    this.enabled = true,
    this.disabledBgColor,
    this.disabledTextColor,
  });

  final String buttonText;
  final VoidCallback onTap;
  double? height, textSize, radius;
  FontWeight? weight;
  Widget? customChild;
  Color? bgColor, textColor;
  final bool enabled;
  final bool isLoading;
  Color? disabledBgColor, disabledTextColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveBgColor =
        enabled
            ? (bgColor ?? Color(0xff12C0C0))
            : (disabledBgColor ?? Colors.grey.shade300);
    final Color effectiveTextColor =
        enabled
            ? (textColor ?? kPrimaryColor)
            : (disabledTextColor ?? kPrimaryColor);

    return Opacity(
      opacity: enabled || isLoading ? 1.0 : 0.6,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 16),
          gradient:
              enabled || isLoading
                  ? LinearGradient(
                    colors:
                        bgColor != null
                            ? [bgColor!, bgColor!]
                            : [Color(0xff12C0C0), Color(0xff009CCD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                  : LinearGradient(
                    colors:
                        bgColor != null
                            ? [bgColor!, bgColor!]
                            : [
                              Color(0xff12C0C0).withValues(alpha: 0.35),
                              Color(0xff009CCD).withValues(alpha: 0.35),
                            ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
          color: !enabled || isLoading ? effectiveBgColor : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled || isLoading ? onTap : null,
            splashColor:
                enabled || isLoading
                    ? kPrimaryColor.withValues(alpha: 0.1)
                    : Colors.transparent,
            highlightColor:
                enabled
                    ? kPrimaryColor.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(radius ?? 16),
            child: isLoading ? Center(child: CircularProgressIndicator.adaptive(),) :
                customChild ??
                Center(
                  child: MyText(
                    text: buttonText,
                    size: textSize ?? 15,
                    weight: weight ?? FontWeight.w600,
                    color: effectiveTextColor,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyBorderButton extends StatelessWidget {
  MyBorderButton({
    required this.buttonText,
    required this.onTap,
    this.height = 48,
    this.textSize,
    this.weight,
    this.radius,
    this.customChild,
    this.bgColor,
    this.textColor,
  });

  final String buttonText;
  final VoidCallback onTap;
  double? height, textSize, radius;
  FontWeight? weight;
  Widget? customChild;
  Color? bgColor, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 16),
        border: Border.all(width: 1.0, color: kSecondaryColor),
        color: kBorderColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: kSecondaryColor.withValues(alpha: 0.1),
          highlightColor: kPrimaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(radius ?? 16),
          child:
              customChild ??
              Center(
                child: MyText(
                  text: buttonText,
                  size: textSize ?? 15,
                  weight: weight ?? FontWeight.w600,
                  color: textColor ?? kSecondaryColor,
                ),
              ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyToggleButton extends StatelessWidget {
  MyToggleButton({
    required this.buttonText,
    required this.onTap,
    required this.isSelected,
  });

  final String buttonText;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: isSelected ? kSecondaryColor : Colors.transparent,
        border: Border.all(width: 1.0, color: kSecondaryColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor:
              isSelected
                  ? kPrimaryColor.withValues(alpha: 0.1)
                  : kSecondaryColor.withValues(alpha: 0.1),
          highlightColor:
              isSelected
                  ? kPrimaryColor.withValues(alpha: 0.1)
                  : kSecondaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(50),
          child: Center(
            child: MyText(
              text: buttonText,
              size: 14,
              lineHeight: null,
              weight: FontWeight.w600,
              color: isSelected ? kPrimaryColor : kSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
