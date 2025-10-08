import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manifesto_md/models/auth_model.dart';

class AuthService  {

static final AuthService instance = AuthService._internal();

AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseFunctions _functions = FirebaseFunctions.instance;


  Future<AuthModel?> signUp(
    {required String email,
    required String password,
    required String name,}
  ) async{

    try {
 UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

 AuthModel user = AuthModel(
        uid: cred.user!.uid,
        email: email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );

        await _firestore.collection("users").doc(user.uid).set(user.toMap());
          return user;
    } catch (e) {
      throw ("Signup Error $e");
    }

  }



Future<AuthModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      DocumentSnapshot snap =
          await _firestore.collection("users").doc(cred.user!.uid).get();

      return AuthModel.fromMap(snap.data() as Map<String, dynamic>);
    } catch (e) {
      throw ("Login Error $e");
    }
  }


  Future<String> checkForEmail(String email) async {

    try {
        final emailResp = await _firestore.collection("users").doc(email.trim()).get();
        if(emailResp.exists){
          return "This Email is already registered";
        }
      return "";
    } catch (e) {
      throw ("Something went wrong $e");
    }



  }




}
