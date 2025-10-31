import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:manifesto_md/controllers/create_group_controller.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_screen.dart';

class AddGroupMembers extends StatefulWidget {
  const AddGroupMembers({super.key});

  @override
  State<AddGroupMembers> createState() => _AddGroupMembersState();
}

class _AddGroupMembersState extends State<AddGroupMembers> {
  late final CreateGroupController c;
  final TextEditingController _searchController = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Track existing members for filtering
  List<String> existingMembers = [];
  String? existingGroupId;
  bool isAddingToExisting = false;

  @override
  void initState() {
    super.initState();

    c = Get.isRegistered<CreateGroupController>()
        ? Get.find<CreateGroupController>()
        : Get.put(CreateGroupController());

    // Get existing group data if provided
    final args = Get.arguments as Map<String, dynamic>?;
    existingGroupId = args?['groupId'] as String?;
    existingMembers = List<String>.from(args?['existingMembers'] ?? []);
    isAddingToExisting = existingGroupId != null;

    // Clear previous selection when opening for existing group
    if (isAddingToExisting) {
      c.selected.clear();
    }

    _scrollCtrl.addListener(() {
      final max = _scrollCtrl.position.maxScrollExtent;
      if (_scrollCtrl.position.pixels > max - 280) {
        c.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- helpers to normalize user fields ---
  String _name(Map<String, dynamic> u) =>
      (u['name'] ?? u['displayName'] ?? '').toString();
  String _email(Map<String, dynamic> u) =>
      (u['email'] ?? '').toString();
  String _photo(Map<String, dynamic> u) =>
      (u['photoUrl'] ?? u['photoURL'] ?? u['imageUrl'] ?? '').toString();

  String _initials(Map<String, dynamic> u) {
    final n = _name(u).trim();
    if (n.isEmpty) return '';
    final parts = n.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final letters = parts.take(2).map((e) => e[0]).join();
    return letters.toUpperCase();
  }

  // Method for adding members to existing group
  Future<void> _addMembersToExistingGroup() async {
    if (c.isSubmitting.value || c.selected.isEmpty) return;

    try {
      c.isSubmitting.value = true;
      await c.inviteSelectedToExistingGroup(existingGroupId!);

      Get.back();
      Get.snackbar('Success', 'Members added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add members: $e');
    } finally {
      c.isSubmitting.value = false;
    }
  }

  // Method for creating new group
  Future<void> _createGroup() async {
    if (c.isSubmitting.value) return;

    try {
      c.isSubmitting.value = true;
      await c.createGroupAndNavigate();
    } catch (e) {
      // Error is already handled in createGroupAndNavigate
    } finally {
      c.isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Obx(() => c.selected.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 15),
          child: GestureDetector(
            onTap: isAddingToExisting ? _addMembersToExistingGroup : _createGroup,
            child: c.isSubmitting.value
                ? Container(
              height: 48,
              width: 48,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kSecondaryColor,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Image.asset(Assets.imagesDone, height: 48),
          ),
        )
            : const SizedBox.shrink()),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: -5.0,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Image.asset(Assets.imagesArrowBack, height: 24),
              ),
            ],
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: isAddingToExisting ? 'Add Members' : 'New Group',
                size: 14,
                color: kTertiaryColor,
                weight: FontWeight.w600,
              ),
              MyText(
                  text: isAddingToExisting ? 'Select members to add' : 'Add Members',
                  size: 12,
                  color: kTertiaryColor
              ),
            ],
          ),
        ),
        body: Obx(() {
          final query = c.query.value.trim().toLowerCase();
          final all = c.users;

          // Filter out existing members and apply search filter
          final filtered = all.where((u) {
            final uid = u['id'] as String;
            final isExistingMember = existingMembers.contains(uid);
            if (isExistingMember) return false;

            if (query.isEmpty) return true;

            final n = _name(u).toLowerCase();
            final e = _email(u).toLowerCase();
            return n.contains(query) || e.contains(query);
          }).toList();

          final byId = {for (final u in all) u['id'] as String: u};

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: AppSizes.HORIZONTAL,
                child: CustomSearchBar(
                  hintText: 'Search Name or Email',
                  controller: _searchController,
                  onChanged: (val) => c.query.value = val,
                ),
              ),

              // Show existing members count if adding to existing group
              if (isAddingToExisting && existingMembers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      MyText(
                        text: '${existingMembers.length} existing members in group',
                        size: 12,
                        color: kGreyColor,
                      ),
                    ],
                  ),
                ),

              // Selected members chips
              if (c.selected.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 65,
                  child: ListView.separated(
                    padding: AppSizes.HORIZONTAL,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: c.selected.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final uid = c.selected.elementAt(i);
                      final u = byId[uid];
                      final img = u != null ? _photo(u) : '';
                      final initials = u != null ? _initials(u) : '';
                      final firstName = u != null
                          ? (_name(u).split(' ').firstOrNull ?? _name(u))
                          : uid;

                      return Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomCenter,
                            children: [
                              if (img.isNotEmpty)
                                CommonImageView(
                                  height: 40,
                                  width: 40,
                                  radius: 100,
                                  url: img,
                                  fit: BoxFit.cover,
                                )
                              else
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
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => c.selected.remove(uid),
                                  child: Image.asset(
                                    Assets.imagesCancelIcon,
                                    height: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          MyText(
                            paddingTop: 6,
                            text: firstName,
                            size: 12,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                            weight: FontWeight.w500,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  height: 1,
                  color: kBorderColor,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                ),
              ],

              SizedBox(height: 10,),

              // Section title
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 12),
                child: MyText(
                  text: isAddingToExisting ? 'Available Contacts' : 'All SymptoSmart MD Contacts',
                  size: 14,
                  weight: FontWeight.w600,
                ),
              ),

              // Users list
              Expanded(
                child: filtered.isEmpty && !c.isLoadingPage.value
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        text: 'No contacts available',
                        size: 16,
                        color: kGreyColor,
                      ),
                      if (isAddingToExisting && existingMembers.isNotEmpty)
                        MyText(
                          text: 'All contacts are already in the group',
                          size: 12,
                          color: kGreyColor,
                          paddingTop: 8,
                        ),
                    ],
                  ),
                )
                    : ListView.separated(
                  controller: _scrollCtrl,
                  itemCount: filtered.length + ((c.hasMore.value && c.isLoadingPage.value) ? 1 : 0),
                  padding: AppSizes.HORIZONTAL,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    if (i >= filtered.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    final u = filtered[i];
                    final uid = u['id'] as String;
                    final img = _photo(u);
                    final nm = _name(u);
                    final em = _email(u);
                    final checked = c.selected.contains(uid);

                    return _MemberTile(
                      name: nm,
                      email: em,
                      imageUrl: img,
                      isSelected: checked,
                      onTap: () => checked ? c.selected.remove(uid) : c.selected.add(uid),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final String email;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberTile({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          if (imageUrl.isNotEmpty)
            CommonImageView(
              height: 48,
              width: 48,
              url: imageUrl,
              radius: 100,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBorderColor,
              ),
              child: Center(
                child: MyText(
                  text: name.isNotEmpty
                      ? name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
                      : '',
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: name, size: 14, weight: FontWeight.w600),
                MyText(
                  paddingTop: 6,
                  text: email,
                  size: 12,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  color: kGreyColor,
                ),
              ],
            ),
          ),
          CustomCheckBox(
            radius: 100,
            borderWidth: 1.0,
            isActive: isSelected,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}