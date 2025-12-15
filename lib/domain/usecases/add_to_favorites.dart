import '../repositories/favorites_repository.dart';

class AddToFavorites {
  final FavoritesRepository repository;

  AddToFavorites(this.repository);

  Future<void> call(String userId, int movieId) async {
    await repository.addToFavorites(userId, movieId);
  }
}