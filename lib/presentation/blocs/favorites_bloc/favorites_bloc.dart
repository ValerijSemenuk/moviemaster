import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/usecases/add_to_favorites.dart';
import 'package:moviemaster/domain/usecases/get_favorites.dart';
import 'package:moviemaster/domain/usecases/remove_from_favorites.dart';

part 'favorites_events.dart';
part 'favorites_states.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites getFavorites;
  final AddToFavorites addToFavorites;
  final RemoveFromFavorites removeFromFavorites;

  final Map<int, MovieEntity> _movieCache = {};

  FavoritesBloc({
    required this.getFavorites,
    required this.addToFavorites,
    required this.removeFromFavorites,
  }) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CacheMovieEvent>(_onCacheMovie);
  }

  Future<void> _onCacheMovie(
      CacheMovieEvent event,
      Emitter<FavoritesState> emit,
      ) async {
    _movieCache[event.movie.id] = event.movie;
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event,
      Emitter<FavoritesState> emit,
      ) async {
    emit(FavoritesLoading());
    try {
      final favoriteIds = await getFavorites(event.userId);

      final favoriteMovies = await _getMoviesFromIds(favoriteIds);

      emit(FavoritesLoaded(favoriteMovies: favoriteMovies));
    } catch (e) {
      emit(FavoritesError('Помилка завантаження улюблених: $e'));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event,
      Emitter<FavoritesState> emit,
      ) async {
    try {
      final currentState = state;

      if (currentState is FavoritesLoaded) {
        final existingMovieIndex = currentState.favoriteMovies
            .indexWhere((movie) => movie.id == event.movieId);

        if (existingMovieIndex >= 0) {
          await removeFromFavorites(event.userId, event.movieId);

          final updatedMovies = List<MovieEntity>.from(currentState.favoriteMovies)
            ..removeAt(existingMovieIndex);

          emit(FavoritesLoaded(favoriteMovies: updatedMovies));
        } else {
          await addToFavorites(event.userId, event.movieId);

          MovieEntity newMovie;
          if (_movieCache.containsKey(event.movieId)) {
            newMovie = _movieCache[event.movieId]!;
          } else {
            newMovie = MovieEntity(
              id: event.movieId,
              title: 'Завантаження...',
              overview: '',
              posterPath: null,
              voteAverage: 0.0,
              releaseDate: null,
            );
          }

          final updatedMovies = [
            ...currentState.favoriteMovies,
            newMovie,
          ];

          emit(FavoritesLoaded(favoriteMovies: updatedMovies));
        }
      } else {
        add(LoadFavoritesEvent(userId: event.userId));
      }
    } catch (e) {
      emit(FavoritesError('Помилка зміни улюблених: $e'));

      if (state is FavoritesLoaded) {
        emit(FavoritesLoaded(favoriteMovies: (state as FavoritesLoaded).favoriteMovies));
      }
    }
  }

  Future<List<MovieEntity>> _getMoviesFromIds(List<int> ids) async {
    final List<MovieEntity> movies = [];

    for (final id in ids) {
      if (_movieCache.containsKey(id)) {
        movies.add(_movieCache[id]!);
      } else {
        movies.add(MovieEntity(
          id: id,
          title: 'Завантаження...',
          overview: '',
          posterPath: null,
          voteAverage: 0.0,
          releaseDate: null,
        ));
      }
    }

    return movies;
  }

  bool isFavorite(int movieId) {
    if (state is FavoritesLoaded) {
      return (state as FavoritesLoaded)
          .favoriteMovies
          .any((movie) => movie.id == movieId);
    }
    return false;
  }
}