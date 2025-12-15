import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/data/datasources/remote/movie_remote_data_source.dart';
import 'package:moviemaster/data/models/movie_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MovieRemoteDataSource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = MovieRemoteDataSource(dio: mockDio);
  });

  group('getPopularMovies', () {
    const tPage = 1;
    final tJsonResponse = {
      'results': [
        {
          'id': 1,
          'title': 'Test Movie',
          'overview': 'Test Overview',
          'poster_path': '/test.jpg',
          'vote_average': 8.5,
          'release_date': '2024-01-01',
        }
      ]
    };
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

    test('should return list of MovieModel when response is successful', () async {
      when(() => mockDio.get(
        '/movie/popular',
        queryParameters: {'page': tPage},
      )).thenAnswer((_) async => Response(
        data: tJsonResponse,
        requestOptions: RequestOptions(path: '/movie/popular'),
        statusCode: 200,
      ));

      final result = await dataSource.getPopularMovies(page: tPage);

      expect(result.length, tMovieModels.length);
      expect(result[0].id, tMovieModels[0].id);
      expect(result[0].title, tMovieModels[0].title);
    });

    test('should throw Exception when dio throws', () async {
      when(() => mockDio.get(
        '/movie/popular',
        queryParameters: {'page': tPage},
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/movie/popular'),
      ));

      expect(() => dataSource.getPopularMovies(page: tPage),
          throwsA(isA<Exception>()));
    });
  });
}