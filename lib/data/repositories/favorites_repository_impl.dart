import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moviemaster/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFirestore _firestore;

  FavoritesRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<int>> getFavorites(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userId).set({
          'favorites': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        return [];
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final favorites = data['favorites'] as List<dynamic>?;

      return favorites?.map((item) => (item as num).toInt()).toList() ?? [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  @override
  Future<void> addToFavorites(String userId, int movieId) async {
    try {
      await _firestore.collection('users').doc(userId).set(
        {
          'favorites': FieldValue.arrayUnion([movieId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, int movieId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([movieId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }
}