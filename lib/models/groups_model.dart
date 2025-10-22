// lib/models/group_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String createdBy;
  final int memberCount;
  final String? avatarUrl;
  final String? description;
  final String? lastMessage;
  final Timestamp? lastMessageAt;
  final Timestamp? createdAt;

  /// optional (filled when loading via members collectionGroup)
  final String? myRole;

  Group({
    required this.id,
    required this.name,
    required this.createdBy,
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
    return Group(
      id: d.id,
      name: (data['name'] ?? '') as String,
      createdBy: (data['createdBy'] ?? '') as String,
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
