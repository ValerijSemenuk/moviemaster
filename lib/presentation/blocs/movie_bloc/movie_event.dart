part of 'movie_bloc.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

class LoadPopularMovies extends MovieEvent {
  final int page;

  const LoadPopularMovies({this.page = 1});

  @override
  List<Object> get props => [page];
}

class SearchMoviesEvent extends MovieEvent {
  final String query;

  const SearchMoviesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends MovieEvent {
  const ClearSearch();
}