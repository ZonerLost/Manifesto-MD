import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/models/groups_model.dart';
import 'package:manifesto_md/models/notifications_model.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_room.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_screen.dart';
import 'package:manifesto_md/view/widget/show_common_snackbar_widget.dart';
import '../services/chat_service.dart';

class CreateGroupController extends GetxController {
  // Inputs (for create group)
  final name = ''.obs;

  // Search for "add members" screen (users list pagination)
  final query = ''.obs;

  // NEW: Search for Chat Room groups list
  final groupSearchQuery = ''.obs;

  // UI state
  final isSubmitting = false.obs;
  final isLoadingPage = false.obs;

  final hasMore = true.obs;

  /// Raw groups from streams
  final ownedGroups = <Group>[].obs;
  final joinedGroups = <Group>[].obs;

  /// NEW: Derived (search-filtered) lists for UI rendering
  final filteredOwned = <Group>[].obs;
  final filteredJoined = <Group>[].obs;

  // selection (single source of truth)
  final selected = <String>{}.obs;

  // Users page
  final users = <Map<String, dynamic>>[].obs;
  final int pageSize = 50;
  DocumentSnapshot<Map<String, dynamic>>? _lastSnap;

  // Group avatar
  Uint8List? avatarBytes;
  String avatarExt = 'jpg';

  // Group permissions
  final permissions = <String, bool>{
    'editGroupSettings': true,
    'sendNewMessage': true,
    'addOtherMembers': true,
    'inviteViaLink': false,
  }.obs;

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

    // Users pagination for "add members" screen
    _loadFirstPage();
    ever<String>(query, (_) => _loadFirstPage());

    // Groups + notifications streams
    _bindNotifications();
    _bindGroups();

    // Recompute group search filters whenever sources or search query change
    ever<List<Group>>(ownedGroups, (_) => _recomputeGroupFilters());
    ever<List<Group>>(joinedGroups, (_) => _recomputeGroupFilters());
    ever<String>(groupSearchQuery, (_) => _recomputeGroupFilters());

    // Initial compute (in case lists are already populated)
    _recomputeGroupFilters();
  }

  @override
  void onClose() {
    _ownedSub?.cancel();
    _joinedSub?.cancel();
    _notifSub?.cancel();
    super.onClose();
  }

  // ---------------------- Group avatar ----------------------

  void setGroupAvatar(Uint8List bytes, String extension) {
    avatarBytes = bytes;
    avatarExt = extension;
    update();
  }

  Future<String?> _uploadGroupIcon() async {
    if (avatarBytes == null) return null;

    try {
      final storage = FirebaseStorage.instance;
      final fileName =
          'group_icons/${DateTime.now().millisecondsSinceEpoch}.$avatarExt';
      final ref = storage.ref().child(fileName);

      final snapshot = await ref.putData(avatarBytes!);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading group icon: $e');
      return null;
    }
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
        // FIXED: Exclude groups the user owns from "joined"
        final joinedWithoutOwned =
        list.where((g) => (g.createdBy ?? '') != myUid).toList();
        joinedGroups.assignAll(joinedWithoutOwned);
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

  // ---------------------- Group search helpers ----------------------

  /// Call this from the Chat Room search bar
  void setGroupSearch(String q) {
    groupSearchQuery.value = q.trim();
  }

  /// Optional: wire to a clear button
  void clearGroupSearch() {
    groupSearchQuery.value = '';
  }

  bool _matchGroup(Group g, String q) {
    if (q.isEmpty) return true;
    final needle = q.toLowerCase();

    final name = (g.name ?? '').toLowerCase();
    final lastMsg = (g.lastMessage ?? '').toLowerCase();

    return name.contains(needle) || lastMsg.contains(needle);
  }

  void _recomputeGroupFilters() {
    final q = groupSearchQuery.value;
    filteredOwned.assignAll(ownedGroups.where((g) => _matchGroup(g, q)));
    filteredJoined.assignAll(joinedGroups.where((g) => _matchGroup(g, q)));
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

  // ---------------------- Pagination / Users (add members) ----------------------

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
        q = FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: false)
            .limit(pageSize);
        if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);

        try {
          snap = await q.get();
        } on FirebaseException {
          q = FirebaseFirestore.instance
              .collection('users')
              .orderBy(FieldPath.documentId)
              .limit(pageSize);
          if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
          snap = await q.get();
        }
      } else {
        final qLower = query.value.toLowerCase();

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

  // ---------------------- Selection helpers ----------------------

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

  // ---------------------- Submit (create group + invites) ----------------------

  Future<String> submit() async {
    final n = name.value.trim();
    if (n.isEmpty) throw 'Group name is required';
    if (selected.isEmpty) throw 'Pick at least one member';

    isSubmitting.value = true;
    try {
      // Upload group icon if exists
      final String? groupIconUrl = await _uploadGroupIcon();

      // Build members data
      final membersData = <Map<String, dynamic>>[];
      for (final uid in selected) {
        final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          membersData.add({
            'uid': uid,
            'email': userData['email'] ?? '',
            'displayName': userData['name'] ??
                userData['displayName'] ??
                'User', // prefer 'name'
            'photoURL': userData['photoUrl'] ??
                userData['photoURL'] ??
                userData['imageUrl'] ??
                '',
            'joinedAt': FieldValue.serverTimestamp(),
            'role': 'member',
          });
        }
      }

      // Add current user as admin
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(myUid)
          .get();
      if (currentUserDoc.exists) {
        final userData = currentUserDoc.data()!;
        membersData.add({
          'uid': myUid,
          'email': userData['email'] ?? '',
          'displayName':
          userData['name'] ?? userData['displayName'] ?? 'User',
          'photoURL':
          userData['photoUrl'] ?? userData['photoURL'] ?? userData['imageUrl'] ?? '',
          'joinedAt': FieldValue.serverTimestamp(),
          'role': 'admin',
        });
      }

      final gid = await ChatService.instance.createGroupFlow(
        name: n,
        memberIds: selected.toList(),
        avatarBytes: avatarBytes,
        avatarFileExt: avatarExt,
        groupIconUrl: groupIconUrl,
        permissions: permissions,
        membersData: membersData,
      );

      // Send invites
      for (final uid in selected) {
        await ChatService.instance.sendGroupInvite(
          groupId: gid,
          receiverId: uid,
        );
      }

      // Clear avatar after successful creation
      avatarBytes = null;

      return gid;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Create and jump back to ChatRoom
  Future<void> createGroupAndNavigate() async {
    try {
      final groupId = await submit();
      if (groupId.isNotEmpty) {
        Get.snackbar('Success', 'Group created successfully!');
        Get.offAll(() => const ChatRoom());
        selected.clear();
        name.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create group: $e');
      rethrow;
    }
  }

  // ---------------------- Invites ----------------------

  Future<void> inviteSelectedToExistingGroup(String groupId) async {
    if (selected.isEmpty) {
      throw 'Pick at least one member';
    }
    isSubmitting.value = true;
    try {
      await ChatService.instance.inviteMembersToGroup(
        groupId: groupId,
        newMemberIds: selected.toList(),
      );
      selected.clear();
      showCommonSnackbarWidget('Success', 'Invites sent successfully');
    } catch (e) {
      showCommonSnackbarWidget('Error', 'Failed to send invites: $e');
      rethrow;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> acceptInvite(AppNotification notif) async {
    isAccepting.value = true;
    try {
      final gid = await ChatService.instance.respondToInviteByGroup(
        groupId: notif.groupId ?? "",
        accepted: true,
      );
      showCommonSnackbarWidget(
          'Invite Accepted', 'You have joined ${notif.groupName}');
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
      showCommonSnackbarWidget(
          'Invite Rejected', 'Invite from ${notif.senderName} rejected');
    } catch (e) {
      // ignore: avoid_print
      print(e);
      showCommonSnackbarWidget('Error', 'Failed to reject invite: $e');
    } finally {
      isRejecting.value = false;
    }
  }
}
