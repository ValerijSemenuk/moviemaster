import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:moviemaster/data/models/movie_model.dart';

class MovieLocalDataSource {
  static const String _boxName = 'movies_cache';
  static const Duration _cacheDuration = Duration(hours: 1);

  Box<String>? _box;

  Future<Box<String>> _openBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }

    try {
      _box = await Hive.openBox<String>(_boxName);
      return _box!;
    } catch (e) {
      print('Помилка при відкритті боксу: $e');
      await Hive.deleteBoxFromDisk(_boxName);
      _box = await Hive.openBox<String>(_boxName);
      return _box!;
    }
  }
  Future<void> cacheMovies(List<MovieModel> movies, String cacheKey) async {
    final box = await _openBox();

    final List<Map<String, dynamic>> moviesJson = movies.map((movie) => {
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'vote_average': movie.voteAverage,
      'release_date': movie.releaseDate,
    }).toList();

    final cacheEntry = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'movies': moviesJson,
    };

    final jsonString = jsonEncode(cacheEntry);
    await box.put(cacheKey, jsonString);

    print('Кешовано ${movies.length} фільмів з ключем: $cacheKey');
  }

  Future<List<MovieModel>?> getCachedMovies(String cacheKey) async {
    final box = await _openBox();
    final cachedJson = box.get(cacheKey);

    if (cachedJson == null) {
      print('Кеш не знайдено для ключа: $cacheKey');
      return null;
    }

    try {
      final Map<String, dynamic> cachedData = jsonDecode(cachedJson);
      final timestamp = cachedData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > _cacheDuration) {
        print('Кеш застарів для ключа: $cacheKey');
        await box.delete(cacheKey);
        return null;
      }

      final List<dynamic> moviesJson = cachedData['movies'] as List<dynamic>;
      final List<MovieModel> movies = moviesJson.map((json) {
        return MovieModel.fromJson(json as Map<String, dynamic>);
      }).toList();

      print('Завантажено ${movies.length} фільмів з кешу для ключа: $cacheKey');
      return movies;
    } catch (e) {
      print('Помилка при завантаженні кешу: $e');
      await box.delete(cacheKey);
      return null;
    }
  }

  Future<void> clearCache() async {
    final box = await _openBox();
    await box.clear();
    print('Весь кеш очищено');
  }

  Future<void> clearCacheForKey(String cacheKey) async {
    final box = await _openBox();
    await box.delete(cacheKey);
    print('Кеш очищено для ключа: $cacheKey');
  }

  Future<bool> isCacheValid(String cacheKey) async {
    final box = await _openBox();
    final cachedJson = box.get(cacheKey);

    if (cachedJson == null) return false;

    try {
      final Map<String, dynamic> cachedData = jsonDecode(cachedJson);
      final timestamp = cachedData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      return now.difference(cacheTime) <= _cacheDuration;
    } catch (e) {
      return false;
    }
  }
}