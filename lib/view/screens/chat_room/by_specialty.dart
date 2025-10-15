import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/chat_room/create_new_group.dart';
import 'package:manifesto_md/view/widget/chat_head_tile_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class BySpecialty extends StatefulWidget {
  const BySpecialty({super.key});

  @override
  State<BySpecialty> createState() => _BySpecialtyState();
}

class _BySpecialtyState extends State<BySpecialty> {
  bool _showEmptyState = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showEmptyState = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _showEmptyState ? const _EmptyState() : _Chats(),

        Positioned(
          right: 20,
          bottom: 40,
          child: GestureDetector(
            onTap: () {
              Get.to(() => CreateNewGroup());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6.54),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
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
                    text: 'New Group',
                    size: 10,
                    weight: FontWeight.w700,
                    color: kPrimaryColor,
                    paddingLeft: 4,
                    paddingRight: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chats extends StatelessWidget {
  final List<Map<String, String>> chatGroups = [
    {
      'initials': 'IM',
      'name': 'Internal Medicine',
      'unread': '2',
      'time': 'Yesterday,3:45 PM',
      'message': 'Dr. Ayesha: How to manage high INR...',
    },
    {
      'initials': 'PD',
      'name': 'Pediatrics',
      'unread': '',
      'time': 'Yesterday',
      'message': 'Dr. Ayesha: How to manage high INR...',
    },
    {
      'initials': 'EM',
      'name': 'Emergency Medicine',
      'unread': '',
      'time': 'Yesterday',
      'message': 'Dr. Ayesha: How to manage high INR...',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: chatGroups.length,
      padding: AppSizes.DEFAULT,
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 12);
      },
      itemBuilder: (BuildContext context, int index) {
        return ChatHeadTile(
          name: chatGroups[index]['name'] ?? '',
          time: chatGroups[index]['time'] ?? '',
          message: chatGroups[index]['message'] ?? '',
          unread: chatGroups[index]['unread'] ?? '',
          imageUrl: '',
          seen: false,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(Assets.imagesNoGroupChat, height: 250),
        MyText(
          text: 'No chat group found',
          textAlign: TextAlign.center,
          size: 16,
          weight: FontWeight.w600,
          paddingBottom: 8,
        ),
        MyText(
          text: 'Let’s create new group',
          size: 12,
          textAlign: TextAlign.center,
          color: kGreyColor,
          paddingBottom: 100,
        ),
      ],
    );
  }
}
