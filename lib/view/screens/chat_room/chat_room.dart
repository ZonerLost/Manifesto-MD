import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:manifesto_md/controllers/create_group_controller.dart';

// New controller to manage multi-select across tabs
class GroupSelectionController extends GetxController {
  final selectedIds = <String>{}.obs;
  bool get isSelecting => selectedIds.isNotEmpty;

  void toggle(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void clear() => selectedIds.clear();
}

class ChatRoom extends StatelessWidget {
  const ChatRoom({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> tabs = ['By Specialty', 'By Level', 'General Groups'];

    // Ensure controllers
    final CreateGroupController c = Get.put(CreateGroupController(), permanent: true);
    final GroupSelectionController sel = Get.put(GroupSelectionController(), permanent: true);

    // Local helpers
    Future<void> _exitGroup(String groupId) async {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final fs = FirebaseFirestore.instance;
      final groupRef = fs.collection('groups').doc(groupId);
      final memberDoc = groupRef.collection('members').doc(uid);
      await fs.runTransaction((txn) async {
        txn.delete(memberDoc);
        txn.update(groupRef, {
          'memberIds': FieldValue.arrayRemove([uid]),
          'memberCount': FieldValue.increment(-1),
        });
      });
    }

    Future<void> _deleteGroupDoc(String groupId) async {
      // NOTE: This deletes only the group document.
      // If you need recursive deletion, move this to a Cloud Function.
      await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
    }

    Future<void> _deleteSelectedGroups() async {
      if (!sel.isSelecting) return;

      final ids = sel.selectedIds.toList();
      final ownedIds = c.ownedGroups.map((g) => g.id).toSet();

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete / Exit'),
          content: Text(
            'You selected ${ids.length} group(s).\n'
                'Owned groups will be deleted.\n'
                'Joined groups will be exited.\n\nContinue?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        for (final gid in ids) {
          if (ownedIds.contains(gid)) {
            await _deleteGroupDoc(gid);
          } else {
            await _exitGroup(gid);
          }
        }
        sel.clear();
        Get.snackbar('Done', 'Selection processed successfully.');
      } catch (e) {
        Get.snackbar('Error', 'Failed to process selection: $e');
      }
    }

    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: CustomContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: NestedScrollView(
            physics: const BouncingScrollPhysics(),
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
                        onTap: () {
                          if (sel.isSelecting) {
                            sel.clear();
                          } else {
                            Get.back();
                          }
                        },
                        child: Image.asset(Assets.imagesArrowBack, height: 24),
                      ),
                    ],
                  ),
                  title: Obx(() {
                    if (sel.isSelecting) {
                      return MyText(
                        text: '${sel.selectedIds.length} selected',
                        size: 15,
                        color: kTertiaryColor,
                        weight: FontWeight.w700,
                      );
                    }
                    return  MyText(
                      text: 'Chat Room',
                      size: 15,
                      color: kTertiaryColor,
                      weight: FontWeight.w600,
                    );
                  }),
                  actions: [
                    // Notifications always visible
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() =>  ChatNotifications(), binding: AppBindings());
                        },
                        child: Image.asset(
                          Assets.imagesNotifications,
                          height: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Dynamic actions: settings or delete/clear in selection mode
                    Obx(() {
                      if (!sel.isSelecting) {
                        // Settings gear replaces the previous 3-dots
                        return Row(
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to a settings screen if you have one.
                                  // For now, show a placeholder.
                                  Get.snackbar('Settings', 'Settings coming soon');
                                },
                                child: const Icon(Icons.settings, color: kTertiaryColor, size: 24),
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        );
                      } else {
                        // Selection mode: show delete + clear
                        return Row(
                          children: [
                            IconButton(
                              tooltip: 'Delete / Exit selected',
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: _deleteSelectedGroups,
                            ),
                            IconButton(
                              tooltip: 'Clear selection',
                              icon: const Icon(Icons.close, color: kTertiaryColor),
                              onPressed: sel.clear,
                            ),
                            const SizedBox(width: 10),
                          ],
                        );
                      }
                    }),
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
                            onChanged: c.setGroupSearch,
                            onClear: c.clearGroupSearch,
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Container(
                      color: Colors.transparent,
                      padding: AppSizes.HORIZONTAL,
                      child: TabBar(
                        automaticIndicatorColorAdjustment: false,
                        unselectedLabelColor: kGreyColor,
                        labelColor: kSecondaryColor,
                        labelStyle:  TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.URBANIST,
                          fontSize: 12,
                        ),
                        unselectedLabelStyle:  TextStyle(
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
                  shape:  Border(
                    bottom: BorderSide(color: kBorderColor, width: 1),
                  ),
                ),
              ];
            },
            body: const TabBarView(
              physics: BouncingScrollPhysics(),
              children: [BySpecialty(), BySpecialty(), BySpecialty()],
            ),
          ),
        ),
      ),
    );
  }
}
