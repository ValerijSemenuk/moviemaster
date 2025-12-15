import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/repositories/movie_repository.dart';

class SearchMovies {
  final MovieRepository repository;

  SearchMovies(this.repository);

  Future<List<MovieEntity>> call(String query, {int page = 1}) async {
    return await repository.searchMovies(query, page: page);
  }
}