import '../entities/movie_entity.dart';

abstract class FavoritesRepository {
  Future<List<int>> getFavorites(String userId);
  Future<void> addToFavorites(String userId, int movieId);
  Future<void> removeFromFavorites(String userId, int movieId);
}