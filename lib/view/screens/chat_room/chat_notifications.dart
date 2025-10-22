import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/create_group_controller.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ChatNotifications extends StatelessWidget {
  ChatNotifications({super.key});

  final CreateGroupController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Notifications'),
        body: Obx(() {
          if (controller.isLoadingNotifications.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          final notifications = controller.notifications;

          return ListView.separated(
            padding: AppSizes.DEFAULT,
            physics: const BouncingScrollPhysics(),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final n = notifications[index];

              final name = n.senderName;
              final message =
                  "You have been invited to join '${n.groupName ?? 'a group'}' by ${n.senderName}. Do you want to join?'";

              final isPending = n.isPending;
              final isAccepted = n.isAccepted;
              final isRejected = n.isRejected;

              return _NotificationTile(
                name: name,
                message: message,
                isAccepting: controller.isAccepting.value,
                isRejecting: controller.isRejecting.value,
                negativeButtonText:
                    isPending ? 'Reject' : isRejected ? 'Rejected' : '',
                positiveButtonText:
                    isPending ? 'Accept' : isAccepted ? 'Accepted' : '',
                onNegativeTap: isPending
                    ? () => controller.rejectInvite(n)
                    : () {},
                onPositiveTap: isPending
                    ? () => controller.acceptInvite(n)
                    : () {
                        if (isAccepted) {
                          // Get.to(() => ChatScreen(
                          //       projectId: n.groupId ?? '',
                          //       projectName: n.groupName ?? '',
                          //       collaboratorIds: const [],
                          //       collaboratorEmails: const [],
                          //     ));
                        }
                      },
              );
            },
          );
        }),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String name;
  final String message;
  final String negativeButtonText;
  final String positiveButtonText;
  final bool isAccepting;
  final bool isRejecting;
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
    this.isAccepting = false, 
    this.isRejecting = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name
            .trim()
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
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
                    text: initials,
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MyText(
                  text: message,
                  size: 14,
                  lineHeight: 1.5,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (negativeButtonText.isNotEmpty)
                Expanded(
                  child: MyButton(
                    textSize: 14,
                    height: 40,
                    radius: 12,
                    isLoading: isRejecting,
                    weight: FontWeight.bold,
                    textColor: Colors.black,
                    bgColor: ksecondaryButtonColor,
                    buttonText: negativeButtonText,
                    onTap: onNegativeTap,
                  ),
                ),
              if (negativeButtonText.isNotEmpty &&
                  positiveButtonText.isNotEmpty)
                const SizedBox(width: 10),
              if (positiveButtonText.isNotEmpty)
                Expanded(
                  child: MyButton(
                    textSize: 14,
                    height: 40,
                    radius: 12,
                    isLoading: isAccepting,
                    weight: FontWeight.bold,
                    buttonText: positiveButtonText,
                    onTap: onPositiveTap,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
