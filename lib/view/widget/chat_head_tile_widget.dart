import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_screen.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart'; // <-- use your common image widget
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ChatHeadTile extends StatelessWidget {
  final String name;
  final String time;
  final String message;
  final String groupId;
  final String groupName;
  final String unread;   // "0", "1", "2", ...
  final String imageUrl; // group avatar url
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
    required this.groupName,
  }) : super(key: key);

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'G';
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // unread is non-nullable; treat "0" or empty as no-unread
    final bool hasUnread = unread.trim().isNotEmpty && unread != '0';

    return GestureDetector(
      onTap: () {
        Get.to(() => ChatScreen(groupId: groupId, groupName: groupName));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Row(
          children: [
            // Avatar: show imageUrl if available, else initials
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBorderColor,
              ),
              clipBehavior: Clip.antiAlias,
              child: (imageUrl.isNotEmpty)
                  ? CommonImageView(
                url: imageUrl,
                height: 48,
                width: 48,
                radius: 24,
                fit: BoxFit.cover,
                isAvatar: true,
              )
                  : Center(
                child: MyText(
                  text: _initials(name.isNotEmpty ? name : groupName),
                  size: 16,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(text: name, size: 14, weight: FontWeight.w700),
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
            const SizedBox(width: 10),
            // Time + unread badge
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
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: const BoxDecoration(
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
