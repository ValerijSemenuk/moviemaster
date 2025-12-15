import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/movie_details_entity.dart';
import 'package:moviemaster/domain/repositories/movie_repository.dart';
import 'package:moviemaster/domain/usecases/get_movie_details.dart';

import '../../mocks/mock_repositories.dart';


void main() {
  late GetMovieDetails useCase;
  late MockMovieRepository mockMovieRepository;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    useCase = GetMovieDetails(mockMovieRepository);
  });

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

  test('should get movie details from repository', () async {
    when(() => mockMovieRepository.getMovieDetails(any()))
        .thenAnswer((_) async => tMovieDetails);

    final result = await useCase.execute(tMovieId);

    expect(result, tMovieDetails);
    verify(() => mockMovieRepository.getMovieDetails(tMovieId)).called(1);
  });

  test('should propagate exception when repository fails', () async {
    final tException = Exception('Failed to load movie details');
    when(() => mockMovieRepository.getMovieDetails(any()))
        .thenThrow(tException);

    expect(() => useCase.execute(tMovieId), throwsA(tException));
    verify(() => mockMovieRepository.getMovieDetails(tMovieId)).called(1);
  });
}