import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:manifesto_md/models/auth_model.dart';
import 'package:manifesto_md/models/professional_details_model.dart';

class ProfileService {
  static final ProfileService instance = ProfileService._internal();
  ProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// ✅ Fetch user profile
  Future<AuthModel?> getProfile(String userId) async {
    try {
      final snap = await _firestore.collection('users').doc(userId).get();
      if (!snap.exists || snap.data() == null) return null;
      return AuthModel.fromMap(snap.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Get profile error: $e");
    }
  }


Future<Map<String, dynamic>?> getProfessionalDetails(String userId) async {
  try {
    final querySnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('professional_details')
        .get();

    if (querySnap.docs.isEmpty) return null;

    final doc = querySnap.docs.first;

    final data = doc.data();

    return {
      "docId" : doc.id, 
      "Details" : ProfessionalDetailsModel.fromMap(data)};
  } catch (e) {
    throw Exception("Get professional details error: $e");
  }
}


  /// ✅ Update profile data (name, country, etc.)
  Future<void> updateProfile({
    required String userId,
    required updatedData,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
    } catch (e) {
      throw Exception("Update profile error: $e");
    }
  }



  Future<void> updateProfessionalDetails({
    required String userId,
    required String docId, 
    required Map<String, dynamic> professionalData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('professional_details')
          .doc(docId)
          .set(professionalData, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Update professional details error: $e");
    }
  }

  /// ✅ Upload profile image and return URL
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      // Update user's Firestore document with new image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImage': imageUrl,
      });

      return imageUrl;
    } catch (e) {
      throw Exception("Upload image error: $e");
    }
  }
}
