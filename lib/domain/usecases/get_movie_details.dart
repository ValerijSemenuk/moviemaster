import '../entities/movie_details_entity.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetails {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  Future<MovieDetailsEntity> execute(int movieId) async {
    return await repository.getMovieDetails(movieId);
  }
}