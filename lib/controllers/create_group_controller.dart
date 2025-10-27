import 'dart:async';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  StreamSubscription? _ownedSub;
  StreamSubscription? _joinedSub;
  // Selection (selected userIds; creator is auto-included by service)
  final selected = <String>{}.obs;
  final selectedUsers = <String, Map<String, dynamic>>{}.obs;
  // Users page
  final users = <Map<String, dynamic>>[].obs;
  final int pageSize = 50;
  DocumentSnapshot<Map<String, dynamic>>? _lastSnap;
  String userName = "";  // Optional avatar
  Uint8List? avatarBytes;
  String avatarExt = 'jpg';

  final showInitialLoader = true.obs;
  final notifications = <AppNotification>[].obs;
  final isLoadingNotifications = false.obs;
  final isAccepting = false.obs;
  final isRejecting = false.obs;
  bool _gotOwned = false;
  bool _gotJoined = false;
  bool _gotNotifs = false;


  String get myUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    // initial load
    _loadFirstPage();

    // re-run search when query changes
    ever<String>(query, (_) => _loadFirstPage());
    _bindNotifications();
    _bindGroups();
    
  }



 void _maybeHideInitialLoader() {
    if (_gotOwned && _gotJoined && _gotNotifs ) {
      // Hide just once
      if (showInitialLoader.value) showInitialLoader.value = false;
    }
  }


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
        // Consider first attempt "done" so loader doesn't hang forever
        if (!_gotOwned) {
          _gotOwned = true;
          _maybeHideInitialLoader();
        }
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
        print('joinedGroups stream error: $e');
      },
    );
  }


  // ---- Pagination ----
  Future<void> _loadFirstPage() async {
    users.clear();
    _lastSnap = null;
    hasMore.value = true;
    await loadNextPage();
  }



  @override
  void onClose() {
    _ownedSub?.cancel();
    _joinedSub?.cancel();
    super.onClose();
  }



  /// Accept a group invitation (by groupId; we derive the deterministic invite id)
  Future<void> acceptInvite(AppNotification notif) async {
    isAccepting.value = true;
    try {
      // derive deterministic notificationId internally
      final gid = await ChatService.instance.respondToInviteByGroup(
        groupId: notif.groupId ?? "", // safer than notif.id
        accepted: true,
      );
      showCommonSnackbarWidget('Invite Accepted', 'You’ve joined ${notif.groupName}');
      if (gid != null) {
        // Navigate to chat if you want:
        Get.to(() => ChatScreen(groupId: gid));
      isAccepting.value = false;

      }
    } catch (e) {
      print(e);
      showCommonSnackbarWidget('Error', 'Failed to accept invite: $e');
    } finally {
      isAccepting.value = false;
    }
  }

  /// Reject a group invitation (by groupId; derive deterministic invite id)
  Future<void> rejectInvite(AppNotification notif) async {
    isRejecting.value = true;
    try {
      await ChatService.instance.respondToInviteByGroup(
        groupId: notif.groupId ?? "",
        accepted: false,
      );
      showCommonSnackbarWidget('Invite Rejected', 'Invite from ${notif.senderName} rejected');
    } catch (e) {
      print(e);
      showCommonSnackbarWidget('Error', 'Failed to reject invite: $e');
    } finally {
      isRejecting.value = false;
    }
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
        // Fallback if 'createdAt' missing/index not built
        q = FirebaseFirestore.instance
            .collection('users')
            .orderBy(FieldPath.documentId)
            .limit(pageSize);
        if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
        snap = await q.get();
      }
    } else {
      final qLower = query.value.toLowerCase();
      q = FirebaseFirestore.instance
          .collection('users')
          .where('displayName_lower', isGreaterThanOrEqualTo: qLower)
          .where('displayName_lower', isLessThan: '$qLower\uf8ff')
          .orderBy('displayName_lower')             
          .limit(pageSize);
      if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
      snap = await q.get();
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


  void _bindNotifications() {
    isLoadingNotifications.value = true;
    try {
      ChatService.instance.userNotifications().listen((list) {
        notifications.assignAll(list);
        isLoadingNotifications.value = false;

        if (!_gotNotifs) {
          _gotNotifs = true;
          _maybeHideInitialLoader();
        }
      }, onError: (err) {
        isLoadingNotifications.value = false;
        if (!_gotNotifs) {
          _gotNotifs = true; 
          _maybeHideInitialLoader();
        }
        print('Notification stream error: $err');
      });
    } catch (e) {
      isLoadingNotifications.value = false;
      if (!_gotNotifs) {
        _gotNotifs = true;
        _maybeHideInitialLoader();
      }
      print('Failed to bind notifications: $e');
    }
  }


 
  void toggleUser(Map<String, dynamic> user) {
    final uid = user['id'] as String;
    if (selectedUsers.containsKey(uid)) {
      selectedUsers.remove(uid);
    } else {
      selectedUsers[uid] = user;
    }
  }


  // Back-compat: toggle by uid (find the user map from current 'users' list)
  void toggle(String uid) {
    final user = users.firstWhereOrNull((u) => u['id'] == uid);
    if (user == null) return; // or fetch if needed
    toggleUser(user);
  }

  void selectAllVisible() {
    for (final u in users) {
      final uid = u['id'] as String;
      if (uid == myUid) continue;
      selectedUsers[uid] = u;
    }
  }


  void clearSelection() => selected.clear();

  // ---- Submit ----
  
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
