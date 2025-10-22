import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:manifesto_md/models/chat_message_model.dart';
import 'package:manifesto_md/models/groups_model.dart';
import 'package:manifesto_md/models/notifications_model.dart';
import 'package:manifesto_md/models/user_group_model.dart';

/// Central Firestore + Storage chat service.
/// Handles groups, messages, typing indicators, and notifications.
class ChatService {
  static final ChatService instance = ChatService._internal();
  ChatService._internal();

  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  // ---------------------------------------------------------------------------
  // COLLECTION HELPERS
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _groups() => _fs.collection('groups');
  DocumentReference<Map<String, dynamic>> _group(String id) => _groups().doc(id);
  CollectionReference<Map<String, dynamic>> _msgs(String gid) => _group(gid).collection('messages');
  CollectionReference<Map<String, dynamic>> _notifications() => _fs.collection('notifications');
  String _inviteId(String groupId, String receiverId) => '${groupId}_$receiverId';

  // ---------------------------------------------------------------------------
  // USER SEARCH
  // ---------------------------------------------------------------------------

  Stream<List<Map<String, dynamic>>> searchUsers(
  String q, {
  required String groupId,
  int limit = 20,
}) async* {
  final usersCol = _fs.collection('users');

  // 🔹 Step 1: Fetch already accepted member IDs
  final memberSnap = await _group(groupId)
      .collection('members')
      .where('status', isEqualTo: 'accepted')
      .get();

  final acceptedIds = memberSnap.docs.map((d) => d.id).toSet();

  // 🔹 Step 2: Build search query
  final qLower = q.trim().toLowerCase();
  Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  if (qLower.isEmpty) {
    stream = usersCol.limit(limit).snapshots();
  } else {
    stream = usersCol
        .where('displayName_lower', isGreaterThanOrEqualTo: qLower)
        .where('displayName_lower', isLessThan: '$qLower\uf8ff')
        .limit(limit)
        .snapshots();
  }

  // 🔹 Step 3: Filter out accepted members from stream
  yield* stream.map((snap) {
    return snap.docs
        .where((d) => !acceptedIds.contains(d.id))
        .map((d) => {'id': d.id, ...d.data()})
        .toList();
  });
}


/// Allow any accepted member or owner to invite new users to a group.
Future<void> inviteMembersToGroup({
  required String groupId,
  required List<String> newMemberIds,
}) async {
  final currentUser = _auth.currentUser!;
  final uid = currentUser.uid;

  // 1️⃣ Check if current user is an accepted member or owner
  final memberSnap = await _group(groupId)
      .collection('members')
      .doc(uid)
      .get();

  if (!memberSnap.exists) {
    throw Exception('You are not a member of this group.');
  }

  final memberData = memberSnap.data()!;
  final role = memberData['role'] ?? 'member';
  final status = memberData['status'] ?? 'pending';

  if (status != 'accepted' && role != 'owner') {
    throw Exception('Only accepted members can invite others.');
  }



  final groupSnap = await _group(groupId).get();
  if (!groupSnap.exists) throw Exception('Group not found');
  final group = groupSnap.data()!;


  for (final newMemberId in newMemberIds) {
    final notifId = _inviteId(groupId, newMemberId);
    await _notifications().doc(notifId).set({
      'type': 'group_invite',
      'senderId': uid,
      'senderName': currentUser.displayName ?? 'User',
      'receiverId': newMemberId,
      'groupId': groupId,
      'groupName': group['name'] ?? 'Group',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: false));
  }
}


  // ---------------------------------------------------------------------------
  // GROUP CREATION FLOW
  // ---------------------------------------------------------------------------
Future<String> createGroupFlow({
  required String name,
 
  required List<String> memberIds, 
  Uint8List? avatarBytes,
  String avatarFileExt = 'jpg',
  String? description,
}) async {
  final uid = _auth.currentUser!.uid;
  final groupRef = _groups().doc();
  final now = FieldValue.serverTimestamp();

  // 1️Create group metadata (memberCount starts at 1: the owner)
  await groupRef.set({
    'name': name.trim(),
    'createdBy': uid,
    'createdAt': now,
    'memberCount': 1,                
    'avatarUrl': null,
    'description': description,
    'lastMessage': null,
    'lastMessageAt': null,
  });


  await groupRef.collection('members').doc(uid).set({
    'uid': uid,
    'role': 'owner',
    'joinedAt': now,
    'lastReadAt': now,
    'isMuted': false,
    
  });


  if (avatarBytes != null && avatarBytes.isNotEmpty) {
    final path = 'group_avatars/${groupRef.id}/avatar.$avatarFileExt';
    final task = await _storage.ref(path).putData(
      avatarBytes,
      SettableMetadata(
        contentType: _guessContentType(avatarFileExt),
        cacheControl: 'public,max-age=3600',
      ),
    );
    final url = await task.ref.getDownloadURL();
    await groupRef.update({'avatarUrl': url});
  }

  // 4️⃣ DO NOT add invitees as members here. Your controller will call sendGroupInvite() for each.
  return groupRef.id;
}



  String _guessContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ---------------------------------------------------------------------------
  // INVITES & NOTIFICATIONS
  // ---------------------------------------------------------------------------

  /// Creates a Firestore notification (and optional FCM trigger).
Future<void> sendGroupInvite({
  required String groupId,
  required String receiverId,
}) async {
  final sender = _auth.currentUser!;
  final groupSnap = await _group(groupId).get();
  if (!groupSnap.exists) throw Exception('Group not found');
  final group = groupSnap.data() ?? {};

  // REQUIRED by your rules: notifications/{groupId}_{receiverId}
  final notifId = '${groupId}_$receiverId';

  await _notifications().doc(notifId).set({
    'type': 'group_invite',
    'senderId': sender.uid,
    'senderName': sender.displayName ?? 'User',
    'receiverId': receiverId,
    'groupId': groupId,
    'groupName': group['name'] ?? 'Group',
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: false));
}


  /// Stream all notifications for the current user (live updates)
Stream<List<AppNotification>> userNotifications() {
  final uid = _auth.currentUser!.uid;

  return _notifications()
      .where('receiverId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
}


Stream<List<String>> acceptedMemberIdsStream(String groupId) {
  return _group(groupId)
      .collection('members')
      .where('status', isEqualTo: 'accepted')
      .snapshots()
      .map((s) => s.docs.map((d) => (d.data()['uid'] as String?) ?? d.id).toList());
}




/// Live stream of accepted members' profiles:
/// - listens /groups/{gid}/members where status=='accepted'
/// - for each member uid, listens to BOTH:
///     a) /groups/{gid}/members/{uid}
///     b) /users/{uid}
/// - merges them so you get the best name/photo, not just email
Stream<List<UserLite>> acceptedMembersProfilesStream(String groupId) {
  final controller = StreamController<List<UserLite>>.broadcast();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberIdsSub;
  // For each uid, we hold two subs: member-doc sub and user-doc sub
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>> memberDocSubs = {};
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>> userDocSubs = {};

  // Latest cached values to merge
  final Map<String, UserLite?> latestMemberLite = {}; // from member doc
  final Map<String, UserLite?> latestUserLite = {};   // from users doc

  void emit() {
    final out = <UserLite>[];
    final uids = <String>{
      ...latestMemberLite.keys,
      ...latestUserLite.keys,
    };
    for (final uid in uids) {
      final merged = UserLite.merge(latestUserLite[uid], latestMemberLite[uid]);
      out.add(merged);
    }
    // Optional: stable sort (by display name, then uid)
    out.sort((a, b) {
      final an = a.displayName ?? a.email ?? a.uid;
      final bn = b.displayName ?? b.email ?? b.uid;
      final cmp = an.toLowerCase().compareTo(bn.toLowerCase());
      if (cmp != 0) return cmp;
      return a.uid.compareTo(b.uid);
    });
    controller.add(out);
  }

  // Subscribe to accepted members list
  memberIdsSub = FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('members')
      .where('status', isEqualTo: 'accepted')
      .snapshots()
      .listen((snap) {
    final ids = snap.docs
        .map((d) => (d.data()['uid'] as String?) ?? d.id)
        .toSet();

    // Unsubscribe removed users
    for (final uid in List<String>.from(memberDocSubs.keys)) {
      if (!ids.contains(uid)) {
        memberDocSubs[uid]?.cancel();
        memberDocSubs.remove(uid);
        latestMemberLite.remove(uid);
      }
    }
    for (final uid in List<String>.from(userDocSubs.keys)) {
      if (!ids.contains(uid)) {
        userDocSubs[uid]?.cancel();
        userDocSubs.remove(uid);
        latestUserLite.remove(uid);
      }
    }

    // Subscribe new users (both member doc and users doc)
    for (final uid in ids) {
      if (!memberDocSubs.containsKey(uid)) {
        memberDocSubs[uid] = FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('members')
            .doc(uid)
            .snapshots()
            .listen((d) {
          if (d.exists) {
            latestMemberLite[uid] = UserLite.fromMemberDoc(d);
          } else {
            latestMemberLite.remove(uid);
          }
          emit();
        }, onError: (_) {
          latestMemberLite.remove(uid);
          emit();
        });
      }

      if (!userDocSubs.containsKey(uid)) {
        userDocSubs[uid] = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots()
            .listen((d) {
          if (d.exists) {
            latestUserLite[uid] = UserLite.fromUserDoc(d);
          } else {
            latestUserLite.remove(uid);
          }
          emit();
        }, onError: (_) {
          latestUserLite.remove(uid);
          emit();
        });
      }
    }

    // Emit after membership changes as well
    emit();
  });

  controller.onCancel = () async {
    await memberIdsSub?.cancel();
    for (final s in memberDocSubs.values) {
      await s.cancel();
    }
    for (final s in userDocSubs.values) {
      await s.cancel();
    }
    memberDocSubs.clear();
    userDocSubs.clear();
    latestMemberLite.clear();
    latestUserLite.clear();
  };

  return controller.stream;
}

/// Accept/reject by **groupId** (we derive the deterministic notificationId).
  /// If accepted: batch self-join + increment memberCount (+1).
  /// Returns groupId for navigation.
  Future<String?> respondToInviteByGroup({
    required String groupId,
    required bool accepted,
  }) async {
    final uid = _auth.currentUser!.uid;
    final notificationId = _inviteId(groupId, uid);
    return respondToInvite(notificationId: notificationId, accepted: accepted);
  }



   /// Accept/reject by notificationId (must be deterministic).
  /// If accepted: batch self-join + increment memberCount (+1).
  /// Returns groupId for navigation.
  Future<String?> respondToInvite({
    required String notificationId,
    required bool accepted,
  }) async {
    final notifRef = _notifications().doc(notificationId);
    final snap = await notifRef.get();
    if (!snap.exists) return null;

    final data = snap.data()!;
    final groupId = data['groupId'] as String;
    final uid = _auth.currentUser!.uid;

    // 1) Flip invite status (rules: onlyChangedKeys(['status','respondedAt']))
    await notifRef.update({
      'status': accepted ? 'accepted' : 'rejected',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    if (!accepted) return groupId;

    // 2) Batch: self-join + memberCount +1 (matches your narrow rule)
    final batch = _fs.batch();
    final memberRef = _group(groupId).collection('members').doc(uid);
    final groupRef = _group(groupId);

    batch.set(memberRef, {
      'uid': uid,
      'role': 'member',
      'status': 'accepted', 
      'joinedAt': FieldValue.serverTimestamp(),   
      'lastReadAt': FieldValue.serverTimestamp(), 
      'isMuted': false,
      
    }, SetOptions(merge: false)); 

    batch.update(groupRef, {
      'memberCount': FieldValue.increment(1),     
    });

    await batch.commit();
    return groupId;
  }



/// Updates ONLY the chat preview fields on a group doc.
/// - lastMessage: a short preview string
/// - lastMessageAt: server timestamp (now)
Future<void> updateGroupPreview({
  required String groupId,
  required String preview,
}) async {
  final p = preview.trim();
  try {
    await _group(groupId).update({
      'lastMessage': p.isEmpty ? 'No message yet' : p,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  } on FirebaseException catch (e) {
    // Silently ignore permission-denied so UI doesn't crash,
    // rethrow anything else so it surfaces during dev.
    if (e.code != 'permission-denied') rethrow;
  }
}




Future<Group?> getGroupOnce(String groupId) async {
    final d = await _group(groupId).get();
    return d.exists ? Group.fromDoc(d) : null;
    }

  Stream<Group?> groupStream(String groupId) {
    return _group(groupId).snapshots().map((d) => d.exists ? Group.fromDoc(d) : null);
  }
  

  /// Stream **all** my groups with role by joining on collectionGroup('members')
  Stream<List<Group>> myGroupsWithRoleStream() {
    final uid = _auth.currentUser!.uid;
    return _fs.collectionGroup('members')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .asyncMap((memberSnaps) async {
          final futures = memberSnaps.docs.map((m) async {
            final role = (m.data()['role'] as String?) ?? 'member';
            final groupRef = m.reference.parent.parent!;
            final g = await groupRef.get();
            if (!g.exists) return null;
            return Group.fromDoc(g, myRole: role);
          });
          final list = await Future.wait(futures);
          return list.whereType<Group>().toList();
        });
  }


 

  /// Owned groups (role == 'owner')
 /// Owned groups: read /groups where createdBy == me
Stream<List<Group>> ownedGroupsStream() {
  final uid = _auth.currentUser!.uid;

  // This hits /groups docs directly; rule passes via isOwner(groupId).
  return _groups()
      .where('createdBy', isEqualTo: uid)
      .snapshots()
      .map((snap) => snap.docs.map(Group.fromDoc).toList());
}

Stream<List<Group>> joinedGroupsStream() {
  final uid = _auth.currentUser!.uid;

  final memberRows$ = _fs.collectionGroup('members')
      .where('uid', isEqualTo: uid)
      .where('role', isEqualTo: 'member')
      .where('status', isEqualTo: 'accepted')
      .snapshots();

  return memberRows$.asyncMap((snap) async {
    final futures = snap.docs.map((m) async {
      try {
        final groupRef = m.reference.parent.parent!;
        final g = await groupRef.get();           // may 403 if rules say no
        if (!g.exists) return null;
        return Group.fromDoc(g, myRole: 'member');
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          // Silently skip groups you’re not allowed to read
          return null;
        }
        rethrow;
      }
    });
    final list = await Future.wait(futures);
    return list.whereType<Group>().toList();
  });
}


  // -------------------------------------------------------------------------
  // MESSAGES
  // ---------------------------------------------------------------------------

  Stream<List<ChatMessage>> messagesStream(String groupId,
  
      {int limit = 200}) {
    return _msgs(groupId)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(ChatMessage.fromDoc).toList());
  }

  Future<void> sendTextMessage({
    required String groupId,
    required String text,
   required  String senderName,
  }) async {
    final user = _auth.currentUser!;
    final msgRef = _msgs(groupId).doc();

    await msgRef.set({
      'id': msgRef.id,
      'groupId': groupId,
      'senderId': user.uid,
      'senderName': senderName,
      'text': text.trim(),
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await updateGroupPreview(groupId: groupId, preview: text.trim());

    // Update group last message (ignore permission-denied silently)
    try {
      await _group(groupId).update({
        'lastMessage': text.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }
  }

  Future<void> editMessage({
    required String groupId,
    required String messageId,
    required String newText,
  }) async {
    await _msgs(groupId).doc(messageId).update({
      'text': newText.trim(),
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMessage({
    required String groupId,
    required String messageId,
  }) async {
    await _msgs(groupId).doc(messageId).delete();
  }

  Future<void> softDeleteMessage({
    required String groupId,
    required String messageId,
  }) async {
    await _msgs(groupId).doc(messageId).update({
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // TYPING STATUS
  // ---------------------------------------------------------------------------

  Future<void> setTyping(String groupId, bool isTyping) async {
    final uid = _auth.currentUser!.uid;
    await _group(groupId).collection('typing').doc(uid).set({
      'uid': uid,
      'isTyping': isTyping,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Set<String>> typingUsers(String groupId) {
    return _group(groupId).collection('typing').snapshots().map((snap) {
      final now = DateTime.now();
      return snap.docs.where((d) {
        final isTyping = d.data()['isTyping'] == true;
        final ts = (d.data()['updatedAt'] as Timestamp?)?.toDate();
        return isTyping && ts != null && now.difference(ts).inSeconds <= 5;
      }).map((d) => d.id).toSet();
    });
  }
}
