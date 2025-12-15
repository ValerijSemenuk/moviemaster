import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moviemaster/data/models/user_model.dart';
import 'package:moviemaster/domain/entities/user_entity.dart';
import 'package:moviemaster/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      return await _createOrUpdateUserInFirestore(userCredential.user);
    } catch (e) {
      print('Помилка входу через Google: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _createOrUpdateUserInFirestore(userCredential.user);
    } on FirebaseAuthException catch (e) {
      print('Помилка входу: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _createOrUpdateUserInFirestore(userCredential.user);
    } on FirebaseAuthException catch (e) {
      print('Помилка реєстрації: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (userDoc.exists) {
      final userModel = UserModel.fromFirestore(userDoc);
      return userModel.toEntity();
    }

    return UserModel.fromFirebaseUser(firebaseUser).toEntity();
  }

  @override
  Future<void> updateUserProfile(String displayName, String? photoUrl) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(displayName);
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    await _firestore.collection('users').doc(user.uid).update({
      'displayName': displayName,
      'photoUrl': photoUrl ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await user.reload();
  }

  Future<UserEntity?> _createOrUpdateUserInFirestore(User? firebaseUser) async {
    if (firebaseUser == null) return null;

    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      final newUser = UserModel.fromFirebaseUser(firebaseUser);
      await userRef.set(newUser.toFirestore());
    } else {
      await userRef.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final updatedDoc = await userRef.get();
    final userModel = UserModel.fromFirestore(updatedDoc);
    return userModel.toEntity();
  }

  Future<UserModel?> getCurrentUserModel() async {
    final User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) return null;

    return UserModel.fromFirestore(userDoc);
  }
}