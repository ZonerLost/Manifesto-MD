import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/view/screens/chat_room/add_group_members.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class GroupDetails extends StatelessWidget {
  const GroupDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: '',
          actions: [
            Center(
              child: GestureDetector(
                onTap: () {
                  // Get.bottomSheet(
                  //   _GroupPermissions(),
                  //   isScrollControlled: true,
                  // );
                },
                child: Image.asset(Assets.imagesMore, height: 24),
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
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBorderColor,
              ),
              child: Center(
                child: MyText(
                  text: 'IM',

                  // chatGroups[selectedIndexes.elementAt(index)]['name'] !=
                  //         null
                  //     ? chatGroups[selectedIndexes.elementAt(
                  //           index,
                  //         )]['name']!
                  //         .trim()
                  //         .split(' ')
                  //         .where((e) => e.isNotEmpty)
                  //         .map((e) => e.substring(0, 1))
                  //         .take(2)
                  //         .join()
                  //         .toUpperCase()
                  //     : '',
                  size: 24,
                  weight: FontWeight.w600,
                ),
              ),
            ),

            MyText(
              paddingTop: 12,
              text: 'Internal Medicine',
              size: 20,
              weight: FontWeight.w600,
              textAlign: TextAlign.center,
              paddingBottom: 6,
            ),
            MyText(
              text: 'Group: 06 Members',
              size: 16,
              paddingBottom: 16,
              weight: FontWeight.w500,
              color: kSecondaryColor,
              textAlign: TextAlign.center,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => AddGroupMembers());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      colors: [Color(0xff12C0C0), Color(0xff009CCD)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: kPrimaryColor),
                      MyText(
                        text: 'Add Members',
                        size: 12,
                        weight: FontWeight.w500,
                        color: kPrimaryColor,
                        paddingLeft: 4,
                        paddingRight: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: kBorderColor,
              margin: EdgeInsets.symmetric(vertical: 16),
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(
                    text: 'Add Group Discussion',
                    size: 14,
                    color: kSecondaryColor,
                    weight: FontWeight.w500,
                    paddingBottom: 6,
                  ),
                  MyText(
                    text: 'Created By John Smith- 27 July, 2025',
                    size: 14,
                    color: kGreyColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(
                    paddingLeft: 12,
                    text: 'Media, Links and Docs',
                    size: 14,
                    color: kGreyColor,
                    paddingBottom: 6,
                  ),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: 10,
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        return CommonImageView(
                          height: 60,
                          width: 60,
                          radius: 16,
                          url: dummyImg,
                          fit: BoxFit.cover,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(width: 8);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GroupSettingTile(
                    image: Assets.imagesAllNotifications,
                    title: 'Notification',
                    subTitle: 'All',
                    onTap: () {},
                  ),
                  Container(
                    height: 1,
                    color: kBorderColor,
                    margin: EdgeInsets.symmetric(vertical: 16),
                  ),
                  _GroupSettingTile(
                    image: Assets.imagesAllNotifications,
                    title: 'Media Visibility',
                    subTitle: 'Default',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GroupSettingTile(
                    image: Assets.imagesDisappear,
                    title: 'Disappearing Messages',
                    subTitle: 'Off',
                    onTap: () {},
                  ),
                  Container(
                    height: 1,
                    color: kBorderColor,
                    margin: EdgeInsets.symmetric(vertical: 16),
                  ),
                  _GroupSettingTile(
                    image: Assets.imagesAdvanceChatPrivacy,
                    title: 'Advanced Chat Privacy',
                    subTitle: 'Off',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSettingTile extends StatelessWidget {
  const _GroupSettingTile({
    required this.image,
    required this.title,
    required this.subTitle,
    required this.onTap,
  });

  final String image;
  final String title;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(image, height: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyText(text: title, size: 14, weight: FontWeight.w500),
                MyText(text: subTitle, size: 12, color: kGreyColor),
              ],
            ),
          ),
          Image.asset(Assets.imagesArrowNext, height: 16),
        ],
      ),
    );
  }
}
