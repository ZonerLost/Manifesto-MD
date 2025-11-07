import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarksService {
  static const String moduleKeyClinical = 'clinical_manifesto';
  static const String itemTypeClinicalEntry = 'clinical_entry';

  BookmarksService._();
  static final BookmarksService instance = BookmarksService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? _uid() => _auth.currentUser?.uid;

  String _slug(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  /// Deterministic doc id so toggling is fast.
  String entryDocId(String entryName) =>
      'clinical_entry_${_slug(entryName)}';

  CollectionReference<Map<String, dynamic>> _userBookmarksCol(String uid) =>
      _db.collection('users').doc(uid).collection('bookmarks');

  DocumentReference<Map<String, dynamic>> _entryDocRef({
    required String uid,
    required String entryName,
  }) {
    return _userBookmarksCol(uid).doc(entryDocId(entryName));
  }

  /// Returns true if the given entry is saved.
  Future<bool> isEntryBookmarked(String entryName) async {
    final uid = _uid();
    if (uid == null) return false;
    final doc = await _entryDocRef(uid: uid, entryName: entryName).get();
    return doc.exists;
  }

  /// Toggle save for a clinical entry.
  /// [systemName] and [icdCode] are optional but recommended for clarity in "bookmarks" UI.
  Future<bool> toggleEntryBookmark({
    required String entryName,
    String? systemName,
    String? icdCode,
    String? displayName,
  }) async {
    final uid = _uid();
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    final ref = _entryDocRef(uid: uid, entryName: entryName);
    final snap = await ref.get();

    if (snap.exists) {
      await ref.delete();
      return false; // now removed
    } else {
      final now = FieldValue.serverTimestamp();
      await ref.set({
        'moduleKey': moduleKeyClinical,
        'itemType': itemTypeClinicalEntry,
        'entryName': entryName,
        'system': systemName,
        'icdCode': icdCode,
        'displayName': displayName ?? entryName,
        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
      return true; // now saved
    }
  }

  /// Update timestamp if needed (optional helper).
  Future<void> touchEntryBookmark(String entryName) async {
    final uid = _uid();
    if (uid == null) return;
    final ref = _entryDocRef(uid: uid, entryName: entryName);
    await ref.set({'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  /// Stream a Set of saved entry names for this user in the Clinical module.
  Stream<Set<String>> watchSavedEntryNames() {
    final uid = _uid();
    if (uid == null) {
      // emit empty if signed-out
      return Stream.value(<String>{});
    }
    return _userBookmarksCol(uid)
        .where('moduleKey', isEqualTo: moduleKeyClinical)
        .where('itemType', isEqualTo: itemTypeClinicalEntry)
        .snapshots()
        .map((snap) {
      final names = <String>{};
      for (final d in snap.docs) {
        final n = d.data()['entryName'];
        if (n is String && n.trim().isNotEmpty) names.add(n);
      }
      return names;
    });
  }
}
