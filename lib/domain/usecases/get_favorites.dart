import 'package:moviemaster/domain/repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository repository;

  GetFavorites(this.repository);

  Future<List<int>> call(String userId) async {
    return await repository.getFavorites(userId);
  }
}