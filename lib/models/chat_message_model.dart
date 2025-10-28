// lib/models/chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String message;
  final String type; // text | image | video | file | files
  final String? mediaUrl;
  final List<dynamic>? attachments; // [{name,url,size,type}]
  final Map<String, dynamic>? replyTo; // {messageId,message,sender,userId}
  final Map<String, dynamic>? reactions; // {'😊': [uid, ...]}
  final List<dynamic>? readBy; // [uid, ...]
  final String userId;
  final String? userName;
  final String? photoUrl;
  final Timestamp? sentAt;

  ChatMessage({
    required this.id,
    required this.message,
    required this.type,
    required this.userId,
    this.mediaUrl,
    this.attachments,
    this.replyTo,
    this.reactions,
    this.readBy,
    this.userName,
    this.photoUrl,
    this.sentAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>? ?? {};
    return ChatMessage(
      id: d.id,
      message: (m['message'] ?? '').toString(),
      type: (m['type'] ?? 'text').toString(),
      mediaUrl: m['mediaUrl'] as String?,
      attachments: m['attachments'] as List<dynamic>?,
      replyTo: m['replyTo'] as Map<String, dynamic>?,
      reactions: m['reactions'] as Map<String, dynamic>?,
      readBy: m['readBy'] as List<dynamic>?,
      userId: (m['userId'] ?? '').toString(),
      userName: m['userName'] as String?,
      photoUrl: m['photoUrl'] as String?,
      sentAt: m['sentAt'] as Timestamp?,
    );
  }
}
