import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moviemaster/data/repositories/favorites_repository_impl.dart';

void main() {
  late FavoritesRepositoryImpl repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FavoritesRepositoryImpl(firestore: fakeFirestore);
  });

  group('getFavorites', () {
    const tUserId = 'user123';

    test('should return empty list when user document does not exist', () async {
      // Act
      final result = await repository.getFavorites(tUserId);

      // Assert
      expect(result, []);

      // Перевіряємо, що документ створено
      final userDoc = await fakeFirestore.collection('users').doc(tUserId).get();
      expect(userDoc.exists, true);
    });

    test('should return favorites list when user document exists', () async {
      // Arrange
      await fakeFirestore.collection('users').doc(tUserId).set({
        'favorites': [1, 2, 3],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Act
      final result = await repository.getFavorites(tUserId);

      // Assert
      expect(result, [1, 2, 3]);
    });

    test('should return empty list on exception', () async {
      // Act & Assert
      final result = await repository.getFavorites(tUserId);
      expect(result, isA<List<int>>());
      expect(result, isEmpty);
    });
  });

  group('addToFavorites', () {
    const tUserId = 'user123';
    const tMovieId = 1;

    test('should add movie to favorites', () async {
      // Arrange - спочатку створюємо документ
      await fakeFirestore.collection('users').doc(tUserId).set({
        'favorites': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Act
      await repository.addToFavorites(tUserId, tMovieId);

      // Assert
      final userDoc = await fakeFirestore.collection('users').doc(tUserId).get();
      final data = userDoc.data() as Map<String, dynamic>;
      expect(data['favorites'], contains(tMovieId));
    });

    test('should add movie to existing favorites', () async {
      // Arrange
      await fakeFirestore.collection('users').doc(tUserId).set({
        'favorites': [2, 3],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Act
      await repository.addToFavorites(tUserId, tMovieId);

      // Assert
      final userDoc = await fakeFirestore.collection('users').doc(tUserId).get();
      final data = userDoc.data() as Map<String, dynamic>;
      final favorites = List<int>.from(data['favorites'] as List<dynamic>);
      expect(favorites, containsAll([2, 3, tMovieId]));
    });
  });

  group('removeFromFavorites', () {
    const tUserId = 'user123';
    const tMovieId = 1;

    test('should remove movie from favorites', () async {
      // Arrange
      await fakeFirestore.collection('users').doc(tUserId).set({
        'favorites': [tMovieId, 2, 3],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Act
      await repository.removeFromFavorites(tUserId, tMovieId);

      // Assert
      final userDoc = await fakeFirestore.collection('users').doc(tUserId).get();
      final data = userDoc.data() as Map<String, dynamic>;
      final favorites = List<int>.from(data['favorites'] as List<dynamic>);
      expect(favorites, isNot(contains(tMovieId)));
      expect(favorites, containsAll([2, 3]));
    });

    test('should not throw when removing non-existent movie', () async {
      // Arrange
      await fakeFirestore.collection('users').doc(tUserId).set({
        'favorites': [2, 3],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Act & Assert (не повинно бути помилки)
      await expectLater(
        repository.removeFromFavorites(tUserId, tMovieId),
        completes,
      );

      // Перевіряємо, що інші фільми залишились
      final userDoc = await fakeFirestore.collection('users').doc(tUserId).get();
      final data = userDoc.data() as Map<String, dynamic>;
      final favorites = List<int>.from(data['favorites'] as List<dynamic>);
      expect(favorites, containsAll([2, 3]));
    });
  });
}