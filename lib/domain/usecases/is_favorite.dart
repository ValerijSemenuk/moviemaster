import '../repositories/favorites_repository.dart';

class IsFavorite {
  final FavoritesRepository repository;

  IsFavorite(this.repository);

  Future<bool> call(String userId, int movieId) async {
    final favorites = await repository.getFavorites(userId);
    return favorites.contains(movieId);
  }
}