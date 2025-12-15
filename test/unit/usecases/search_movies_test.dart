import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/repositories/movie_repository.dart';
import 'package:moviemaster/domain/usecases/search_movies.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  late SearchMovies useCase;
  late MockMovieRepository mockMovieRepository;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    useCase = SearchMovies(mockMovieRepository);
  });

  const tQuery = 'Avengers';
  final tMovies = [
    MovieEntity(
      id: 1,
      title: 'Avengers: Endgame',
      overview: 'The final chapter',
      posterPath: '/endgame.jpg',
      releaseDate: '2019-04-26',
      voteAverage: 8.4,
    ),
  ];

  test('should search movies with query and default page', () async {
    when(() => mockMovieRepository.searchMovies(any(), page: any(named: 'page')))
        .thenAnswer((_) async => tMovies);

    final result = await useCase(tQuery);

    expect(result, tMovies);
    verify(() => mockMovieRepository.searchMovies(tQuery, page: 1)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should search movies with query and custom page', () async {
    const page = 2;
    when(() => mockMovieRepository.searchMovies(any(), page: any(named: 'page')))
        .thenAnswer((_) async => tMovies);

    final result = await useCase(tQuery, page: page);

    expect(result, tMovies);
    verify(() => mockMovieRepository.searchMovies(tQuery, page: page)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should return empty list for empty query', () async {
    when(() => mockMovieRepository.searchMovies('', page: any(named: 'page')))
        .thenAnswer((_) async => []);

    final result = await useCase('');

    expect(result, []);
    verify(() => mockMovieRepository.searchMovies('', page: 1)).called(1);
  });

  test('should propagate exception when search fails', () async {
    final tException = Exception('Search failed');
    when(() => mockMovieRepository.searchMovies(any(), page: any(named: 'page')))
        .thenThrow(tException);

    expect(() => useCase(tQuery), throwsA(tException));
    verify(() => mockMovieRepository.searchMovies(tQuery, page: 1)).called(1);
  });
}