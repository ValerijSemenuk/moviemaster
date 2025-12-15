import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/data/models/credit_model.dart';
import 'package:moviemaster/data/models/movie_model.dart';
import 'package:moviemaster/data/models/review_model.dart';
import 'package:moviemaster/data/models/video_model.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/entities/movie_details_entity.dart';
import 'package:moviemaster/domain/entities/user_entity.dart';
import 'package:moviemaster/domain/repositories/movie_repository.dart';
import 'package:moviemaster/domain/repositories/auth_repository.dart';
import 'package:moviemaster/domain/repositories/favorites_repository.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockMovieEntity extends Mock implements MovieEntity {}

class MockMovieDetailsEntity extends Mock implements MovieDetailsEntity {}

class MockUserEntity extends Mock implements UserEntity {}

class MockMovieModel extends Mock implements MovieModel {}
class MockVideoModel extends Mock implements VideoModel {}
class MockCreditModel extends Mock implements CreditModel {}
class MockReviewModel extends Mock implements ReviewModel {}

void registerFallbackValues() {
  registerFallbackValue(
    MovieEntity(
      id: 0,
      title: 'fake title',
      overview: 'fake overview',
      posterPath: null,
      releaseDate: null,
      voteAverage: 0.0,
    ),
  );

  registerFallbackValue('fake query');

  registerFallbackValue(1);

  registerFallbackValue(1);
}

void registerAllFallbackValues() {
  registerFallbackValues();

  registerFallbackValue(MockMovieEntity());
  registerFallbackValue(MockMovieDetailsEntity());
  registerFallbackValue(MockUserEntity());
  registerFallbackValue(MockMovieModel());
  registerFallbackValue(MockVideoModel());
  registerFallbackValue(MockCreditModel());
  registerFallbackValue(MockReviewModel());
}