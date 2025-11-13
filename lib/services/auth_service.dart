import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manifesto_md/models/auth_model.dart';
import 'package:manifesto_md/models/professional_details_model.dart';
import 'package:manifesto_md/services/sahred_preferences_service.dart';

class AuthService  {

static final AuthService instance = AuthService._internal();

AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // final FirebaseFunctions _functions = FirebaseFunctions.instance;


  Future<AuthModel?> signUp(
    {required String email,
    required String password,
    required String name,}
  ) async{

    try {
 UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );

 AuthModel user = AuthModel(
        uid: cred.user!.uid,
        email: email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );

        await _firestore.collection("users").doc(user.uid).set(user.toMap());
          return user;
    } on FirebaseAuthException catch (e){
       throw getFirebaseAuthErrorMessage(e.code);
    }  
     catch (e) {
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
    } on FirebaseAuthException catch (e){
       throw getFirebaseAuthErrorMessage(e.code);
    }
    catch (e) {
      throw ("Login Error $e");
    }
  }


  Future<String> forgotPassword(String email) async {
  try {
    // Step 1: Check if email exists in Firestore
    final querySnapshot = await _firestore
        .collection("users")
        .where("email", isEqualTo: email.trim())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // ⚠️ No account found
      return "No account found for this email.";
    }

    // Step 2: Send reset password email via Firebase
    await _auth.sendPasswordResetEmail(email: email.trim(),);

    // ✅ Successfully sent
    return "A password reset link has been sent to your email.";
  } on FirebaseAuthException catch (e) {
    throw getFirebaseAuthErrorMessage(e.code);
  } catch (e) {
    throw ("Forgot Password Error: $e");
  }
}



Future<String> checkForEmail(String email) async {
  try {
    final querySnapshot = await _firestore
        .collection("users")
        .where("email", isEqualTo: email.trim())
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return "This Email is already registered";
    }
    return "";
  } catch (e) {
    throw ("Something went wrong: $e");
  }
}

Future<User?> signInWithGoogle() async {
  try {
    // Trigger Google Sign-In
    await _googleSignIn.initialize();
    final GoogleSignInAccount account = await _googleSignIn.authenticate(
      scopeHint: ['email', 'profile'],
    );

    // Request authorization
    final GoogleSignInClientAuthorization? authorization = await account
        .authorizationClient
        .authorizationForScopes(['email', 'profile']);
    if (authorization == null) {
      print("Google sign-in cancelled by authorization");
      return null;
    }

    final GoogleSignInAuthentication authTokens = account.authentication;

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: authorization.accessToken,
      idToken: authTokens.idToken,
    );

    // Sign in to Firebase with Google credentials
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      print("Google sign-in failed: user is null");
      return null;
    }

    final userDoc = await _firestore.collection("users").doc(user.uid).get();

    if (userDoc.exists) {
      // ✅ User already exists → just sign in and store UID
      print("User already exists, logging in...");
      await SharePrefService.instance.addUserId(user.uid);
    } else {
      // 🆕 New user → add to Firestore
      print("New user detected, creating record...");
      final authModel = AuthModel(
        uid: user.uid,
        email: user.email ?? "",
        country: "",
        name: user.displayName ?? "N/A",
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection("users")
          .doc(user.uid)
          .set(authModel.toMap(), SetOptions(merge: true));

      await SharePrefService.instance.addUserId(user.uid);
    }

    return user;
  } catch (e) {
    print("Google Sign-In Error: $e");
    return null;
  }
}


  String getFirebaseAuthErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This user account has been disabled.';
    case 'user-not-found':
      return 'No account found for this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'operation-not-allowed':
      return 'This sign-in method is not allowed.';
    case 'weak-password':
      return 'The password is too weak. Please use at least 6 characters.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'network-request-failed':
      return 'Network error. Please check your internet connection.';
    case 'invalid-credential':
      return 'The provided credentials are invalid';
    case 'missing-email':
      return 'Please enter an email address.';
    case 'account-exists-with-different-credential':
      return 'An account already exists with a different sign-in method.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

Future<ProfessionalDetailsModel?> saveProfessionalData({
  required String severityLevel,
  required String expLevel,
  required String userId,
}) async {
  try {

    ProfessionalDetailsModel p = ProfessionalDetailsModel(
      speciality: severityLevel,
      professionalLevel: expLevel,
    );

    DocumentReference docRef = await _firestore
        .collection("users")
        .doc(userId)
        .collection("professional_details")
        .add(p.toMap());


    DocumentSnapshot snap = await docRef.get();


    return ProfessionalDetailsModel.fromMap(
      snap.data() as Map<String, dynamic>,
    );
  } on FirebaseAuthException catch (e) {
    throw getFirebaseAuthErrorMessage(e.code);
  } catch (e) {
    throw ("Save professional data error: $e");
  }
}




Future<void> logOut() async{
  try {
    await _auth.signOut();
    SharePrefService.instance.clearUserId();
  } catch (e) {
      throw ("Something Went Wrong  $e");
  }
}


}
