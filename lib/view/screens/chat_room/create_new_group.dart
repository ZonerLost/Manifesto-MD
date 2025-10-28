import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/create_group_controller.dart';
import 'package:manifesto_md/view/screens/chat_room/add_group_members.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_switch_tile_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class CreateNewGroup extends StatelessWidget {
  CreateNewGroup({super.key});

  final CreateGroupController createNewGroup = Get.find();

  final groupName = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 15),
          child: GestureDetector(
            onTap: () {
              Get.to(() => AddGroupMembers());
            },
            child: Image.asset(Assets.imagesDone, height: 48),
          ),
        ),
        appBar: simpleAppBar(
          title: 'New Group',
          actions: [
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    _GroupPermissions(),
                    isScrollControlled: true,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6.54),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kSecondaryColor,
                  ),
                  child: MyText(
                    text: 'Group Permission',
                    size: 12,
                    weight: FontWeight.w600,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: kBorderColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: MyText(
                          text: 'Group Icon',
                          size: 10,
                          weight: FontWeight.w600,
                          color: kGreyColor,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        Assets.imagesChangeProfileImage,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            MyTextField(
              labelPrefix: Assets.imagesGroupName,
              controller: groupName,
              onChanged: (value) {
                createNewGroup.name.value = value;
              },
              labelText: 'Group Name',
              hintText: 'abc 123',
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupPermissions extends StatelessWidget {
  final List<String> _options = ['New Group', 'Settings'];
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.DEFAULT,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
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
            text: 'Group Permission',
            size: 18,
            weight: FontWeight.w700,
            paddingBottom: 16,
          ),
          CustomSwitchTile(
            mBottom: 8,
            title: 'Edit Group Settings',
            icon: Assets.imagesEditGroupSettings,
            onChanged: (v) {},
            value: true,
          ),
          CustomSwitchTile(
            mBottom: 8,
            value: true,
            title: 'Send New Message',
            icon: Assets.imagesPrivateMessages,
            onChanged: (v) {},
          ),
          CustomSwitchTile(
            mBottom: 8,
            title: 'Add Other Members',
            icon: Assets.imagesAddOtherMember,
            onChanged: (v) {},
            value: true,
          ),
          CustomSwitchTile(
            mBottom: 24,
            value: false,
            title: 'Invite VIA Group Link',
            icon: Assets.imagesInviteViaLink,
            onChanged: (v) {},
          ),
          MyButton(
            buttonText: 'Done',
            onTap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}