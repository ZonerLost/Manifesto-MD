// lib/models/group_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String createdBy;
  final String? ownerId;
  final int memberCount;
  final String? avatarUrl;
  final String? description;
  final String? lastMessage;
  final Timestamp? lastMessageAt;
  final Timestamp? createdAt;

  final String? myRole;

  Group({
    required this.id,
    required this.name,
    required this.createdBy,
    this.ownerId,
    required this.memberCount,
    this.avatarUrl,
    this.description,
    this.lastMessage,
    this.lastMessageAt,
    this.createdAt,
    this.myRole,
  });

  factory Group.fromDoc(DocumentSnapshot<Map<String, dynamic>> d, {String? myRole}) {
    final data = d.data() ?? {};

    // Normalize ownership across schemas:
    // - Prefer ownerId when present
    // - Fall back to createdBy for legacy docs
    final String? ownerId = (data['ownerId'] as String?) ?? (data['createdBy'] as String?);
    final String createdBy = (data['createdBy'] as String?) ?? (data['ownerId'] as String?) ?? '';

    return Group(
      id: d.id,
      name: (data['name'] ?? '') as String,
      createdBy: createdBy,
      ownerId: ownerId,
      memberCount: (data['memberCount'] ?? 0) as int,
      avatarUrl: data['avatarUrl'] as String?,
      description: data['description'] as String?,
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: data['lastMessageAt'] as Timestamp?,
      createdAt: data['createdAt'] as Timestamp?,
      myRole: myRole,
    );
  }
}
