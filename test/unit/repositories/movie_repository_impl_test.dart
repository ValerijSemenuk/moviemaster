import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/data/models/movie_model.dart';
import 'package:moviemaster/data/repositories/movie_repository_impl.dart';
import 'package:moviemaster/domain/entities/movie_details_entity.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';

import '../../mocks/mock_datasources.dart';
import '../../mocks/mock_repositories.dart';

void main() {
  late MovieRepositoryImpl repository;
  late MockMovieRemoteDataSource mockRemoteDataSource;
  late MockMovieLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerAllFallbackValues();
  });

  setUp(() {
    mockRemoteDataSource = MockMovieRemoteDataSource();
    mockLocalDataSource = MockMovieLocalDataSource();
    repository = MovieRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getPopularMovies', () {
    final tMovieModels = [
      MovieModel(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.5,
        releaseDate: '2024-01-01',
      ),
    ];
    final tMovieEntities = [
      MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.5,
        releaseDate: '2024-01-01',
      ),
    ];
    const tPage = 1;
    const cacheKey = 'popular_$tPage';

    test('should return movies from cache when available', () async {
      when(() => mockLocalDataSource.getCachedMovies(cacheKey))
          .thenAnswer((_) async => tMovieModels);

      final result = await repository.getPopularMovies(page: tPage);

      verify(() => mockLocalDataSource.getCachedMovies(cacheKey)).called(1);
      verifyZeroInteractions(mockRemoteDataSource);

      expect(result.length, tMovieEntities.length);
      expect(result[0].id, tMovieEntities[0].id);
      expect(result[0].title, tMovieEntities[0].title);
    });

    test('should fetch from remote and cache when cache is empty', () async {
      when(() => mockLocalDataSource.getCachedMovies(cacheKey))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.getPopularMovies(page: tPage))
          .thenAnswer((_) async => tMovieModels);
      when(() => mockLocalDataSource.cacheMovies(tMovieModels, cacheKey))
          .thenAnswer((_) async {});

      final result = await repository.getPopularMovies(page: tPage);

      verify(() => mockLocalDataSource.getCachedMovies(cacheKey)).called(1);
      verify(() => mockRemoteDataSource.getPopularMovies(page: tPage)).called(1);
      verify(() => mockLocalDataSource.cacheMovies(tMovieModels, cacheKey)).called(1);

      expect(result.length, tMovieEntities.length);
      expect(result[0].id, tMovieEntities[0].id);
    });

    test('should return from cache when remote fails', () async {
      var callNumber = 0;
      when(() => mockLocalDataSource.getCachedMovies(cacheKey))
          .thenAnswer((_) async {
        callNumber++;
        return callNumber == 1 ? null : tMovieModels;
      });

      when(() => mockRemoteDataSource.getPopularMovies(page: tPage))
          .thenThrow(Exception('Network error'));

      final result = await repository.getPopularMovies(page: tPage);

      verify(() => mockLocalDataSource.getCachedMovies(cacheKey)).called(2);
      verify(() => mockRemoteDataSource.getPopularMovies(page: tPage)).called(1);

      expect(result.length, tMovieEntities.length);
      expect(result[0].id, tMovieEntities[0].id);
    });

    test('should throw exception when both remote and cache fail', () async {
      when(() => mockLocalDataSource.getCachedMovies(cacheKey))
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.getPopularMovies(page: tPage))
          .thenThrow(Exception('Network error'));

      expect(() => repository.getPopularMovies(page: tPage),
          throwsA(isA<Exception>()));
    });
  });

  group('searchMovies', () {
    const tQuery = 'test';
    const tPage = 1;
    final tMovieModels = [
      MovieModel(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.5,
        releaseDate: '2024-01-01',
      ),
    ];
    final tMovieEntities = [
      MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        posterPath: '/test.jpg',
        voteAverage: 8.5,
        releaseDate: '2024-01-01',
      ),
    ];

    test('should return movies from remote data source', () async {
      when(() => mockRemoteDataSource.searchMovies(tQuery, page: tPage))
          .thenAnswer((_) async => tMovieModels);

      final result = await repository.searchMovies(tQuery, page: tPage);

      verify(() => mockRemoteDataSource.searchMovies(tQuery, page: tPage)).called(1);

      expect(result.length, tMovieEntities.length);
      expect(result[0].id, tMovieEntities[0].id);
      expect(result[0].title, tMovieEntities[0].title);
    });

    test('should throw when remote fails', () async {
      when(() => mockRemoteDataSource.searchMovies(tQuery, page: tPage))
          .thenThrow(Exception('Network error'));

      expect(() => repository.searchMovies(tQuery, page: tPage),
          throwsA(isA<Exception>()));
    });
  });

  group('getMovieDetails', () {
    const tMovieId = 1;
    final tMovieModel = MovieModel(
      id: tMovieId,
      title: 'Test Movie',
      overview: 'Test Overview',
      posterPath: '/test.jpg',
      voteAverage: 8.5,
      releaseDate: '2024-01-01',
      genres: ['Action', 'Adventure'],
      runtime: 120,
      tagline: 'A great tagline',
      budget: 1000000,
      revenue: 5000000,
      status: 'Released',
      spokenLanguages: ['English'],
      backdropPath: '/backdrop.jpg',
    );

    test('should return MovieDetailsEntity when all calls succeed', () async {
      when(() => mockRemoteDataSource.getMovieDetails(tMovieId))
          .thenAnswer((_) async => tMovieModel);
      when(() => mockRemoteDataSource.getMovieVideos(tMovieId))
          .thenAnswer((_) async => []);
      when(() => mockRemoteDataSource.getMovieCredits(tMovieId))
          .thenAnswer((_) async => []);
      when(() => mockRemoteDataSource.getMovieReviews(tMovieId))
          .thenAnswer((_) async => []);
      when(() => mockRemoteDataSource.getSimilarMovies(tMovieId))
          .thenAnswer((_) async => []);

      final result = await repository.getMovieDetails(tMovieId);

      verify(() => mockRemoteDataSource.getMovieDetails(tMovieId)).called(1);
      expect(result, isA<MovieDetailsEntity>());
      expect(result.id, tMovieId);
    });

    test('should throw when getMovieDetails fails', () async {
      when(() => mockRemoteDataSource.getMovieDetails(tMovieId))
          .thenThrow(Exception('Failed to load details'));

      expect(() => repository.getMovieDetails(tMovieId),
          throwsA(isA<Exception>()));
    });
  });
}