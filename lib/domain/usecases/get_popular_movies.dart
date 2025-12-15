import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/repositories/movie_repository.dart';

class GetPopularMovies {
  final MovieRepository repository;

  GetPopularMovies(this.repository);

  Future<List<MovieEntity>> call({int page = 1}) async {
    return await repository.getPopularMovies(page: page);
  }
}