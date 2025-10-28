import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/models/groups_model.dart';
import 'package:manifesto_md/models/notifications_model.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_screen.dart';
import 'package:manifesto_md/view/widget/show_common_snackbar_widget.dart';
import '../services/chat_service.dart';

class CreateGroupController extends GetxController {
  // Inputs
  final name = ''.obs;
  final query = ''.obs;

  // UI state
  final isSubmitting = false.obs;
  final isLoadingPage = false.obs;

  final hasMore = true.obs;
  final ownedGroups = <Group>[].obs;
  final joinedGroups = <Group>[].obs;

  // selection (single source of truth)
  final selected = <String>{}.obs;

  // Users page
  final users = <Map<String, dynamic>>[].obs;
  final int pageSize = 50;
  DocumentSnapshot<Map<String, dynamic>>? _lastSnap;

  // Optional avatar
  String userName = "";
  Uint8List? avatarBytes;
  String avatarExt = 'jpg';

  // Home screen top loader + notifications
  final showInitialLoader = true.obs;
  final notifications = <AppNotification>[].obs;
  final isLoadingNotifications = false.obs;
  final isAccepting = false.obs;
  final isRejecting = false.obs;

  StreamSubscription? _ownedSub;
  StreamSubscription? _joinedSub;
  StreamSubscription? _notifSub;

  bool _gotOwned = false;
  bool _gotJoined = false;
  bool _gotNotifs = false;

  String get myUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    _loadFirstPage();
    ever<String>(query, (_) => _loadFirstPage());
    _bindNotifications();
    _bindGroups();
  }

  @override
  void onClose() {
    _ownedSub?.cancel();
    _joinedSub?.cancel();
    _notifSub?.cancel();
    super.onClose();
  }

  // ---------------------- Groups streams ----------------------

  void _bindGroups() {
    _ownedSub?.cancel();
    _joinedSub?.cancel();

    _ownedSub = ChatService.instance.ownedGroupsStream().listen(
          (list) {
        ownedGroups.assignAll(list);
        if (!_gotOwned) {
          _gotOwned = true;
          _maybeHideInitialLoader();
        }
      },
      onError: (e) {
        if (!_gotOwned) {
          _gotOwned = true;
          _maybeHideInitialLoader();
        }
        // ignore: avoid_print
        print('ownedGroups stream error: $e');
      },
    );

    _joinedSub = ChatService.instance.joinedGroupsStream().listen(
          (list) {
        joinedGroups.assignAll(list);
        if (!_gotJoined) {
          _gotJoined = true;
          _maybeHideInitialLoader();
        }
      },
      onError: (e) {
        if (!_gotJoined) {
          _gotJoined = true;
          _maybeHideInitialLoader();
        }
        // ignore: avoid_print
        print('joinedGroups stream error: $e');
      },
    );
  }

  Future<void> inviteSelectedToExistingGroup(String groupId) async {
    if (selected.isEmpty) {
      throw 'Pick at least one member';
    }
    isSubmitting.value = true;
    try {
      // Use the new inviteMembersToGroup method from ChatService
      await ChatService.instance.inviteMembersToGroup(
        groupId: groupId,
        newMemberIds: selected.toList(),
      );

      // clear selection so a later visit doesn't re-use it
      selected.clear();

      showCommonSnackbarWidget('Success', 'Invites sent successfully');
    } catch (e) {
      showCommonSnackbarWidget('Error', 'Failed to send invites: $e');
      rethrow;
    } finally {
      isSubmitting.value = false;
    }
  }

// OPTIONAL: owner-only remove (ensure rules allow it)
  Future<void> removeMemberFromGroup(String groupId, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups').doc(groupId)
          .collection('members').doc(uid)
          .delete();

      await FirebaseFirestore.instance
          .collection('groups').doc(groupId)
          .update({'memberCount': FieldValue.increment(-1)});

      showCommonSnackbarWidget('Success', 'Member removed successfully');
    } catch (e) {
      showCommonSnackbarWidget('Error', 'Failed to remove member: $e');
      rethrow;
    }
  }


  // ---------------------- Notifications stream ----------------------

  void _bindNotifications() {
    isLoadingNotifications.value = true;
    try {
      _notifSub = ChatService.instance.userNotifications().listen(
            (list) {
          notifications.assignAll(list);
          isLoadingNotifications.value = false;
          if (!_gotNotifs) {
            _gotNotifs = true;
            _maybeHideInitialLoader();
          }
        },
        onError: (err) {
          isLoadingNotifications.value = false;
          if (!_gotNotifs) {
            _gotNotifs = true;
            _maybeHideInitialLoader();
          }
          // ignore: avoid_print
          print('Notification stream error: $err');
        },
      );
    } catch (e) {
      isLoadingNotifications.value = false;
      if (!_gotNotifs) {
        _gotNotifs = true;
        _maybeHideInitialLoader();
      }
      // ignore: avoid_print
      print('Failed to bind notifications: $e');
    }
  }

  void _maybeHideInitialLoader() {
    if (_gotOwned && _gotJoined && _gotNotifs) {
      if (showInitialLoader.value) showInitialLoader.value = false;
    }
  }

  // ---------------------- Pagination / Users ----------------------

  Future<void> _loadFirstPage() async {
    users.clear();
    _lastSnap = null;
    hasMore.value = true;
    await loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (isLoadingPage.value || !hasMore.value) return;
    isLoadingPage.value = true;

    try {
      Query<Map<String, dynamic>> q;
      QuerySnapshot<Map<String, dynamic>> snap;

      if (query.value.trim().isEmpty) {
        // default ordering
        q = FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: false)
            .limit(pageSize);
        if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);

        try {
          snap = await q.get();
        } on FirebaseException {
          // fallback if index missing
          q = FirebaseFirestore.instance
              .collection('users')
              .orderBy(FieldPath.documentId)
              .limit(pageSize);
          if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
          snap = await q.get();
        }
      } else {
        final qLower = query.value.toLowerCase();

        // try displayName_lower first
        try {
          q = FirebaseFirestore.instance
              .collection('users')
              .where('displayName_lower', isGreaterThanOrEqualTo: qLower)
              .where('displayName_lower', isLessThan: '$qLower\uf8ff')
              .orderBy('displayName_lower')
              .limit(pageSize);
          if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
          snap = await q.get();
        } on FirebaseException {
          // fallback to email_lower
          try {
            q = FirebaseFirestore.instance
                .collection('users')
                .where('email_lower', isGreaterThanOrEqualTo: qLower)
                .where('email_lower', isLessThan: '$qLower\uf8ff')
                .orderBy('email_lower')
                .limit(pageSize);
            if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
            snap = await q.get();
          } on FirebaseException {
            // final fallback: doc id
            q = FirebaseFirestore.instance
                .collection('users')
                .orderBy(FieldPath.documentId)
                .limit(pageSize);
            if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
            snap = await q.get();
          }
        }
      }

      if (snap.docs.isEmpty) {
        hasMore.value = false;
        return;
      }

      _lastSnap = snap.docs.last;

      users.addAll(
        snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .where((m) => m['id'] != myUid),
      );

      hasMore.value = snap.docs.length >= pageSize;
    } finally {
      isLoadingPage.value = false;
    }
  }

  // ---------------------- Selection helpers (single source of truth) ---------

  void toggleUser(Map<String, dynamic> user) {
    final uid = user['id'] as String;
    if (selected.contains(uid)) {
      selected.remove(uid);
    } else {
      selected.add(uid);
    }
  }

  void toggle(String uid) {
    if (selected.contains(uid)) {
      selected.remove(uid);
    } else {
      selected.add(uid);
    }
  }

  void selectAllVisible() {
    for (final u in users) {
      final uid = u['id'] as String;
      if (uid == myUid) continue;
      selected.add(uid);
    }
  }

  void clearSelection() => selected.clear();

  // ---------------------- Invites -------------------------------------------

  Future<void> acceptInvite(AppNotification notif) async {
    isAccepting.value = true;
    try {
      final gid = await ChatService.instance.respondToInviteByGroup(
        groupId: notif.groupId ?? "",
        accepted: true,
      );
      showCommonSnackbarWidget('Invite Accepted', 'You have joined ${notif.groupName}');
          if (gid != null) {
        Get.to(() => ChatScreen(groupId: gid, groupName: notif.groupName));
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      showCommonSnackbarWidget('Error', 'Failed to accept invite: $e');
    } finally {
      isAccepting.value = false;
    }
  }

  Future<void> rejectInvite(AppNotification notif) async {
    isRejecting.value = true;
    try {
      await ChatService.instance.respondToInviteByGroup(
        groupId: notif.groupId ?? "",
        accepted: false,
      );
      showCommonSnackbarWidget('Invite Rejected', 'Invite from ${notif.senderName} rejected');
    } catch (e) {
      // ignore: avoid_print
      print(e);
      showCommonSnackbarWidget('Error', 'Failed to reject invite: $e');
    } finally {
      isRejecting.value = false;
    }
  }

  // ---------------------- Submit (create group + invites) --------------------

  Future<String> submit() async {
    final n = name.value.trim();
    if (n.isEmpty) throw 'Group name is required';
    if (selected.isEmpty) throw 'Pick at least one member';

    isSubmitting.value = true;
    try {
      final gid = await ChatService.instance.createGroupFlow(
        name: n,
        memberIds: selected.toList(),
        avatarBytes: avatarBytes,
        avatarFileExt: avatarExt,
      );

      // send invites (optional – if your flow requires acceptance)
      for (final uid in selected) {
        await ChatService.instance.sendGroupInvite(
          groupId: gid,
          receiverId: uid,
        );
      }

      return gid;
    } finally {
      isSubmitting.value = false;
    }
  }
}