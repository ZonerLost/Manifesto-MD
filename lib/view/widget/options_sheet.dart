import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/chat_room/group_details.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class OptionsSheet extends StatelessWidget {
  const OptionsSheet({
    super.key,
    required this.groupId,
    this.groupName,
  });

  final String groupId;
  final String? groupName;

  static const List<String> _options = [
    'Group Info',
    'Group Media',
    'Search',
    'Report',
    'Exit Group',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.DEFAULT,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(Assets.imagesMainBg),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'Options',
            size: 18,
            weight: FontWeight.w700,
            paddingBottom: 16,
          ),
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < _options.length; i++)
                GestureDetector(
                  onTap: () {
                    switch (i) {
                      case 0: // Group Info
                        Get.back(); // close the bottom sheet first
                        Get.to(() => GroupDetails(
                          groupId: groupId,
                          fallbackGroupName: groupName,
                        ));
                        break;
                      default:
                        Get.back();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MyText(
                      text: _options[i],
                      size: 14,
                      color: i == _options.length - 1 ? kRedColor : kTertiaryColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
