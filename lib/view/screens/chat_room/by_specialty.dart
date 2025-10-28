import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/config/bindings/app_bindings.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/chat_controller.dart';
import 'package:manifesto_md/controllers/profile_controller.dart';
import 'package:manifesto_md/models/groups_model.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_screen.dart';
import 'package:manifesto_md/view/screens/chat_room/create_new_group.dart';
import 'package:manifesto_md/view/widget/chat_head_tile_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

import '../../../controllers/create_group_controller.dart';

class BySpecialty extends StatefulWidget {
  const BySpecialty({super.key});

  @override
  State<BySpecialty> createState() => _BySpecialtyState();
}

class _BySpecialtyState extends State<BySpecialty> {
late final CreateGroupController groupController;
late final ChatController chatController;
final ProfileController profileController = Get.find();




  @override
  void initState() {
    super.initState();

    profileController.fetchProfile();
    // Register (or reuse) the controller when this tab/screen is created
    if (Get.isRegistered<CreateGroupController>() ) {
      groupController = Get.find<CreateGroupController>();
    
      
    } else {
      // Use Get.put so the instance is created immediately and returned
      groupController = Get.put(CreateGroupController());

      // If you prefer lazy:
      // Get.lazyPut(() => CreateGroupController());
      // groupController = Get.find<CreateGroupController>();
    }
  
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() =>  Stack(
      children: [
        groupController.showInitialLoader.value ? const Center(child: CircularProgressIndicator()) : _Chats(),

        Positioned(
          right: 20,
          bottom: 40,
          child: GestureDetector(
            onTap: () {
              Get.to(() => CreateNewGroup(), binding: AppBindings());
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
    )
    );
  }
}

class _Chats extends StatelessWidget {
  _Chats({super.key});

  final CreateGroupController c = Get.find<CreateGroupController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final owned = c.ownedGroups;
      final joined = c.joinedGroups;

      // If both empty, show the empty state (parent will overlay FAB)
      if (owned.isEmpty && joined.isEmpty) {
        return const _EmptyState();
      }

      // Build a combined list with section headers
      final items = <_SectionItem>[];

      if (owned.isNotEmpty) {
        items.add(_SectionHeader('Owned groups'));
        for (final g in owned) items.add(_GroupRow(g));
      }
      if (joined.isNotEmpty) {
        if (items.isNotEmpty) items.add(_SpacerItem(12)); 
        items.add(_SectionHeader('Joined groups'));
        for (final g in joined) items.add(_GroupRow(g));
      }

      return ListView.separated(
        padding: AppSizes.DEFAULT,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => items[i].build(context),
      );
    });
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

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

// Lightweight section “item” protocol
abstract class _SectionItem {
  Widget build(BuildContext context);
}

class _SectionHeader implements _SectionItem {
  final String title;
  _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: MyText(
        text: title,
        size: 12,
        weight: FontWeight.w700,
        color: kGreyColor,
      ),
    );
  }
}

class _SpacerItem implements _SectionItem {
  final double height;
  _SpacerItem(this.height);
  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class _GroupRow implements _SectionItem {
  final Group g;
  _GroupRow(this.g);

  @override
  Widget build(BuildContext context) {
    final lastTime = _formatTime(g.lastMessageAt);
    final lastMsg = (g.lastMessage ?? '').trim().isEmpty ? 'No messages yet' : g.lastMessage!;
    return GestureDetector(
      onTap: () {
      
        Get.to(() => ChatScreen(groupId: g.id, groupName: g.name,));
      },
      child: ChatHeadTile(
        name: g.name,
        time: lastTime,
        message: lastMsg,
        unread: '',
        groupId: g.id,
        groupName: g.name,               
        imageUrl: g.avatarUrl ?? '',
        seen: false,              
      ),
    );
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    // Simple friendly formatter – swap for your app’s util if you have one
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) {
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
