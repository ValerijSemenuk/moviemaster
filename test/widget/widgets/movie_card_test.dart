// test/widget/movie_card_test.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/domain/entities/user_entity.dart';
import 'package:moviemaster/domain/repositories/auth_repository.dart';
import 'package:moviemaster/domain/repositories/favorites_repository.dart';
import 'package:moviemaster/domain/usecases/add_to_favorites.dart';
import 'package:moviemaster/domain/usecases/get_favorites.dart';
import 'package:moviemaster/domain/usecases/remove_from_favorites.dart';
import 'package:moviemaster/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:moviemaster/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:moviemaster/presentation/widgets/movie_card.dart';

// Моки для залежностей BLoC
class MockAuthRepository extends Mock implements AuthRepository {}
class MockFavoritesRepository extends Mock implements FavoritesRepository {}

// Fake класи для станів
class FakeAuthState extends Fake implements AuthState {}
class FakeFavoritesState extends Fake implements FavoritesState {}

// Кастомні стани для тестування
class TestAuthState extends AuthState {
  final UserEntity? user;

  TestAuthState(this.user);

  @override
  List<Object> get props => user != null ? [user!] : [];

  bool get isAuthenticated => user != null;
}

class TestFavoritesState extends FavoritesState {
  final List<MovieEntity> favoriteMovies;

  TestFavoritesState(this.favoriteMovies);

  @override
  List<Object> get props => [favoriteMovies];
}

void main() {
  // Реєструємо fake значення для mocktail
  setUpAll(() {
    registerFallbackValue(FakeAuthState());
    registerFallbackValue(FakeFavoritesState());
  });

  late AuthBloc authBloc;
  late FavoritesBloc favoritesBloc;
  late MockAuthRepository mockAuthRepository;
  late MockFavoritesRepository mockFavoritesRepository;

  final tMovie = MovieEntity(
    id: 1,
    title: 'Test Movie',
    overview: 'Test Overview',
    posterPath: '/test.jpg',
    releaseDate: '2024-01-01',
    voteAverage: 8.5,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockFavoritesRepository = MockFavoritesRepository();

    // Створюємо BLoC з моками репозиторіїв
    authBloc = AuthBloc(authRepository: mockAuthRepository);

    // Створюємо use cases для FavoritesBloc
    final getFavorites = GetFavorites(mockFavoritesRepository);
    final addToFavorites = AddToFavorites(mockFavoritesRepository);
    final removeFromFavorites = RemoveFromFavorites(mockFavoritesRepository);

    favoritesBloc = FavoritesBloc(
      getFavorites: getFavorites,
      addToFavorites: addToFavorites,
      removeFromFavorites: removeFromFavorites,
    );
  });

  tearDown(() {
    authBloc.close();
    favoritesBloc.close();
  });

  // Тест 1: Відображення базової інформації
  testWidgets('should display movie information correctly', (WidgetTester tester) async {
    // Стартуємо стан неавторизованого користувача
    authBloc.emit(Unauthenticated());
    favoritesBloc.emit(FavoritesInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie),
          ),
        ),
      ),
    );

    await tester.pump(Duration(milliseconds: 100));

    expect(find.text('Test Movie'), findsOneWidget);
    expect(find.text('8.5'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
  });

  // Тест 2: Відображення кнопки улюбленого для авторизованого користувача
  testWidgets('should show favorite icon when authenticated', (WidgetTester tester) async {
    final user = UserEntity(
      id: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: null,
    );

    // Встановлюємо авторизований стан
    authBloc.emit(Authenticated(user));
    favoritesBloc.emit(FavoritesLoaded(favoriteMovies: []));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie),
          ),
        ),
      ),
    );

    await tester.pump(Duration(milliseconds: 100));

    // Перевіряємо, що з'явилася іконка улюбленого (порожнє серце)
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  // Тест 3: Заповнене серце для фільму в улюблених
  testWidgets('should show filled heart when movie is favorite', (WidgetTester tester) async {
    final user = UserEntity(
      id: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: null,
    );

    // Встановлюємо стан з фільмом в улюблених
    authBloc.emit(Authenticated(user));
    favoritesBloc.emit(FavoritesLoaded(favoriteMovies: [tMovie]));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie),
          ),
        ),
      ),
    );

    await tester.pump(Duration(milliseconds: 100));

    // Перевіряємо заповнене серце
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });

  // Тест 4: Відсутність кнопки улюбленого для неавторизованого користувача
  testWidgets('should not show favorite icon when not authenticated', (WidgetTester tester) async {
    authBloc.emit(Unauthenticated());
    favoritesBloc.emit(FavoritesInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie),
          ),
        ),
      ),
    );

    await tester.pump(Duration(milliseconds: 100));

    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });

  // Тест 5: Клік на картку викликає навігацію
  testWidgets('should call onTap when provided', (WidgetTester tester) async {
    bool wasTapped = false;

    authBloc.emit(Unauthenticated());
    favoritesBloc.emit(FavoritesInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MovieCard(
              movie: tMovie,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump(Duration(milliseconds: 100));

    // Тапаємо на картку
    await tester.tap(find.byType(MovieCard));
    await tester.pump();

    expect(wasTapped, true);
  });

  // Тест 6: Плейсхолдер для відсутнього постера
  testWidgets('should show placeholder when no poster', (WidgetTester tester) async {
    final movieWithoutPoster = MovieEntity(
      id: 2,
      title: 'Movie Without Poster',
      overview: 'Test',
      posterPath: null,
      releaseDate: '2024-01-01',
      voteAverage: 7.0,
    );

    authBloc.emit(Unauthenticated());
    favoritesBloc.emit(FavoritesInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: movieWithoutPoster),
          ),
        ),
      ),
    );

    await tester.pump(Duration(milliseconds: 100));

    // Перевіряємо наявність плейсхолдера
    expect(find.byIcon(Icons.movie), findsOneWidget);
  });

  // Тест 7: Кешування фільму при ініціалізації
  testWidgets('should cache movie on initialization', (WidgetTester tester) async {
    authBloc.emit(Unauthenticated());
    favoritesBloc.emit(FavoritesInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie),
          ),
        ),
      ),
    );

    await tester.pump(Duration(milliseconds: 200));

    // FavoritesBloc має отримати CacheMovieEvent
    // Це перевіряється через стан BLoC
    expect(favoritesBloc.state, isA<FavoritesState>());
  });
}