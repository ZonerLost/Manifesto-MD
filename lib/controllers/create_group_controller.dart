import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';

class CreateGroupController extends GetxController {
  // Inputs
  final name = ''.obs;
  final query = ''.obs;

  // UI state
  final isSubmitting = false.obs;
  final isLoadingPage = false.obs;
  final hasMore = true.obs;

  // Selection (selected userIds; creator is auto-included by service)
  final selected = <String>{}.obs;

  // Users page
  final users = <Map<String, dynamic>>[].obs;
  final int pageSize = 50;
  DocumentSnapshot<Map<String, dynamic>>? _lastSnap;

  // Optional avatar
  Uint8List? avatarBytes;
  String avatarExt = 'jpg';

  String get myUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    // initial load
    _loadFirstPage();

    // re-run search when query changes
    ever<String>(query, (_) => _loadFirstPage());
  }

  // ---- Pagination ----
  Future<void> _loadFirstPage() async {
    users.clear();
    _lastSnap = null;
    hasMore.value = true;
    await loadNextPage();
  }


Future<void> loadNextPage() async {
  if (isLoadingPage.value || !hasMore.value) return;
  isLoadingPage.value = true;

  try {
    Query<Map<String, dynamic>> q;
    QuerySnapshot<Map<String, dynamic>> snap;

    if (query.value.trim().isEmpty) {
      q = FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: false)
          .limit(pageSize);
      if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);

      try {
        snap = await q.get();
      } on FirebaseException {
        // Fallback if 'createdAt' missing/index not built
        q = FirebaseFirestore.instance
            .collection('users')
            .orderBy(FieldPath.documentId)
            .limit(pageSize);
        if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
        snap = await q.get();
      }
    } else {
      final qLower = query.value.toLowerCase();
      q = FirebaseFirestore.instance
          .collection('users')
          .where('displayName_lower', isGreaterThanOrEqualTo: qLower)
          .where('displayName_lower', isLessThan: '$qLower\uf8ff')
          .orderBy('displayName_lower')              // <-- important for paging
          .limit(pageSize);
      if (_lastSnap != null) q = q.startAfterDocument(_lastSnap!);
      snap = await q.get();
    }

    if (snap.docs.isEmpty) {
      hasMore.value = false;
      return;
    }

    _lastSnap = snap.docs.last;

    // Append rows (skip myself)
    users.addAll(
      snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .where((m) => m['id'] != myUid),
    );


    hasMore.value = snap.docs.length >= pageSize;
  } finally {
    isLoadingPage.value = false;
  }
}


  // ---- Selection helpers ----
  void toggle(String uid) {
    if (selected.contains(uid)) {
      selected.remove(uid);
    } else {
      selected.add(uid);
    }
  }

  void selectAllVisible() {
    for (final u in users) {
      final uid = u['id'] as String;
      if (uid == myUid) continue;
      selected.add(uid);
    }
  }

  void clearSelection() => selected.clear();

  // ---- Submit ----
  Future<String> submit() async {
    final n = name.value.trim();
    if (n.isEmpty) throw 'Group name is required';
    if (selected.isEmpty) throw 'Pick at least one member';

    isSubmitting.value = true;
    try {
      final gid = await ChatService.instance.createGroupFlow(
        name: n,
        memberIds: selected.toList(), // creator auto-included inside service
        avatarBytes: avatarBytes,
        avatarFileExt: avatarExt,
      );
      return gid;
    } finally {
      isSubmitting.value = false;
    }
  }
}
