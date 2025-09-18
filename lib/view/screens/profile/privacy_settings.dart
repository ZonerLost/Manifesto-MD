import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_switch_tile_widget.dart';

class PrivacySettings extends StatelessWidget {
  const PrivacySettings({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Privacy Settings'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            CustomSwitchTile(
              value: true,
              title: 'Show Online Status in Public Chat Room',
              icon: Assets.imagesShowOnline,
              onChanged: (v) {},
            ),
            CustomSwitchTile(
              title: 'Allow Private Messages',
              icon: Assets.imagesPrivateMessages,
              onChanged: (v) {},
              value: false,
            ),
          ],
        ),
      ),
    );
  }
}
