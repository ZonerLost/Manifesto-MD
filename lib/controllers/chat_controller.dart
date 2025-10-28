// lib/controllers/chat_controller.dart
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../models/chat_message_model.dart';
import '../models/user_group_model.dart';

class ChatController extends GetxController {
  ChatController(this.groupId);
  final String groupId;

  // Services
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // UI/state
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<ChatMessage> filteredMessages = <ChatMessage>[].obs;
  final RxBool isSending = false.obs;
  final RxList<UserLite> members = <UserLite>[].obs;
  final TextEditingController input = TextEditingController();

  // Search
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  // Typing
  final RxList<String> typingUsers = <String>[].obs;
  Timer? _typingClearTimer;

  // Subscriptions
  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _membersSub;

  String get userId => _auth.currentUser?.uid ?? '';
  String get userEmail => _auth.currentUser?.email ?? '';
  String get userName =>
      _auth.currentUser?.displayName ??
          (userEmail.isNotEmpty ? userEmail.split('@').first : 'User');

  // ---- Firestore paths ------------------------------------------------------
  DocumentReference get _groupRef => _fs.collection('groups').doc(groupId);
  CollectionReference get _msgCol => _groupRef.collection('messages');
  CollectionReference get _typingCol => _groupRef.collection('typing');

  // ---- lifecycle ------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    _loadMessages();
    _loadGroupMembers();
    _listenToTyping();

    // Listen to search query changes
    ever(searchQuery, (query) {
      if (query.isEmpty) {
        isSearching.value = false;
        filteredMessages.assignAll(messages);
      } else {
        isSearching.value = true;
        _filterMessages(query);
      }
    });
  }

  void _loadMessages() {
    // FIXED: Changed to ascending order to show latest messages at bottom (WhatsApp style)
    _msgSub = _msgCol
        .orderBy('sentAt', descending: false) // Ascending order - oldest first
        .snapshots()
        .listen((q) async {
      final list = q.docs.map((d) => ChatMessage.fromDoc(d)).toList();
      messages.assignAll(list);

      // Apply search filter if active
      if (searchQuery.value.isNotEmpty) {
        _filterMessages(searchQuery.value);
      } else {
        filteredMessages.assignAll(list);
      }

      // mark unread as read for me
      await markAllVisibleAsRead();
    });
  }

  void _loadGroupMembers() {
    _membersSub = _fs
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .asyncMap((groupDoc) async {
      final groupData = groupDoc.data() as Map<String, dynamic>?;
      if (groupData == null) return <UserLite>[];

      final memberIds = List<String>.from(groupData['memberIds'] ?? []);
      final memberNames = Map<String, String>.from(groupData['memberNames'] ?? {});
      final memberEmails = Map<String, String>.from(groupData['memberEmailsMap'] ?? {});
      final memberPhotos = Map<String, String>.from(groupData['memberPhotos'] ?? {});

      final membersList = <UserLite>[];
      for (final memberId in memberIds) {
        membersList.add(UserLite(
          uid: memberId,
          displayName: memberNames[memberId] ?? 'User',
          email: memberEmails[memberId] ?? '',
          photoURL: memberPhotos[memberId] ?? '',
        ));
      }
      return membersList;
    }).listen((membersList) {
      members.assignAll(membersList);
    });
  }

  void _listenToTyping() {
    _typingSub = _typingCol
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((q) {
      final now = DateTime.now();
      final active = <String>[];
      for (final d in q.docs) {
        if (d.id == userId) continue;
        final data = d.data() as Map<String, dynamic>;
        final ts = (data['timestamp'] as Timestamp?)?.toDate();
        final isTyping = data['isTyping'] == true;
        if (isTyping && ts != null && now.difference(ts).inSeconds < 3) {
          active.add((data['userName'] ?? 'User').toString());
        }
      }
      typingUsers.assignAll(active);
    });
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _membersSub?.cancel();
    _stopTyping();
    super.onClose();
  }

  // ---- Search functionality -------------------------------------------------

  void _filterMessages(String query) {
    if (query.isEmpty) {
      filteredMessages.assignAll(messages);
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = messages.where((message) {
      return message.message.toLowerCase().contains(lowerQuery) ||
          (message.userName ?? '').toLowerCase().contains(lowerQuery);
    }).toList();

    filteredMessages.assignAll(filtered);
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
  }

  // ---- typing ---------------------------------------------------------------
  void onTypingChanged(bool typing) {
    if (typing) {
      _typingCol.doc(userId).set({
        'isTyping': true,
        'userId': userId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _typingClearTimer?.cancel();
      _typingClearTimer = Timer(const Duration(seconds: 2), _stopTyping);
    } else {
      _stopTyping();
    }
  }

  void _stopTyping() {
    _typingClearTimer?.cancel();
    _typingCol.doc(userId).delete();
  }

  // ---- send text / attachments / media -------------------------------------
  Future<void> send(String senderDisplayName) async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    isSending.value = true;
    try {
      await _sendMessage(
        message: text,
        type: 'text',
        replyTo: _replyingTo,
      );
      // Text field is cleared in the UI immediately after this method
    } finally {
      isSending.value = false;
      onTypingChanged(false);
    }
  }

  Map<String, dynamic>? _replyingTo;
  void setReplyTo(Map<String, dynamic>? data) => _replyingTo = data;

  Future<void> sendAttachmentBundle({
    required List<Map<String, dynamic>> atts,
    String text = '',
  }) async {
    if (atts.isEmpty && text.trim().isEmpty) return;
    await _sendMessage(
      message: text.trim().isEmpty ? 'Sent ${atts.length} file(s)' : text.trim(),
      type: atts.length == 1 ? 'file' : 'files',
      attachments: atts,
      replyTo: _replyingTo,
    );
    _replyingTo = null;
  }

  Future<void> _sendMessage({
    required String message,
    required String type,
    String? mediaUrl,
    Map<String, dynamic>? replyTo,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final me = _auth.currentUser;
    if (me == null) return;

    final data = {
      'message': message,
      'type': type, // text | image | video | file | files
      'mediaUrl': mediaUrl,
      'attachments': attachments,
      'replyTo': replyTo,
      'sentAt': FieldValue.serverTimestamp(),
      'userId': me.uid,
      'userName': me.displayName ?? (me.email?.split('@').first ?? 'You'),
      'photoUrl': me.photoURL,
      'status': 'sent',
      'readBy': [me.uid],
      'reactions': <String, dynamic>{},
    };

    await _msgCol.add(data);

    // bump group preview
    await _groupRef.set({
      'lastMessage': type == 'text' ? message : '[${type.toUpperCase()}]',
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // camera/gallery
  Future<String?> pickAndUploadMedia({
    required bool isVideo,
    required ImageSource source,
    int imgMaxW = 1024,
    int imgMaxH = 1024,
    int imgQuality = 85,
    int maxImageMB = 20,
    int maxVideoMB = 100,
  }) async {
    final picked = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(
      source: source,
      maxWidth: imgMaxW.toDouble(),
      maxHeight: imgMaxH.toDouble(),
      imageQuality: imgQuality,
    );
    if (picked == null) return null;

    final file = File(picked.path);
    final sizeMB = (await file.length()) / (1024 * 1024);
    if (!isVideo && sizeMB > maxImageMB) return null;
    if (isVideo && sizeMB > maxVideoMB) return null;

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    final ref = _storage
        .ref()
        .child('groups/$groupId/media/$fileName');

    final ext = p.extension(fileName).replaceFirst('.', '').toLowerCase();
    final contentType =
        (isVideo ? 'video/' : 'image/') + (ext.isEmpty ? (isVideo ? 'mp4' : 'jpeg') : ext);

    await ref.putFile(file, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  Future<List<PlatformFile>?> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf','doc','docx','xls','xlsx','ppt','pptx',
        'txt','zip','jpg','jpeg','png','gif','webp','heic','heif','mp4','mov','m4v','webm'
      ],
    );
    return result?.files;
  }

  Future<String?> uploadFileAttachment(PlatformFile f,
      {int maxMB = 50}) async {
    if (f.path == null) return null;
    final file = File(f.path!);
    final sizeMB = (await file.length()) / (1024 * 1024);
    if (sizeMB > maxMB) return null;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${f.name}';
    final ref = _storage.ref().child('groups/$groupId/attachments/$fileName');

    final ext = p.extension(fileName).toLowerCase();
    final contentType = _guessContentType(ext);

    await ref.putFile(file, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  String _guessContentType(String ext) {
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      case '.ppt':
      case '.pptx':
        return 'application/vnd.ms-powerpoint';
      case '.zip':
        return 'application/zip';
      case '.txt':
        return 'text/plain';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.heic':
      case '.heif':
        return 'image/heic';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.m4v':
        return 'video/x-m4v';
      case '.webm':
        return 'video/webm';
      default:
        return 'application/octet-stream';
    }
  }

  // quick helpers to send image/video after upload
  Future<void> sendImage(String url) =>
      _sendMessage(message: '', type: 'image', mediaUrl: url, replyTo: _replyingTo);
  Future<void> sendVideo(String url) =>
      _sendMessage(message: '', type: 'video', mediaUrl: url, replyTo: _replyingTo);

  // ---- reactions / delete / read -------------------------------------------
  Future<void> addReaction(String messageId, String emoji) async {
    await _msgCol.doc(messageId).update({
      'reactions.$emoji': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> removeReaction(String messageId, String emoji) async {
    await _msgCol.doc(messageId).update({
      'reactions.$emoji': FieldValue.arrayRemove([userId])
    });
  }

  Future<void> deleteMessage(String messageId) =>
      _msgCol.doc(messageId).delete();

  Future<void> markAllVisibleAsRead() async {
    if (userId.isEmpty) return;
    final batch = _fs.batch();
    for (final m in messages) {
      if (!(m.readBy?.contains(userId) ?? false)) {
        final ref = _msgCol.doc(m.id);
        batch.update(ref, {
          'readBy': FieldValue.arrayUnion([userId]),
          'status': 'read',
        });
      }
    }
    await batch.commit().catchError((_) {});
  }
}