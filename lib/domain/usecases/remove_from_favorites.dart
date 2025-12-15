import '../repositories/favorites_repository.dart';

class RemoveFromFavorites {
  final FavoritesRepository repository;

  RemoveFromFavorites(this.repository);

  Future<void> call(String userId, int movieId) async {
    await repository.removeFromFavorites(userId, movieId);
  }
}