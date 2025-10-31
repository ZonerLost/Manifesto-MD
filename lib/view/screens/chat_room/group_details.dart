import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/view/screens/chat_room/add_group_members.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class GroupDetails extends StatelessWidget {
  const GroupDetails({
    super.key,
    required this.groupId,
    this.fallbackGroupName,
  });

  final String groupId;
  final String? fallbackGroupName;

  String _initialsFrom(String? n, {String fallback = 'G'}) {
    final s = (n ?? '').trim();
    if (s.isEmpty) return fallback;
    final parts = s.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    return parts.take(2).map((e) => e[0]).join().toUpperCase();
  }

  // Leave group functionality
  Future<void> _leaveGroup(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Group'),
        content: Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Remove user from group members
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .update({
                  'memberIds': FieldValue.arrayRemove([currentUser.uid]),
                  'memberCount': FieldValue.increment(-1),
                });

                // Remove from members subcollection
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .collection('members')
                    .doc(currentUser.uid)
                    .delete();

                Get.back(); // Close dialog
                Get.back(); // Go back to previous screen
                Get.snackbar('Success', 'You have left the group');
              } catch (e) {
                Get.back();
                Get.snackbar('Error', 'Failed to leave group: $e');
              }
            },
            child: Text('Leave'),
          ),
        ],
      ),
    );
  }

  // Show options menu
  void _showOptionsMenu(BuildContext context, String ownerId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == ownerId;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          color: kPrimaryColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner)
              ListTile(
                leading: Icon(Icons.edit, color: kSecondaryColor),
                title: Text('Edit Group Info'),
                onTap: () {
                  Get.back();
                  Get.snackbar('Coming Soon', 'Edit group info feature coming soon');
                },
              ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Leave Group', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _leaveGroup(context);
              },
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: 'Group Info',
          actions: [
            Center(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .snapshots(),
                builder: (context, snap) {
                  final data = snap.data?.data() ?? {};
                  final ownerId = (data['ownerId'] as String?) ?? '';

                  return GestureDetector(
                    onTap: () => _showOptionsMenu(context, ownerId),
                    child: Image.asset(Assets.imagesMore, height: 24),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .snapshots(),
          builder: (context, snap) {
            final data = snap.data?.data() ?? {};
            final name = (data['name'] as String?)?.trim();
            final avatarUrl = (data['avatarUrl'] as String?)?.trim() ?? '';
            final memberCount = (data['memberCount'] as int?) ?? 0;
            final memberNames = Map<String, dynamic>.from(data['memberNames'] ?? {});
            final ownerId = (data['ownerId'] as String?) ?? '';
            final memberIds = List<String>.from(data['memberIds'] ?? []);
            final createdAt = (data['createdAt']);

            String createdByLabel = 'Created';
            if (ownerId.isNotEmpty) {
              final ownerName = (memberNames[ownerId] as String?) ?? 'Admin';
              createdByLabel = 'Created by $ownerName';
            }

            String createdAtLabel = '';
            try {
              if (createdAt != null) {
                DateTime dt;
                if (createdAt is Timestamp) {
                  dt = createdAt.toDate();
                } else if (createdAt is DateTime) {
                  dt = createdAt;
                } else {
                  dt = DateTime.now();
                }
                createdAtLabel = ' - ${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)}, ${dt.year}';
              }
            } catch (_) {}

            final displayName = (name?.isNotEmpty == true) ? name! : (fallbackGroupName ?? 'Group');

            return ListView(
              shrinkWrap: true,
              padding: AppSizes.DEFAULT,
              physics: const BouncingScrollPhysics(),
              children: [
                // Avatar + initials
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kBorderColor,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarUrl.isNotEmpty
                        ? CommonImageView(
                      height: 80,
                      width: 80,
                      radius: 40,
                      url: avatarUrl,
                      fit: BoxFit.cover,
                      isAvatar: true,
                    )
                        : Center(
                      child: MyText(
                        text: _initialsFrom(displayName, fallback: 'G'),
                        size: 24,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Name + members
                MyText(
                  paddingTop: 12,
                  text: displayName,
                  size: 20,
                  weight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  paddingBottom: 6,
                ),
                MyText(
                  text: 'Group: ${memberCount.toString().padLeft(2, '0')} Members',
                  size: 16,
                  paddingBottom: 16,
                  weight: FontWeight.w500,
                  color: kSecondaryColor,
                  textAlign: TextAlign.center,
                ),

                // Add Members button - only show if current user is owner
                if (currentUser?.uid == ownerId)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => AddGroupMembers(), arguments: {
                          'groupId': groupId,
                          'existingMembers': memberIds,
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            colors: [Color(0xff12C0C0), Color(0xff009CCD)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 16, color: kPrimaryColor),
                            MyText(
                              text: 'Add Members',
                              size: 12,
                              weight: FontWeight.w500,
                              color: kPrimaryColor,
                              paddingLeft: 4,
                              paddingRight: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                _divider(),

                // Members List Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorderColor, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyText(
                        text: 'Members (${memberCount})',
                        size: 14,
                        color: kSecondaryColor,
                        weight: FontWeight.w600,
                        paddingBottom: 12,
                      ),
                      // Display first 10 members with option to view all
                      ..._buildMembersList(memberNames, memberIds, ownerId, currentUser?.uid),
                      if (memberCount > 10)
                        TextButton(
                          onPressed: () {
                            _showAllMembers(memberNames, memberIds, ownerId);
                          },
                          child: Text('View all ${memberCount} members'),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Created by / date
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorderColor, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyText(
                        text: 'Group Discussion',
                        size: 14,
                        color: kSecondaryColor,
                        weight: FontWeight.w500,
                        paddingBottom: 6,
                      ),
                      MyText(
                        text: '$createdByLabel$createdAtLabel',
                        size: 14,
                        color: kGreyColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Media strip (enhanced - NO INDEX REQUIRED)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorderColor, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                              text: 'Media, Links and Docs',
                              size: 14,
                              color: kSecondaryColor,
                              weight: FontWeight.w600,
                            ),
                            GestureDetector(
                              onTap: () {
                                _showAllMedia();
                              },
                              child: Text(
                                'See all',
                                style: TextStyle(
                                  color: kSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMediaGrid(),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Settings block 1
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorderColor, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GroupSettingTile(
                        image: Assets.imagesAllNotifications,
                        title: 'Notification',
                        subTitle: 'All',
                        onTap: () {},
                      ),
                      _divider(),
                      _GroupSettingTile(
                        image: Assets.imagesAllNotifications,
                        title: 'Media Visibility',
                        subTitle: 'Default',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Settings block 2
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorderColor, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GroupSettingTile(
                        image: Assets.imagesDisappear,
                        title: 'Disappearing Messages',
                        subTitle: 'Off',
                        onTap: () {},
                      ),
                      _divider(),
                      _GroupSettingTile(
                        image: Assets.imagesAdvanceChatPrivacy,
                        title: 'Advanced Chat Privacy',
                        subTitle: 'Off',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildMembersList(Map<String, dynamic> memberNames, List<String> memberIds, String ownerId, String? currentUserId) {
    final displayMembers = memberIds.take(10).toList();

    return displayMembers.map((memberId) {
      final memberName = (memberNames[memberId] as String?) ?? 'User';
      final isOwner = memberId == ownerId;

      return ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kBorderColor,
          ),
          child: Center(
            child: Text(
              _initialsFrom(memberName, fallback: 'U'),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(memberName),
            if (isOwner)
              Container(
                margin: EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: currentUserId == ownerId && memberId != ownerId
            ? IconButton(
          icon: Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _removeMember(memberId, memberName),
        )
            : null,
      );
    }).toList();
  }

  void _showAllMembers(Map<String, dynamic> memberNames, List<String> memberIds, String ownerId) {
    final currentUser = FirebaseAuth.instance.currentUser;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            MyText(
              text: 'All Members (${memberIds.length})',
              size: 18,
              weight: FontWeight.w600,
              paddingBottom: 16,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: memberIds.length,
                itemBuilder: (context, index) {
                  final memberId = memberIds[index];
                  final memberName = (memberNames[memberId] as String?) ?? 'User';
                  final isOwner = memberId == ownerId;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kBorderColor,
                      ),
                      child: Center(
                        child: Text(
                          _initialsFrom(memberName, fallback: 'U'),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(memberName),
                        if (isOwner)
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kSecondaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: currentUser?.uid == ownerId && memberId != ownerId
                        ? IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => _removeMember(memberId, memberName),
                    )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeMember(String memberId, String memberName) async {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Remove Member'),
        content: Text('Are you sure you want to remove $memberName from the group?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .update({
                  'memberIds': FieldValue.arrayRemove([memberId]),
                  'memberCount': FieldValue.increment(-1),
                });

                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .collection('members')
                    .doc(memberId)
                    .delete();

                Get.back();
                Get.snackbar('Success', '$memberName has been removed from the group');
              } catch (e) {
                Get.back();
                Get.snackbar('Error', 'Failed to remove member: $e');
              }
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // UPDATED: Media grid without composite index requirement
  Widget _buildMediaGrid() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .orderBy('sentAt', descending: true) // Only order by sentAt
          .limit(50) // Get more messages to filter locally
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snap.data?.docs ?? [];

        // Filter media messages locally (images, videos, files)
        final mediaMessages = docs.where((doc) {
          final data = doc.data();
          final type = data['type'] as String?;
          return type == 'image' || type == 'video' || type == 'file';
        }).take(12).toList(); // Take only first 12 media items

        if (mediaMessages.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No media shared yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: kGreyColor),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: mediaMessages.length,
          padding: EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            final d = mediaMessages[index].data();
            final type = (d['type'] as String?) ?? 'image';
            final url = (d['mediaUrl'] as String?) ?? dummyImg;

            if (type == 'file') {
              return Container(
                decoration: BoxDecoration(
                  color: kBorderColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.insert_drive_file, size: 24, color: kGreyColor),
                ),
              );
            }

            return Stack(
              children: [
                CommonImageView(
                  height: 100,
                  width: 100,
                  radius: 8,
                  url: url,
                  fit: BoxFit.cover,
                ),
                if (type == 'video')
                  Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // UPDATED: Show all media without composite index requirement
  void _showAllMedia() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            MyText(
              text: 'All Media',
              size: 18,
              weight: FontWeight.w600,
              paddingBottom: 16,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .collection('messages')
                    .orderBy('sentAt', descending: true) // Only order by sentAt
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data?.docs ?? [];

                  // Filter media messages locally
                  final mediaMessages = docs.where((doc) {
                    final data = doc.data();
                    final type = data['type'] as String?;
                    return type == 'image' || type == 'video' || type == 'file';
                  }).toList();

                  if (mediaMessages.isEmpty) {
                    return Center(
                      child: Text(
                        'No media shared yet',
                        style: TextStyle(color: kGreyColor),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: mediaMessages.length,
                    itemBuilder: (context, index) {
                      final d = mediaMessages[index].data();
                      final type = (d['type'] as String?) ?? 'image';
                      final url = (d['mediaUrl'] as String?) ?? dummyImg;

                      if (type == 'file') {
                        return Container(
                          decoration: BoxDecoration(
                            color: kBorderColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(Icons.insert_drive_file, size: 24, color: kGreyColor),
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          // TODO: Implement media viewer
                          Get.snackbar('Media', 'Media viewer coming soon');
                        },
                        child: Stack(
                          children: [
                            CommonImageView(
                              height: 100,
                              width: 100,
                              radius: 8,
                              url: url,
                              fit: BoxFit.cover,
                            ),
                            if (type == 'video')
                              Positioned.fill(
                                child: Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    height: 1,
    color: kBorderColor,
    margin: const EdgeInsets.symmetric(vertical: 16),
  );

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return (m >= 1 && m <= 12) ? months[m] : '';
  }
}

class _GroupSettingTile extends StatelessWidget {
  const _GroupSettingTile({
    required this.image,
    required this.title,
    required this.subTitle,
    required this.onTap,
  });

  final String image;
  final String title;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(image, height: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: title, size: 14, weight: FontWeight.w500),
                MyText(text: subTitle, size: 12, color: kGreyColor),
              ],
            ),
          ),
          Image.asset(Assets.imagesArrowNext, height: 16),
        ],
      ),
    );
  }
}