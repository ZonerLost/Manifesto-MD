// lib/view/screens/chat_room/chat_room.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/config/bindings/app_bindings.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/chat_room/by_specialty.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_notifications.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

import 'create_new_group.dart';

class ChatRoom extends StatelessWidget {
  const ChatRoom({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> tabs = ['By Specialty', 'By Level', 'General Groups'];

    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: CustomContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: NestedScrollView(
            physics: BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  titleSpacing: -5.0,
                  expandedHeight: 165,
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Image.asset(Assets.imagesArrowBack, height: 24),
                      ),
                    ],
                  ),
                  title: MyText(
                    text: 'Chat Room',
                    size: 15,
                    color: kTertiaryColor,
                    weight: FontWeight.w600,
                  ),
                  actions: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => ChatNotifications(), binding: AppBindings());
                        },
                        child: Image.asset(
                          Assets.imagesNotifications,
                          height: 22,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            _ChatRoomOptions(),
                            isScrollControlled: true,
                          );
                        },
                        child: Image.asset(Assets.imagesMore, height: 24),
                      ),
                    ),
                    SizedBox(width: 20),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                          child: CustomSearchBar(
                            hintText: 'Search Groups or Keywords',
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(50),
                    child: Container(
                      color: Colors.transparent,
                      padding: AppSizes.HORIZONTAL,
                      child: TabBar(
                        automaticIndicatorColorAdjustment: false,
                        unselectedLabelColor: kGreyColor,
                        labelColor: kSecondaryColor,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.URBANIST,
                          fontSize: 12,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFonts.URBANIST,
                          fontSize: 12,
                        ),
                        tabs: tabs.map((tab) => Text(tab)).toList(),
                        indicatorColor: kSecondaryColor,
                        indicatorWeight: 2,
                        labelPadding: const EdgeInsets.symmetric(vertical: 8),
                        splashFactory: NoSplash.splashFactory,
                      ),
                    ),
                  ),
                  shape: Border(
                    bottom: BorderSide(color: kBorderColor, width: 1),
                  ),
                ),
              ];
            },
            body: TabBarView(
              physics: BouncingScrollPhysics(),
              children: [BySpecialty(), BySpecialty(), BySpecialty()],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatRoomOptions extends StatelessWidget {
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
                      case 0:
                      // Navigate to create new group
                        Get.to(() => CreateNewGroup());
                        break;
                      case 1:
                      // TODO: Implement settings
                        Get.snackbar('Coming Soon', 'Settings feature coming soon');
                        break;
                    }
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MyText(
                      text: _options[i],
                      size: 14,
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