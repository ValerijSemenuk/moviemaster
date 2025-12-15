import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moviemaster/domain/entities/movie_details_entity.dart';
import 'package:moviemaster/domain/usecases/get_movie_details.dart';

part 'movie_details_events.dart';
part 'movie_details_states.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final GetMovieDetails getMovieDetails;

  MovieDetailsBloc({required this.getMovieDetails})
      : super(MovieDetailsInitial()) {
    on<LoadMovieDetails>(_onLoadMovieDetails);
  }

  Future<void> _onLoadMovieDetails(
      LoadMovieDetails event,
      Emitter<MovieDetailsState> emit,
      ) async {
    emit(MovieDetailsLoading());

    try {
      final movieDetails = await getMovieDetails.execute(event.movieId);
      emit(MovieDetailsLoaded(movieDetails: movieDetails));
    } catch (e) {
      emit(MovieDetailsError(message: 'Не вдалося завантажити деталі фільму'));
    }
  }
}