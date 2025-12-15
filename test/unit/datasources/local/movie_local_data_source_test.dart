import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:moviemaster/data/datasources/movie_local_data_source.dart';
import 'package:moviemaster/data/models/movie_model.dart';

void main() {
  late MovieLocalDataSource dataSource;

  setUp(() async {
    await setUpTestHive();
    dataSource = MovieLocalDataSource();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('cacheMovies and getCachedMovies', () {
    const cacheKey = 'test_key';
    final tMovies = [
      MovieModel(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.5,
        releaseDate: '2024-01-01',
      ),
    ];

    test('should cache and retrieve movies', () async {
      await dataSource.cacheMovies(tMovies, cacheKey);

      final result = await dataSource.getCachedMovies(cacheKey);

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].id, tMovies[0].id);
    });

    test('should return null for non-existent cache key', () async {
      final result = await dataSource.getCachedMovies('non_existent_key');

      expect(result, isNull);
    });
  });

  group('clearCache', () {
    test('should clear all cache', () async {
      const cacheKey1 = 'key1';
      const cacheKey2 = 'key2';
      final tMovies = [
        MovieModel(
          id: 1,
          title: 'Test Movie',
          overview: 'Test Overview',
          posterPath: '/test.jpg',
          voteAverage: 8.5,
          releaseDate: '2024-01-01',
        ),
      ];

      await dataSource.cacheMovies(tMovies, cacheKey1);
      await dataSource.cacheMovies(tMovies, cacheKey2);

      await dataSource.clearCache();

      final result1 = await dataSource.getCachedMovies(cacheKey1);
      final result2 = await dataSource.getCachedMovies(cacheKey2);

      expect(result1, isNull);
      expect(result2, isNull);
    });
  });

  group('isCacheValid', () {
    const cacheKey = 'test_key';
    final tMovies = [
      MovieModel(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.5,
        releaseDate: '2024-01-01',
      ),
    ];

    test('should return true for valid cache', () async {
      await dataSource.cacheMovies(tMovies, cacheKey);

      final isValid = await dataSource.isCacheValid(cacheKey);

      expect(isValid, true);
    });

    test('should return false for non-existent cache', () async {
      final isValid = await dataSource.isCacheValid('non_existent_key');

      expect(isValid, false);
    });
  });
}