import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:manifesto_md/models/chat_message_model.dart';

class ChatService {
  static final ChatService instance = ChatService._internal();
  ChatService._internal();

  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  // ---------- helpers (were missing) ----------
  CollectionReference<Map<String, dynamic>> _groups() => _fs.collection('groups');
  DocumentReference<Map<String, dynamic>> _group(String id) => _groups().doc(id);
  CollectionReference<Map<String, dynamic>> _msgs(String gid) => _group(gid).collection('messages');

  // ---- USERS ----
  // Simple user model: { uid, displayName, photoURL, email, displayName_lower }
  Stream<List<Map<String, dynamic>>> searchUsers(String q, {int limit = 20}) {
    final col = _fs.collection('users');
    if (q.trim().isEmpty) {
      return col.limit(limit).snapshots().map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
    }
    final qLower = q.toLowerCase();
    return col
        .where('displayName_lower', isGreaterThanOrEqualTo: qLower)
        .where('displayName_lower', isLessThan: '$qLower\uf8ff')
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }


  Future<String> createGroupFlow({
  required String name,
  required List<String> memberIds, // don't include current user; we'll add automatically
  Uint8List? avatarBytes,
  String avatarFileExt = 'jpg',
  String? description,
}) async {
  final uid = _auth.currentUser!.uid;
  final groupRef = _groups().doc(); // pre-generate id
  final now = FieldValue.serverTimestamp();

  final uniqueMembers = {...memberIds, uid}.toList();

  // 1) Create the group FIRST (so rules that check isOwner() pass afterwards)
  await groupRef.set({
    'name': name.trim(),
    'createdBy': uid,
    'createdAt': now,
    'memberCount': uniqueMembers.length,
    'avatarUrl': null,
    'description': description,
    'lastMessage': null,
    'lastMessageAt': null,
  });

  // 2) Then add members in a batch
  final batch = _fs.batch();
  for (final m in uniqueMembers) {
    batch.set(groupRef.collection('members').doc(m), {
      'uid': m,
      'role': m == uid ? 'owner' : 'member',
      'joinedAt': now,
      'lastReadAt': now,
      'isMuted': false,
    });
  }
  await batch.commit();

  // 3) Optional avatar upload
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



  // In lib/services/chat_service.dart (inside ChatService)

/// Stream all users with pagination. If `query` is empty, it loads pages of all users.
/// If `query` is non-empty, it uses your search (displayName_lower prefix).
Stream<List<Map<String, dynamic>>> allUsersPage({
  String query = '',
  int pageSize = 50,
  DocumentSnapshot? startAfter,
}) async* {
  Query<Map<String, dynamic>> q;

  if (query.trim().isEmpty) {
    // No search: list everyone (order by createdAt if you have it; otherwise by uid)
    q = _fs.collection('users')
        .orderBy('createdAt', descending: false) // fallback to another field if needed
        .limit(pageSize);
  } else {
    final qLower = query.toLowerCase();
    q = _fs.collection('users')
        .where('displayName_lower', isGreaterThanOrEqualTo: qLower)
        .where('displayName_lower', isLessThan: '$qLower\uf8ff')
        .limit(pageSize);
  }

  if (startAfter != null) q = q.startAfterDocument(startAfter);

  yield* q.snapshots().map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
}


  // ---- MESSAGES ----
  Stream<List<ChatMessage>> messagesStream(String groupId, {int limit = 200}) {
    return _msgs(groupId)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(ChatMessage.fromDoc).toList());
  }

  /// Send a text message (meets your rules: id==docId, groupId==path, senderId==auth, type, createdAt==server)
  Future<void> sendTextMessage({
    required String groupId,
    required String text,
  }) async {
    final user = _auth.currentUser!;
    final msgRef = _msgs(groupId).doc();

    await msgRef.set({
      'id': msgRef.id,
      'groupId': groupId,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'User',
      'text': text.trim(),
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update group preview (will throw permission-denied for non-owners unless you apply the rule tweak; we swallow that).
    try {
      await _group(groupId).update({
        'lastMessage': text.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }
  }

  /// Edit a message (requires rules that allow author updates; see notes)
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

  /// Hard delete (requires rules to allow author/owner delete; see notes)
  Future<void> deleteMessage({
    required String groupId,
    required String messageId,
  }) async {
    await _msgs(groupId).doc(messageId).delete();
  }

  /// Soft delete alternative (update only)
  Future<void> softDeleteMessage({
    required String groupId,
    required String messageId,
  }) async {
    await _msgs(groupId).doc(messageId).update({
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---- TYPING ----
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