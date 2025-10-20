// ------- MESSAGE MODEL (minimal) -------
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime? createdAt;
  final bool deleted;
  final DateTime? editedAt;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.deleted = false,
    this.editedAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ChatMessage(
      id: doc.id,
      groupId: d['groupId'] as String,
      senderId: d['senderId'] as String,
      senderName: (d['senderName'] ?? '') as String,
      text: (d['text'] ?? '') as String,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      deleted: (d['deletedAt'] != null),
      editedAt: (d['editedAt'] as Timestamp?)?.toDate(),
    );
  }
}