import 'package:hive/hive.dart';
import '../../models/favorite_model.dart';

class FavoritesLocalDataSource {
  static const _boxName = 'favorites';

  Future<Box<FavoriteModel>> _openBox() async {
    return await Hive.openBox<FavoriteModel>(_boxName);
  }

  Future<void> addFavorite(int movieId) async {
    final box = await _openBox();
    await box.put(movieId, FavoriteModel(movieId: movieId));
  }

  Future<void> removeFavorite(int movieId) async {
    final box = await _openBox();
    await box.delete(movieId);
  }

  Future<bool> isFavorite(int movieId) async {
    final box = await _openBox();
    return box.containsKey(movieId);
  }

  Future<List<int>> getAllFavorites() async {
    final box = await _openBox();
    return box.keys.cast<int>().toList();
  }
}