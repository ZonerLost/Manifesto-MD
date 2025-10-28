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

class ChatController extends GetxController {
  ChatController(this.groupId);
  final String groupId;

  // UI/state
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isSending = false.obs;
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs; // {id,email,name,photoUrl}
  final TextEditingController input = TextEditingController();

  // typing
  final RxList<String> typingUsers = <String>[].obs;
  Timer? _typingClearTimer;

  // services
  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _groupSub;

  String get userId => _auth.currentUser?.uid ?? '';
  String get userEmail => _auth.currentUser?.email ?? '';
  String get userName =>
      _auth.currentUser?.displayName ??
          (userEmail.isNotEmpty ? userEmail.split('@').first : 'User');

  // ---- Firestore paths ------------------------------------------------------
  DocumentReference get _groupRef => _fs.collection('groups').doc(groupId);
  CollectionReference get _msgCol =>
      _groupRef.collection('messages');
  CollectionReference get _typingCol =>
      _groupRef.collection('typing');

  // ---- lifecycle ------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    // members live
    _groupSub = _groupRef.snapshots().listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final ids = List<String>.from(data['memberIds'] ?? []);
      final names = Map<String, dynamic>.from(data['memberNames'] ?? {});
      final emails = Map<String, dynamic>.from(data['memberEmailsMap'] ?? {}); // optional
      final photos = Map<String, dynamic>.from(data['memberPhotos'] ?? {});
      members.assignAll(ids.map((id) {
        return {
          'id': id,
          'name': names[id] ?? '',
          'email': emails[id] ?? '',
          'photoUrl': photos[id] ?? '',
        };
      }));
    });

    // messages live (ascending)
    _msgSub = _msgCol
        .orderBy('sentAt', descending: false)
        .snapshots()
        .listen((q) async {
      final list = q.docs.map((d) => ChatMessage.fromDoc(d)).toList();
      messages.assignAll(list);
      // mark unread as read for me
      await markAllVisibleAsRead();
      // update "delivered" if needed — optional here
    });

    // typing live
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
    _groupSub?.cancel();
    _stopTyping();
    super.onClose();
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
      input.clear();
      _replyingTo = null;
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
