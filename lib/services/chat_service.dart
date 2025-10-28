// lib/services/chat_service.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../models/groups_model.dart';
import '../models/notifications_model.dart';
import '../models/user_group_model.dart';

class ChatService {
  static final ChatService instance = ChatService._();
  ChatService._();

  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  String get myUid => _auth.currentUser?.uid ?? '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserLite>> getGroupMembers(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .asyncMap((groupDoc) async {
      final groupData = groupDoc.data() as Map<String, dynamic>?;
      if (groupData == null) return [];

      final memberIds = List<String>.from(groupData['memberIds'] ?? []);
      final ownerId = groupData['ownerId'] as String? ?? '';
      final memberNames = Map<String, String>.from(groupData['memberNames'] ?? {});
      final memberEmails = Map<String, String>.from(groupData['memberEmailsMap'] ?? {});
      final memberPhotos = Map<String, String>.from(groupData['memberPhotos'] ?? {});

      // Fetch actual user data from users collection
      final members = <UserLite>[];

      for (final memberId in memberIds) {
        try {
          final userDoc = await _firestore.collection('users').doc(memberId).get();
          UserLite userLite;

          if (userDoc.exists) {
            // Create UserLite from user document (primary source)
            final userFromUserDoc = UserLite.fromUserDoc(userDoc);

            // Create UserLite from group member data (fallback source)
            final userFromGroupData = UserLite.fromGroupMemberData(
              userId: memberId,
              memberNames: memberNames,
              memberEmails: memberEmails,
              memberPhotos: memberPhotos,
            );

            // Merge both sources - user document data takes priority
            userLite = UserLite.merge(userFromUserDoc, userFromGroupData);
          } else {
            // Fallback to stored group data if user document doesn't exist
            userLite = UserLite.fromGroupMemberData(
              userId: memberId,
              memberNames: memberNames,
              memberEmails: memberEmails,
              memberPhotos: memberPhotos,
            );
          }

          members.add(userLite);
        } catch (e) {
          // Fallback in case of error - use group data only
          final fallbackUser = UserLite.fromGroupMemberData(
            userId: memberId,
            memberNames: memberNames,
            memberEmails: memberEmails,
            memberPhotos: memberPhotos,
          );
          members.add(fallbackUser);
        }
      }

      return members;
    });
  }

// Method to update group member information with actual user data
  Future<void> updateGroupMemberInfo(String groupId, String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>? ?? {};

        // Use UserLite to get the best available name
        final userLite = UserLite.fromUserDoc(userDoc);

        await _firestore.collection('groups').doc(groupId).update({
          'memberNames.$userId': userLite.name, // Use the computed name from UserLite
          'memberEmailsMap.$userId': userLite.email ?? '',
          'memberPhotos.$userId': userLite.photoURL ?? '',
        });
      }
    } catch (e) {
      print('Error updating group member info: $e');
    }
  }

// Method to update all group members with actual user data
  Future<void> updateAllGroupMembersInfo(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final groupData = groupDoc.data() as Map<String, dynamic>?;
      if (groupData == null) return;

      final memberIds = List<String>.from(groupData['memberIds'] ?? []);

      for (final memberId in memberIds) {
        await updateGroupMemberInfo(groupId, memberId);
      }
    } catch (e) {
      print('Error updating all group members info: $e');
    }
  }

// Enhanced method to get group members with real-time user data updates
  Stream<List<UserLite>> getGroupMembersWithRealtimeUpdates(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .asyncMap((groupDoc) async {
      final groupData = groupDoc.data() as Map<String, dynamic>?;
      if (groupData == null) return [];

      final memberIds = List<String>.from(groupData['memberIds'] ?? []);
      final memberNames = Map<String, String>.from(groupData['memberNames'] ?? {});
      final memberEmails = Map<String, String>.from(groupData['memberEmailsMap'] ?? {});
      final memberPhotos = Map<String, String>.from(groupData['memberPhotos'] ?? {});

      // Fetch all user documents in parallel for better performance
      final userFutures = memberIds.map((memberId) async {
        try {
          final userDoc = await _firestore.collection('users').doc(memberId).get();

          if (userDoc.exists) {
            final userFromUserDoc = UserLite.fromUserDoc(userDoc);
            final userFromGroupData = UserLite.fromGroupMemberData(
              userId: memberId,
              memberNames: memberNames,
              memberEmails: memberEmails,
              memberPhotos: memberPhotos,
            );

            return UserLite.merge(userFromUserDoc, userFromGroupData);
          } else {
            return UserLite.fromGroupMemberData(
              userId: memberId,
              memberNames: memberNames,
              memberEmails: memberEmails,
              memberPhotos: memberPhotos,
            );
          }
        } catch (e) {
          return UserLite.fromGroupMemberData(
            userId: memberId,
            memberNames: memberNames,
            memberEmails: memberEmails,
            memberPhotos: memberPhotos,
          );
        }
      });

      final users = await Future.wait(userFutures);
      return users;
    });
  }

// Method to get a single group member with real user data
  Future<UserLite?> getGroupMember(String groupId, String userId) async {
    try {
      // Get group data
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final groupData = groupDoc.data() as Map<String, dynamic>?;
      if (groupData == null) return null;

      final memberNames = Map<String, String>.from(groupData['memberNames'] ?? {});
      final memberEmails = Map<String, String>.from(groupData['memberEmailsMap'] ?? {});
      final memberPhotos = Map<String, String>.from(groupData['memberPhotos'] ?? {});

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userFromUserDoc = UserLite.fromUserDoc(userDoc);
        final userFromGroupData = UserLite.fromGroupMemberData(
          userId: userId,
          memberNames: memberNames,
          memberEmails: memberEmails,
          memberPhotos: memberPhotos,
        );

        return UserLite.merge(userFromUserDoc, userFromGroupData);
      } else {
        return UserLite.fromGroupMemberData(
          userId: userId,
          memberNames: memberNames,
          memberEmails: memberEmails,
          memberPhotos: memberPhotos,
        );
      }
    } catch (e) {
      print('Error getting group member: $e');
      return null;
    }
  }

// Method to refresh group member cache with latest user data
  Future<void> refreshGroupMembersCache(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final groupData = groupDoc.data() as Map<String, dynamic>?;
      if (groupData == null) return;

      final memberIds = List<String>.from(groupData['memberIds'] ?? []);

      // Batch update for better performance
      final batch = _firestore.batch();
      final groupRef = _firestore.collection('groups').doc(groupId);

      for (final memberId in memberIds) {
        final userDoc = await _firestore.collection('users').doc(memberId).get();
        if (userDoc.exists) {
          final userLite = UserLite.fromUserDoc(userDoc);

          batch.update(groupRef, {
            'memberNames.$memberId': userLite.name,
            'memberEmailsMap.$memberId': userLite.email ?? '',
            'memberPhotos.$memberId': userLite.photoURL ?? '',
          });
        }
      }

      await batch.commit();
      print('Group members cache refreshed for group: $groupId');
    } catch (e) {
      print('Error refreshing group members cache: $e');
    }
  }

  // ---------------------- Group creation ----------------------

  Future<String> createGroupFlow({
    required String name,
    required List<String> memberIds,
    Uint8List? avatarBytes,
    String avatarFileExt = 'jpg',
  }) async {
    final me = _auth.currentUser;
    if (me == null) throw 'Not logged in';

    // 1. upload avatar if any
    String? avatarUrl;
    if (avatarBytes != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_avatar.$avatarFileExt';
      final ref = _storage.ref().child('groups/avatars/$fileName');
      await ref.putData(avatarBytes);
      avatarUrl = await ref.getDownloadURL();
    }

    // 2. prepare member data
    final allMembers = {me.uid, ...memberIds};
    final memberNames = <String, String>{};
    final memberEmailsMap = <String, String>{};
    final memberPhotos = <String, String>{};

    // fetch user details for all members
    final usersSnap = await _fs.collection('users')
        .where(FieldPath.documentId, whereIn: allMembers.toList())
        .get();

    for (final doc in usersSnap.docs) {
      final data = doc.data();
      memberNames[doc.id] = data['displayName'] ?? 'User';
      memberEmailsMap[doc.id] = data['email'] ?? '';
      memberPhotos[doc.id] = data['photoUrl'] ?? '';
    }

    // 3. create group doc
    final groupRef = _fs.collection('groups').doc();
    await groupRef.set({
      'id': groupRef.id,
      'name': name,
      'avatarUrl': avatarUrl,
      'ownerId': me.uid,
      'memberIds': allMembers.toList(),
      'memberNames': memberNames,
      'memberEmailsMap': memberEmailsMap,
      'memberPhotos': memberPhotos,
      'memberCount': allMembers.length,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessage': 'Group created',
    });

    // 4. add members subcollection
    for (final uid in allMembers) {
      await groupRef.collection('members').doc(uid).set({
        'userId': uid,
        'joinedAt': FieldValue.serverTimestamp(),
        'role': uid == me.uid ? 'owner' : 'member',
      });
    }

    return groupRef.id;
  }

  // ---------------------- Invite members to existing group ----------------------

  Future<void> inviteMembersToGroup({
    required String groupId,
    required List<String> newMemberIds,
  }) async {
    if (newMemberIds.isEmpty) return;

    final groupRef = _fs.collection('groups').doc(groupId);
    final batch = _fs.batch();

    // Get group data first
    final groupDoc = await groupRef.get();
    if (!groupDoc.exists) throw 'Group not found';

    final groupData = groupDoc.data()!;
    final existingMemberIds = List<String>.from(groupData['memberIds'] ?? []);
    final memberNames = Map<String, dynamic>.from(groupData['memberNames'] ?? {});
    final memberEmailsMap = Map<String, dynamic>.from(groupData['memberEmailsMap'] ?? {});
    final memberPhotos = Map<String, dynamic>.from(groupData['memberPhotos'] ?? {});

    // Fetch new member details
    final newMembersSnap = await _fs.collection('users')
        .where(FieldPath.documentId, whereIn: newMemberIds)
        .get();

    final updatedMemberIds = {...existingMemberIds};
    final updatedMemberNames = Map<String, dynamic>.from(memberNames);
    final updatedMemberEmailsMap = Map<String, dynamic>.from(memberEmailsMap);
    final updatedMemberPhotos = Map<String, dynamic>.from(memberPhotos);

    for (final doc in newMembersSnap.docs) {
      final uid = doc.id;
      if (updatedMemberIds.contains(uid)) continue; // Skip if already a member

      final data = doc.data();
      updatedMemberIds.add(uid);
      updatedMemberNames[uid] = data['displayName'] ?? 'User';
      updatedMemberEmailsMap[uid] = data['email'] ?? '';
      updatedMemberPhotos[uid] = data['photoUrl'] ?? '';

      // Add to members subcollection
      batch.set(
        groupRef.collection('members').doc(uid),
        {
          'userId': uid,
          'joinedAt': FieldValue.serverTimestamp(),
          'role': 'member',
        },
      );
    }

    // Update group document
    batch.update(groupRef, {
      'memberIds': updatedMemberIds.toList(),
      'memberNames': updatedMemberNames,
      'memberEmailsMap': updatedMemberEmailsMap,
      'memberPhotos': updatedMemberPhotos,
      'memberCount': updatedMemberIds.length,
    });

    await batch.commit();

    // Send notifications to new members
    for (final uid in newMemberIds) {
      if (!existingMemberIds.contains(uid)) {
        await sendGroupInvite(groupId: groupId, receiverId: uid);
      }
    }
  }

  // ---------------------- Streams ----------------------

  Stream<List<Group>> ownedGroupsStream() {
    return _fs
        .collection('groups')
        .where('ownerId', isEqualTo: myUid)
        .snapshots() // Removed orderBy to avoid composite index
        .map((q) {
      final groups = q.docs.map(Group.fromDoc).toList();
      // Sort locally by last message time (most recent first)
      groups.sort((a, b) {
        final aTime = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return groups;
    });
  }

  Stream<List<Group>> joinedGroupsStream() {
    return _fs
        .collection('groups')
        .where('memberIds', arrayContains: myUid)
        .snapshots() // Removed orderBy and inequality filter to avoid composite index
        .map((q) {
      final allGroups = q.docs.map(Group.fromDoc).toList();
      // Filter and sort locally
      final joinedGroups = allGroups.where((g) => g.createdBy != myUid).toList();
      // Sort by last message time (most recent first)
      joinedGroups.sort((a, b) {
        final aTime = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return joinedGroups;
    });
  }

  // NEW: Get all groups where user is a member (both owned and joined)
  Stream<List<Group>> allUserGroupsStream() {
    return _fs
        .collection('groups')
        .where('memberIds', arrayContains: myUid)
        .snapshots() // No ordering in query to avoid composite index
        .map((q) {
      final groups = q.docs.map(Group.fromDoc).toList();
      // Sort locally by last message time (most recent first)
      groups.sort((a, b) {
        final aTime = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return groups;
    });
  }

  Stream<List<AppNotification>> userNotifications() {
    return _fs
        .collection('users')
        .doc(myUid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map(AppNotification.fromDoc).toList());
  }

  // ---------------------- Invites ----------------------

  Future<void> sendGroupInvite({
    required String groupId,
    required String receiverId,
  }) async {
    final me = _auth.currentUser;
    if (me == null) return;

    final groupDoc = await _fs.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) return;

    final groupData = groupDoc.data()!;
    final groupName = groupData['name'] as String? ?? 'Unknown Group';

    await _fs.collection('users').doc(receiverId).collection('notifications').add({
      'type': 'group_invite',
      'groupId': groupId,
      'groupName': groupName,
      'senderId': me.uid,
      'senderName': me.displayName ?? me.email?.split('@').first ?? 'Someone',
      'senderPhotoUrl': me.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Future<String?> respondToInviteByGroup({
    required String groupId,
    required bool accepted,
  }) async {
    if (!accepted) {
      // just delete the notification
      await _deleteInviteNotification(groupId);
      return null;
    }

    // accept: add me to group members
    final groupRef = _fs.collection('groups').doc(groupId);
    final batch = _fs.batch();

    // add to memberIds array
    batch.update(groupRef, {
      'memberIds': FieldValue.arrayUnion([myUid]),
      'memberCount': FieldValue.increment(1),
    });

    // add me to members subcollection
    batch.set(
      groupRef.collection('members').doc(myUid),
      {
        'userId': myUid,
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'member',
      },
    );

    await batch.commit();
    await _deleteInviteNotification(groupId);
    return groupId;
  }

  Future<void> _deleteInviteNotification(String groupId) async {
    final notifs = await _fs
        .collection('users')
        .doc(myUid)
        .collection('notifications')
        .where('type', isEqualTo: 'group_invite')
        .where('groupId', isEqualTo: groupId)
        .get();

    final batch = _fs.batch();
    for (final doc in notifs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ---------------------- Group media (static for now) ----------------------

  Future<List<Map<String, dynamic>>> getGroupMedia(String groupId) async {
    // Static implementation as requested
    return [
      {
        'type': 'image',
        'url': 'https://via.placeholder.com/150',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'type': 'video',
        'url': 'https://via.placeholder.com/150',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];
  }
}