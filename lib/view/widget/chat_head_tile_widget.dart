import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_screen.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ChatHeadTile extends StatelessWidget {
  final String name;
  final String time;
  final String message;
  final String groupId;
  final String groupName;
  final String unread;
  final String imageUrl;
  final bool seen;

  const ChatHeadTile({
    Key? key,
    required this.name,
    required this.time,
    required this.message,
    required this.unread,
    required this.imageUrl,
    required this.seen,
    required this.groupId, 
    required this.groupName
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasUnread =
        unread != null &&
        unread != "0" &&
        unread != 0 &&
        unread.toString().isNotEmpty;
    return GestureDetector(
      onTap: () {
        Get.to(() => ChatScreen(groupId: groupId, groupName: groupName, ));
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBorderColor,
              ),
              child: Center(
                child: MyText(
                  text:
                      name.isNotEmpty
                          ? name
                              .trim()
                              .split(' ')
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .take(2)
                              .join()
                              .toUpperCase()
                          : '',
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(text: name, size: 14, weight: FontWeight.w600),
                  MyText(
                    paddingTop: 6,
                    text: message,
                    size: 12,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                    color: kGreyColor,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText(
                  text: time,
                  size: 10,
                  weight: FontWeight.w500,
                  color: kGreyColor,
                  paddingBottom: 4,
                ),
                if (hasUnread)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: MyText(
                        text: unread,
                        size: 10,
                        weight: FontWeight.w700,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
