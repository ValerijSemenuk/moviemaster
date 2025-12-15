import 'package:dio/dio.dart';
import '../../models/movie_model.dart';
import '../../models/video_model.dart';
import '../../models/credit_model.dart';
import '../../models/review_model.dart';

class MovieRemoteDataSource {
  final Dio dio;

  MovieRemoteDataSource({required this.dio});

  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await dio.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load popular movies: $e');
    }
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await dio.get(
        '/search/movie',
        queryParameters: {'query': query, 'page': page},
      );
      final results = response.data['results'] as List;
      return results.map((json) => MovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  Future<MovieModel> getMovieDetails(int movieId) async {
    try {
      final response = await dio.get('/movie/$movieId');
      return MovieModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  Future<List<VideoModel>> getMovieVideos(int movieId) async {
    try {
      final response = await dio.get('/movie/$movieId/videos');
      final results = response.data['results'] as List;
      return results
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<CreditModel>> getMovieCredits(int movieId) async {
    try {
      final response = await dio.get('/movie/$movieId/credits');
      final results = response.data['cast'] as List;
      return results
          .map((json) => CreditModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ReviewModel>> getMovieReviews(int movieId) async {
    try {
      final response = await dio.get('/movie/$movieId/reviews');
      final results = response.data['results'] as List;
      return results
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<MovieModel>> getSimilarMovies(int movieId) async {
    try {
      final response = await dio.get('/movie/$movieId/similar');
      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}