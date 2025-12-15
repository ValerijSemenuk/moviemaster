part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {
  final String userId;

  const LoadFavoritesEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String userId;
  final int movieId;

  const ToggleFavoriteEvent({required this.userId, required this.movieId});

  @override
  List<Object> get props => [userId, movieId];
}

class CacheMovieEvent extends FavoritesEvent {
  final MovieEntity movie;

  const CacheMovieEvent({required this.movie});

  @override
  List<Object> get props => [movie];
}