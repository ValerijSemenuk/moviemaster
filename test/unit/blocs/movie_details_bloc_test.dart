import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/movie_details_entity.dart';
import 'package:moviemaster/domain/usecases/get_movie_details.dart';
import 'package:moviemaster/presentation/blocs/movie_details_bloc/movie_details_bloc.dart';

import '../../mocks/mock_repositories.dart';
import '../../mocks/mock_usecases.dart';

void main() {
  late MockGetMovieDetails mockGetMovieDetails;
  late MovieDetailsBloc movieDetailsBloc;

  final tMovieId = 1;
  final tMovieDetails = MovieDetailsEntity(
    id: tMovieId,
    title: 'Test Movie',
    overview: 'Test Overview',
    posterPath: '/test.jpg',
    releaseDate: '2024-01-01',
    voteAverage: 8.5,
    genres: ['Action', 'Adventure'],
    runtime: 120,
    tagline: 'A test tagline',
    budget: 1000000,
    revenue: 5000000,
    status: 'Released',
    spokenLanguages: ['English'],
    backdropPath: '/backdrop.jpg',
    videos: [],
    cast: [],
    reviews: [],
    similarMovies: [],
  );

  setUpAll(() {
    registerAllFallbackValues();
  });

  setUp(() {
    mockGetMovieDetails = MockGetMovieDetails();
    movieDetailsBloc = MovieDetailsBloc(
      getMovieDetails: mockGetMovieDetails,
    );
  });

  tearDown(() {
    movieDetailsBloc.close();
  });

  blocTest<MovieDetailsBloc, MovieDetailsState>(
    'should emit [MovieDetailsLoading, MovieDetailsLoaded] when successful',
    build: () {
      when(() => mockGetMovieDetails.execute(any()))
          .thenAnswer((_) async => tMovieDetails);
      return movieDetailsBloc;
    },
    act: (bloc) => bloc.add(LoadMovieDetails(tMovieId)),
    expect: () => [
      MovieDetailsLoading(),
      MovieDetailsLoaded(movieDetails: tMovieDetails),
    ],
    verify: (_) {
      verify(() => mockGetMovieDetails.execute(tMovieId)).called(1);
    },
  );

  blocTest<MovieDetailsBloc, MovieDetailsState>(
    'should emit [MovieDetailsLoading, MovieDetailsError] when fails',
    build: () {
      when(() => mockGetMovieDetails.execute(any()))
          .thenThrow(Exception('Failed'));
      return movieDetailsBloc;
    },
    act: (bloc) => bloc.add(LoadMovieDetails(tMovieId)),
    expect: () => [
      MovieDetailsLoading(),
      const MovieDetailsError(message: 'Не вдалося завантажити деталі фільму'),
    ],
  );
}