import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_screen.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ChatNotifications extends StatelessWidget {
  const ChatNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    List notifications = [
      {
        'name': 'john',
        'message':
            "You have been invited to join Medicine group by john. Do you want to join?",
        'negativeButtonText': 'Deny',
        'positiveButtonText': 'Approve',
        'onNegativeTap': () {
          // Handle deny action
        },
        'onPositiveTap': () {
          // Handle approve action
        },
      },
      {
        'name': 'Smith',
        'message':
            "Invitation declined! Smith has declined your group invitation to Medicine group.",
        'negativeButtonText': 'Leave',
        'positiveButtonText': 'Send Again',
        'onNegativeTap': () {
          // Handle leave action
        },
        'onPositiveTap': () {
          // Handle send again action
        },
      },
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Notification'),
        body: ListView.separated(
          itemCount: notifications.length,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _NotificationTile(
              name: notification['name'],
              message: notification['message'],
              negativeButtonText: notification['negativeButtonText'],
              positiveButtonText: notification['positiveButtonText'],
              onNegativeTap: notification['onNegativeTap'],
              onPositiveTap: notification['onPositiveTap'],
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 16);
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String name;
  final String message;
  final String negativeButtonText;
  final String positiveButtonText;
  final VoidCallback onNegativeTap;
  final VoidCallback onPositiveTap;

  const _NotificationTile({
    Key? key,
    required this.name,
    required this.message,
    required this.negativeButtonText,
    required this.positiveButtonText,
    required this.onNegativeTap,
    required this.onPositiveTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ChatScreen());
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
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
                  child: MyText(
                    text: message,
                    size: 12,
                    lineHeight: 1.5,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MyBorderButton(
                    textSize: 12,
                    height: 35,
                    radius: 12,
                    weight: FontWeight.w500,
                    buttonText: negativeButtonText,
                    onTap: onNegativeTap,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: MyButton(
                    textSize: 12,
                    height: 35,
                    radius: 12,
                    weight: FontWeight.w500,
                    buttonText: positiveButtonText,
                    onTap: onPositiveTap,
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
