part of 'movie_bloc.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieSearching extends MovieState {}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object> get props => [message];
}

class MovieLoaded extends MovieState {
  final List<MovieEntity> movies;

  const MovieLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}

class MovieSearchLoaded extends MovieState {
  final List<MovieEntity> movies;
  final String query;

  const MovieSearchLoaded({required this.movies, required this.query});

  @override
  List<Object> get props => [movies, query];
}