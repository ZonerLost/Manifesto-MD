import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.subTitle,
    this.child,
  });
  final String title;
  final String subTitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(38),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                child ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MyText(
                      text: title,
                      size: 18,
                      weight: FontWeight.w600,
                      textAlign: TextAlign.center,
                      paddingTop: 20,
                    ),
                    MyText(
                      text: subTitle,
                      color: kQuaternaryColor,
                      textAlign: TextAlign.center,
                      paddingTop: 10,
                      paddingBottom: 20,
                      size: 12,
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}
