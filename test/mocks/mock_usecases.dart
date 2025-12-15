import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/entities/movie_details_entity.dart';
import 'package:moviemaster/domain/usecases/get_popular_movies.dart';
import 'package:moviemaster/domain/usecases/search_movies.dart';
import 'package:moviemaster/domain/usecases/get_movie_details.dart';
import 'package:moviemaster/domain/usecases/get_favorites.dart';
import 'package:moviemaster/domain/usecases/add_to_favorites.dart';
import 'package:moviemaster/domain/usecases/remove_from_favorites.dart';

class MockGetPopularMovies extends Mock implements GetPopularMovies {}

class MockSearchMovies extends Mock implements SearchMovies {}

class MockGetMovieDetails extends Mock implements GetMovieDetails {}

class MockGetFavorites extends Mock implements GetFavorites {}

class MockAddToFavorites extends Mock implements AddToFavorites {}

class MockRemoveFromFavorites extends Mock implements RemoveFromFavorites {}