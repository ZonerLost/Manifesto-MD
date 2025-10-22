import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a Firestore notification document.
/// Supports group invites, system messages, etc.
class AppNotification {
  final String id;
  final String type; // e.g. "group_invite", "system_alert"
  final String senderId;
  final String senderName;
  final String receiverId;
  final String? groupId;
  final String? groupName;
  final String status; // "pending", "accepted", "rejected"
  final DateTime? createdAt;
  final DateTime? respondedAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    this.groupId,
    this.groupName,
    required this.status,
    this.createdAt,
    this.respondedAt,
  });

  // ---------------------------------------------------------------------------
  // FACTORY FROM SNAPSHOT
  // ---------------------------------------------------------------------------

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppNotification(
      id: doc.id,
      type: data['type'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      groupId: data['groupId'],
      groupName: data['groupName'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  // ---------------------------------------------------------------------------
  // TO JSON (for creating/updating)
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'groupId': groupId,
      'groupName': groupName,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      if (respondedAt != null)
        'respondedAt': Timestamp.fromDate(respondedAt!),
    };
  }

  // ---------------------------------------------------------------------------
  // COPY WITH
  // ---------------------------------------------------------------------------

  AppNotification copyWith({
    String? status,
    DateTime? respondedAt,
  }) {
    return AppNotification(
      id: id,
      type: type,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      groupId: groupId,
      groupName: groupName,
      status: status ?? this.status,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
