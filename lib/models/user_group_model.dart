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
        u?.email,
        m?.email,
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

  String get name =>
      (displayName != null && displayName!.trim().isNotEmpty)
          ? displayName!.trim()
          : (email ?? 'User');

  // -------- fallbacks & util ----------

  static String? _pickName(Map<String, dynamic> m) {
    return _firstNonEmpty([
      m['photoUrl'] as String?,
      m['name'] as String?,
     
    ]);
  }

  static String? _pickEmail(Map<String, dynamic> m) {
    return _firstNonEmpty([
      m['email'] as String?,
      m['primaryEmail'] as String?,
    ]);
  }

  static String? _pickPhoto(Map<String, dynamic> m) {
    return _firstNonEmpty([
      m['photoURL'] as String?,
      m['photoUrl'] as String?,
      m['avatarUrl'] as String?,
      m['avatar'] as String?,
    ]);
  }

  static String? _firstNonEmpty(List<String?> cands) {
    for (final v in cands) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
    }
}
