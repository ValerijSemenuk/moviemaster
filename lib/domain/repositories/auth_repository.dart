import 'package:moviemaster/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity?> registerWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateUserProfile(String displayName, String? photoUrl);
}