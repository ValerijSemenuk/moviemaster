import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/usecases/get_popular_movies.dart';
import 'package:moviemaster/domain/usecases/search_movies.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMovies getPopularMovies;
  final SearchMovies searchMoviesUseCase;

  MovieBloc({
    required this.getPopularMovies,
    required this.searchMoviesUseCase,
  }) : super(MovieInitial()) {
    on<LoadPopularMovies>(_onLoadPopularMovies);
    on<SearchMoviesEvent>(_onSearchMovies);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadPopularMovies(
      LoadPopularMovies event,
      Emitter<MovieState> emit,
      ) async {
    try {
      if (event.page == 1) {
        emit(MovieLoading());
      }

      final movies = await getPopularMovies(page: event.page);
      emit(MovieLoaded(movies: movies));
    } catch (e) {
      emit(MovieError(e.toString()));
    }
  }

  Future<void> _onSearchMovies(
      SearchMoviesEvent event,
      Emitter<MovieState> emit,
      ) async {
    try {
      if (event.query.isEmpty) {
        add(const LoadPopularMovies());
        return;
      }

      emit(MovieSearching());

      final movies = await searchMoviesUseCase(event.query);
      emit(MovieSearchLoaded(movies: movies, query: event.query));
    } catch (e) {
      emit(MovieError('Помилка пошуку: $e'));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<MovieState> emit) {
    add(const LoadPopularMovies());
  }
}