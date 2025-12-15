import 'package:flutter_test/flutter_test.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/entities/user_entity.dart';


MovieEntity createTestMovie({
  int id = 1,
  String title = 'Test Movie',
  String overview = 'Test Overview',
  String? posterPath = '/test.jpg',
  double voteAverage = 8.5,
  String? releaseDate = '2024-01-01',
}) {
  return MovieEntity(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    voteAverage: voteAverage,
    releaseDate: releaseDate,
  );
}

UserEntity createTestUser({
  String id = '123',
  String email = 'test@example.com',
  String? displayName = 'Test User',
  String? photoUrl,
}) {
  return UserEntity(
    id: id,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
  );
}