import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/config/bindings/app_bindings.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/chat_controller.dart';
import 'package:manifesto_md/controllers/payment_controller.dart';
import 'package:manifesto_md/controllers/profile_controller.dart';
import 'package:manifesto_md/models/groups_model.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_screen.dart';
import 'package:manifesto_md/view/screens/chat_room/create_new_group.dart';
import 'package:manifesto_md/view/widget/chat_head_tile_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:manifesto_md/controllers/create_group_controller.dart';
import 'package:manifesto_md/view/screens/subscription/subscription.dart';

import 'chat_room.dart' show GroupSelectionController;

class BySpecialty extends StatefulWidget {
  const BySpecialty({super.key});

  @override
  State<BySpecialty> createState() => _BySpecialtyState();
}

class _BySpecialtyState extends State<BySpecialty> {
  late final CreateGroupController groupController;
  late final ChatController chatController;
  late final PaymentController paymentController;
  final ProfileController profileController = Get.find();
  final GroupSelectionController sel = Get.find<GroupSelectionController>();

  @override
  void initState() {
    super.initState();

    profileController.fetchProfile();
    paymentController = Get.find<PaymentController>();
    if (Get.isRegistered<CreateGroupController>()) {
      groupController = Get.find<CreateGroupController>();
    } else {
      groupController = Get.put(CreateGroupController());
    }
  }

  Future<void> _handleNewGroupTap() async {
    if (!paymentController.hasCheckedSubscription.value) {
      await paymentController.checkIfPremium();
    }
    if (!paymentController.isPremiumUser.value) {
      Get.snackbar(
        'Subscription Required',
        'A Manifesto MD Pro subscription is needed to create new groups.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      Get.to(() => const Subscription());
      return;
    }
    Get.to(() => CreateNewGroup(), binding: AppBindings());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
      children: [
        groupController.showInitialLoader.value
            ? const Center(child: CircularProgressIndicator())
            : _Chats(),
        Positioned(
          right: 20,
          bottom: 40,
          child: GestureDetector(
            onTap: () => _handleNewGroupTap(),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6.54),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xff12C0C0), Color(0xff009CCD)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child:  Row(
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
    ));
  }
}

class _Chats extends StatelessWidget {
  _Chats();

  final CreateGroupController c = Get.find<CreateGroupController>();
  final GroupSelectionController sel = Get.find<GroupSelectionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final owned = c.filteredOwned; // search-aware
      final joined = c.filteredJoined; // search-aware

      if (owned.isEmpty && joined.isEmpty) {
        return const _EmptyState();
      }

      final items = <_SectionItem>[];

      if (owned.isNotEmpty) {
        items.add(_SectionHeader('Owned groups'));
        for (final g in owned) {
          items.add(_GroupRow(g));
        }
      }
      if (joined.isNotEmpty) {
        if (items.isNotEmpty) items.add(_SpacerItem(12));
        items.add(_SectionHeader('Joined groups'));
        for (final g in joined) {
          items.add(_GroupRow(g));
        }
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
    // Layout-safe, scrollable center: avoids RenderFlex overflow
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // key to prevent overflow
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Image.asset(Assets.imagesNoGroupChat, height: 220),
                    const SizedBox(height: 12),
                     MyText(
                      text: 'No chat group found',
                      textAlign: TextAlign.center,
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                    const SizedBox(height: 6),
                     MyText(
                      text: 'Let’s create new group',
                      size: 12,
                      textAlign: TextAlign.center,
                      color: kGreyColor,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        paddingLeft: 4,
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

  final GroupSelectionController sel = Get.find<GroupSelectionController>();

  @override
  Widget build(BuildContext context) {
    final lastTime = _formatTime(g.lastMessageAt);
    final lastMsg =
    (g.lastMessage ?? '').trim().isEmpty ? 'No messages yet' : g.lastMessage!;

    return Obx(() {
      final selected = sel.selectedIds.contains(g.id);
      final isSelecting = sel.isSelecting;

      return GestureDetector(
        // Long-press only needed to ENTER selection mode
        onLongPress: () {
          if (!isSelecting) sel.toggle(g.id);
        },
        onTap: () {
          if (isSelecting) {
            sel.toggle(g.id);
          } else {
            Get.to(() => ChatScreen(groupId: g.id, groupName: g.name));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? kSecondaryColor : kBorderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // NEW: show selection box for ALL items while in selection mode
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isSelecting
                    ? Padding(
                  key: const ValueKey('selectBox'),
                  padding: const EdgeInsets.only(left: 10, right: 6),
                  child: _SelectBox(
                    selected: selected,
                    onTap: () => sel.toggle(g.id),
                  ),
                )
                    : const SizedBox(width: 0, key: ValueKey('noBox')),
              ),

              // The actual tile takes the remaining width
              Expanded(
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
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) {
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _SelectBox extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _SelectBox({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? kSecondaryColor : kGreyColor,
            width: 2,
          ),
          color: selected ? kSecondaryColor : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: selected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
