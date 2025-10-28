import 'package:cloud_firestore/cloud_firestore.dart';

class UserLite {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;

  const UserLite({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
  });

  /// Build from a *users/{uid}* doc
  factory UserLite.fromUserDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return UserLite(
      uid: d.id,
      displayName: _pickName(m),
      email: _pickEmail(m),
      photoURL: _pickPhoto(m),
    );
  }

  /// Build from a *groups/{gid}/members/{uid}* doc
  factory UserLite.fromMemberDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    return UserLite(
      uid: (m['uid'] as String?) ?? d.id,
      displayName: _pickName(m),
      email: _pickEmail(m),
      photoURL: _pickPhoto(m),
    );
  }

  /// Build from group member maps (memberNames, memberEmailsMap, memberPhotos)
  factory UserLite.fromGroupMemberData({
    required String userId,
    required Map<String, String> memberNames,
    required Map<String, String> memberEmails,
    required Map<String, String> memberPhotos,
  }) {
    return UserLite(
      uid: userId,
      displayName: memberNames[userId],
      email: memberEmails[userId],
      photoURL: memberPhotos[userId],
    );
  }

  /// Merge user + member docs (userDoc wins when it has better info)
  static UserLite merge(UserLite? userDoc, UserLite? memberDoc) {
    final u = userDoc;
    final m = memberDoc;
    if (u == null && m == null) {
      throw StateError('Cannot merge null UserLite sources');
    }
    final uid = (u?.uid ?? m!.uid);
    return UserLite(
      uid: uid,
      displayName: _firstNonEmpty([
        u?.displayName,
        m?.displayName,
        u?.email?.split('@').first, // Use email prefix as fallback
        m?.email?.split('@').first,
      ]),
      email: _firstNonEmpty([
        u?.email,
        m?.email,
      ]),
      photoURL: _firstNonEmpty([
        u?.photoURL,
        m?.photoURL,
      ]),
    );
  }

  /// Get the best available name for display
  String get name {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }

    // Use email username as fallback
    if (email != null && email!.isNotEmpty) {
      final emailParts = email!.split('@');
      if (emailParts.isNotEmpty) {
        return _capitalizeName(emailParts[0]);
      }
    }

    return 'User';
  }

  /// Get first name for short display
  String get firstName {
    final fullName = name;
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : fullName;
  }

  /// Get initials for avatar
  String get initials {
    final name = this.name;
    if (name.isEmpty || name == 'User') return 'U';

    final nameParts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();

    if (nameParts.isEmpty) return 'U';
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();

    return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase();
  }

  /// Check if user has a profile photo
  bool get hasPhoto => photoURL != null && photoURL!.isNotEmpty;

  // -------- fallbacks & util ----------

  static String? _pickName(Map<String, dynamic> m) {
    return _firstNonEmpty([
      m['name'] as String?,
      m['displayName'] as String?,
      m['username'] as String?,
      m['fullName'] as String?,
      m['firstName'] as String?,
    ]);
  }

  static String? _pickEmail(Map<String, dynamic> m) {
    return _firstNonEmpty([
      m['email'] as String?,
      m['primaryEmail'] as String?,
      m['userEmail'] as String?,
    ]);
  }

  static String? _pickPhoto(Map<String, dynamic> m) {
    return _firstNonEmpty([
      m['photoURL'] as String?,
      m['photoUrl'] as String?,
      m['avatarUrl'] as String?,
      m['avatar'] as String?,
      m['profilePicture'] as String?,
      m['imageUrl'] as String?,
    ]);
  }

  static String? _firstNonEmpty(List<String?> cands) {
    for (final v in cands) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  static String _capitalizeName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (photoURL != null) 'photoURL': photoURL,
    };
  }

  @override
  String toString() {
    return 'UserLite(uid: $uid, name: $name, email: $email, hasPhoto: $hasPhoto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLite && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}