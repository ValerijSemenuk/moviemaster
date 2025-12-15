import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/usecases/get_favorites.dart';
import 'package:moviemaster/domain/usecases/add_to_favorites.dart';
import 'package:moviemaster/domain/usecases/remove_from_favorites.dart';
import 'package:moviemaster/presentation/blocs/favorites_bloc/favorites_bloc.dart';

import '../../mocks/mock_repositories.dart';
import '../../mocks/mock_usecases.dart';


void main() {
  late MockGetFavorites mockGetFavorites;
  late MockAddToFavorites mockAddToFavorites;
  late MockRemoveFromFavorites mockRemoveFromFavorites;
  late FavoritesBloc favoritesBloc;

  const tUserId = 'user123';
  final tFavoriteIds = [1, 2, 3];
  final tMovies = [
    MovieEntity(
      id: 1,
      title: 'Favorite Movie 1',
      overview: 'Overview 1',
      posterPath: '/test1.jpg',
      releaseDate: '2024-01-01',
      voteAverage: 8.5,
    ),
    MovieEntity(
      id: 2,
      title: 'Favorite Movie 2',
      overview: 'Overview 2',
      posterPath: '/test2.jpg',
      releaseDate: '2024-02-01',
      voteAverage: 7.8,
    ),
  ];

  setUpAll(() {
    registerAllFallbackValues();
  });

  setUp(() {
    mockGetFavorites = MockGetFavorites();
    mockAddToFavorites = MockAddToFavorites();
    mockRemoveFromFavorites = MockRemoveFromFavorites();

    favoritesBloc = FavoritesBloc(
      getFavorites: mockGetFavorites,
      addToFavorites: mockAddToFavorites,
      removeFromFavorites: mockRemoveFromFavorites,
    );
  });

  tearDown(() {
    favoritesBloc.close();
  });

  group('LoadFavoritesEvent', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesLoading, FavoritesLoaded] when successful',
      build: () {
        when(() => mockGetFavorites(any()))
            .thenAnswer((_) async => tFavoriteIds);
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(const LoadFavoritesEvent(userId: tUserId)),
      expect: () => [
        FavoritesLoading(),
        // Використовуємо isA замість any()
        isA<FavoritesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetFavorites(tUserId)).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should emit [FavoritesLoading, FavoritesError] when fails',
      build: () {
        when(() => mockGetFavorites(any()))
            .thenThrow(Exception('Failed'));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(const LoadFavoritesEvent(userId: tUserId)),
      expect: () => [
        FavoritesLoading(),
        const FavoritesError('Помилка завантаження улюблених: Exception: Failed'),
      ],
    );
  });

  group('ToggleFavoriteEvent - додавання до улюблених', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should add to favorites when movie is not in favorites',
      build: () {
        when(() => mockGetFavorites(any()))
            .thenAnswer((_) async => [1, 2]);
        when(() => mockAddToFavorites(any(), any()))
            .thenAnswer((_) async {});
        return favoritesBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadFavoritesEvent(userId: tUserId));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const ToggleFavoriteEvent(userId: tUserId, movieId: 3));
      },
      expect: () => [
        FavoritesLoading(),
        isA<FavoritesLoaded>(),
        isA<FavoritesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetFavorites(tUserId)).called(1);
        verify(() => mockAddToFavorites(tUserId, 3)).called(1);
      },
    );
  });

  group('ToggleFavoriteEvent - видалення з улюблених', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should remove from favorites when movie is already in favorites',
      build: () {
        when(() => mockGetFavorites(any()))
            .thenAnswer((_) async => [1, 2, 3]);
        when(() => mockRemoveFromFavorites(any(), any()))
            .thenAnswer((_) async {});
        return favoritesBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadFavoritesEvent(userId: tUserId));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const ToggleFavoriteEvent(userId: tUserId, movieId: 3));
      },
      expect: () => [
        FavoritesLoading(),
        isA<FavoritesLoaded>(),
        isA<FavoritesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetFavorites(tUserId)).called(1);
        verify(() => mockRemoveFromFavorites(tUserId, 3)).called(1);
      },
    );
  });

  group('CacheMovieEvent', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should cache movie without changing state',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(CacheMovieEvent(movie: tMovies[0])),
      expect: () => [],
    );
  });

  group('isFavorite method', () {
    test('should return true when movie is in favorites', () {
      final bloc = FavoritesBloc(
        getFavorites: mockGetFavorites,
        addToFavorites: mockAddToFavorites,
        removeFromFavorites: mockRemoveFromFavorites,
      );

      bloc.emit(FavoritesLoaded(favoriteMovies: tMovies));

      expect(bloc.isFavorite(1), true);
      expect(bloc.isFavorite(3), false);

      bloc.close();
    });

    test('should return false when state is not FavoritesLoaded', () {
      final bloc = FavoritesBloc(
        getFavorites: mockGetFavorites,
        addToFavorites: mockAddToFavorites,
        removeFromFavorites: mockRemoveFromFavorites,
      );

      bloc.emit(FavoritesInitial());
      expect(bloc.isFavorite(1), false);

      bloc.emit(FavoritesLoading());
      expect(bloc.isFavorite(1), false);

      bloc.close();
    });
  });
}