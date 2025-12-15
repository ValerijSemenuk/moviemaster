import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/usecases/get_popular_movies.dart';
import 'package:moviemaster/domain/usecases/search_movies.dart';
import 'package:moviemaster/presentation/blocs/movie_bloc/movie_bloc.dart';

import '../../mocks/mock_repositories.dart';
import '../../mocks/mock_usecases.dart';

void main() {
  late MockGetPopularMovies mockGetPopularMovies;
  late MockSearchMovies mockSearchMovies;
  late MovieBloc movieBloc;

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

  setUpAll(() {
    registerAllFallbackValues();
  });

  setUp(() {
    mockGetPopularMovies = MockGetPopularMovies();
    mockSearchMovies = MockSearchMovies();
    movieBloc = MovieBloc(
      getPopularMovies: mockGetPopularMovies,
      searchMoviesUseCase: mockSearchMovies,
    );
  });

  tearDown(() {
    movieBloc.close();
  });

  group('LoadPopularMovies', () {
    blocTest<MovieBloc, MovieState>(
      'should emit [MovieLoading, MovieLoaded] when successful',
      build: () {
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => tMovies);
        return movieBloc;
      },
      act: (bloc) => bloc.add(const LoadPopularMovies()),
      expect: () => [
        MovieLoading(),
        MovieLoaded(movies: tMovies),
      ],
      verify: (_) {
        verify(() => mockGetPopularMovies(page: 1)).called(1);
      },
    );

    blocTest<MovieBloc, MovieState>(
      'should emit [MovieError] when fails',
      build: () {
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenThrow(Exception('Failed'));
        return movieBloc;
      },
      act: (bloc) => bloc.add(const LoadPopularMovies()),
      expect: () => [
        MovieLoading(),
        MovieError('Exception: Failed'),
      ],
    );

    blocTest<MovieBloc, MovieState>(
      'should use correct page when loading',
      build: () {
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => tMovies);
        return movieBloc;
      },
      act: (bloc) => bloc.add(const LoadPopularMovies(page: 2)),
      verify: (_) {
        verify(() => mockGetPopularMovies(page: 2)).called(1);
      },
    );
  });

  group('SearchMoviesEvent', () {
    blocTest<MovieBloc, MovieState>(
      'should emit [MovieSearching, MovieSearchLoaded] when search successful',
      build: () {
        when(() => mockSearchMovies(any(), page: any(named: 'page')))
            .thenAnswer((_) async => tMovies);
        return movieBloc;
      },
      act: (bloc) => bloc.add(const SearchMoviesEvent('test')),
      expect: () => [
        MovieSearching(),
        MovieSearchLoaded(movies: tMovies, query: 'test'),
      ],
      verify: (_) {
        verify(() => mockSearchMovies('test', page: 1)).called(1);
      },
    );

    blocTest<MovieBloc, MovieState>(
      'should load popular movies when query is empty',
      build: () {
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => tMovies);
        return movieBloc;
      },
      act: (bloc) => bloc.add(const SearchMoviesEvent('')),
      expect: () => [
        MovieLoading(),
        MovieLoaded(movies: tMovies),
      ],
    );

    blocTest<MovieBloc, MovieState>(
      'should emit [MovieSearching, MovieError] when search fails',
      build: () {
        when(() => mockSearchMovies(any(), page: any(named: 'page')))
            .thenThrow(Exception('Search failed'));
        return movieBloc;
      },
      act: (bloc) => bloc.add(const SearchMoviesEvent('test')),
      expect: () => [
        MovieSearching(),
        MovieError('Помилка пошуку: Exception: Search failed'),
      ],
    );
  });

  group('ClearSearch', () {
    blocTest<MovieBloc, MovieState>(
      'should load popular movies when clearing search',
      build: () {
        when(() => mockGetPopularMovies(page: any(named: 'page')))
            .thenAnswer((_) async => tMovies);
        return movieBloc;
      },
      act: (bloc) => bloc.add(const ClearSearch()),
      expect: () => [
        MovieLoading(),
        MovieLoaded(movies: tMovies),
      ],
    );
  });
}