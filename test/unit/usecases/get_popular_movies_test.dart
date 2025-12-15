import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/repositories/movie_repository.dart';
import 'package:moviemaster/domain/usecases/get_popular_movies.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  late GetPopularMovies useCase;
  late MockMovieRepository mockMovieRepository;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    useCase = GetPopularMovies(mockMovieRepository);
  });

  final tMovies = [
    MovieEntity(
      id: 1,
      title: 'Test Movie 1',
      overview: 'Test Overview 1',
      posterPath: '/test1.jpg',
      releaseDate: '2024-01-01',
      voteAverage: 8.5,
    ),
    MovieEntity(
      id: 2,
      title: 'Test Movie 2',
      overview: 'Test Overview 2',
      posterPath: '/test2.jpg',
      releaseDate: '2024-02-01',
      voteAverage: 7.8,
    ),
  ];

  test('should get popular movies from repository with default page', () async {
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => tMovies);

    final result = await useCase();

    expect(result, tMovies);
    verify(() => mockMovieRepository.getPopularMovies(page: 1)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should get popular movies from repository with custom page', () async {
    const page = 2;
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => tMovies);

    final result = await useCase(page: page);

    expect(result, tMovies);
    verify(() => mockMovieRepository.getPopularMovies(page: page)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should propagate exception when repository fails', () async {
    final tException = Exception('Failed to load movies');
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenThrow(tException);

    expect(() => useCase(), throwsA(tException));
    verify(() => mockMovieRepository.getPopularMovies(page: 1)).called(1);
  });
}