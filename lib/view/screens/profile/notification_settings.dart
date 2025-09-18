import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_switch_tile_widget.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Notification Settings'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            CustomSwitchTile(
              value: true,
              title: 'Content Updates',
              icon: Assets.imagesContentUpdates,
              onChanged: (v) {},
            ),
            CustomSwitchTile(
              title: 'Chat Messages',
              icon: Assets.imagesPrivateMessages,
              onChanged: (v) {},
              value: false,
            ),
            CustomSwitchTile(
              title: 'General Medical News & Alerts',
              icon: Assets.imagesMedicalAlerts,
              onChanged: (v) {},
              value: false,
            ),
          ],
        ),
      ),
    );
  }
}
