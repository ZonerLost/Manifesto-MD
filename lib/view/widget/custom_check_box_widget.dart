import 'package:manifesto_md/constants/app_colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomCheckBox extends StatelessWidget {
  CustomCheckBox({
    Key? key,
    required this.isActive,
    required this.onTap,
    this.radius,
    this.unSelectedColor,
    this.borderWidth,
  }) : super(key: key);

  final bool isActive;
  final VoidCallback onTap;
  final Color? unSelectedColor;
  double? radius;
  double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 230),
        curve: Curves.easeInOut,
        height: 18,
        width: 18,
        decoration: BoxDecoration(
          border: Border.all(width: borderWidth ?? 2.0, color: kSecondaryColor),
          color: isActive ? kSecondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(radius ?? 2),
        ),
        child:
            !isActive
                ? SizedBox()
                : Icon(Icons.check, size: 12, color: kPrimaryColor),
      ),
    );
  }
}

class CustomRadio extends StatelessWidget {
  CustomRadio({
    Key? key,
    required this.isActive,
    required this.onTap,
    this.unSelectedColor,
  }) : super(key: key);

  final bool isActive;
  final VoidCallback onTap;
  final Color? unSelectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 230),
        curve: Curves.easeInOut,
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: isActive ? kSecondaryColor : kBorderColor,
          ),
          color: isActive ? kPrimaryColor : kSecondaryColor,
          shape: BoxShape.circle,
        ),
        child:
            !isActive
                ? SizedBox()
                : Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      shape: BoxShape.circle,
                    ),
                    height: 11,
                    width: 10,
                  ),
                ),
      ),
    );
  }
}
