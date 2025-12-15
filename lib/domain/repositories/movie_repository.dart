import '../entities/movie_entity.dart';
import '../entities/movie_details_entity.dart';

abstract class MovieRepository {
  Future<List<MovieEntity>> getPopularMovies({int page});
  Future<List<MovieEntity>> searchMovies(String query, {int page});
  Future<MovieDetailsEntity> getMovieDetails(int movieId);
  Future<List<VideoEntity>> getMovieVideos(int movieId);
  Future<List<CastEntity>> getMovieCredits(int movieId);
  Future<List<ReviewEntity>> getMovieReviews(int movieId);
  Future<List<MovieEntity>> getSimilarMovies(int movieId);
}