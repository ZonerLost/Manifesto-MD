import 'package:flutter/cupertino.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String icon;
  final bool value;
  final double? mBottom;
  final Function(bool)? onChanged;

  const CustomSwitchTile({
    required this.title,
    required this.icon,
    required this.value,
    this.onChanged,
    this.mBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: mBottom ?? 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        border: Border.all(color: kBorderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(icon, height: 20),
          Expanded(
            child: MyText(
              paddingLeft: 10,
              text: title,
              weight: FontWeight.w500,
              size: 12,
            ),
          ),
          SizedBox(
            height: 25,
            child: Transform.scale(
              scale: 0.62,
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 25 / 0.62,
                width: 25 / 0.62,
                child: CupertinoSwitch(
                  activeTrackColor: kSecondaryColor,
                  value: value,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
