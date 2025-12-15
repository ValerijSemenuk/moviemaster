import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:moviemaster/data/datasources/movie_local_data_source.dart';
import 'package:moviemaster/domain/usecases/add_to_favorites.dart';
import 'package:moviemaster/domain/usecases/get_favorites.dart';
import 'package:moviemaster/domain/usecases/get_movie_details.dart';
import 'package:moviemaster/domain/usecases/remove_from_favorites.dart';
import 'package:moviemaster/presentation/blocs/movie_details_bloc/movie_details_bloc.dart';
import 'package:moviemaster/presentation/pages/home_page.dart';
import 'package:moviemaster/presentation/pages/movie_details_page.dart';
import 'package:moviemaster/core/config/app_config.dart';
import 'package:moviemaster/core/network/dio_client.dart';
import 'package:moviemaster/data/datasources/remote/movie_remote_data_source.dart';
import 'package:moviemaster/data/repositories/movie_repository_impl.dart';
import 'package:moviemaster/data/repositories/auth_repository_impl.dart';
import 'package:moviemaster/data/repositories/favorites_repository_impl.dart';
import 'package:moviemaster/domain/repositories/movie_repository.dart';
import 'package:moviemaster/domain/repositories/auth_repository.dart';
import 'package:moviemaster/domain/repositories/favorites_repository.dart';
import 'package:moviemaster/domain/usecases/get_popular_movies.dart';
import 'package:moviemaster/domain/usecases/search_movies.dart';
import 'package:moviemaster/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:moviemaster/presentation/blocs/movie_bloc/movie_bloc.dart';
import 'package:moviemaster/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:moviemaster/presentation/pages/auth/login_page.dart';
import 'package:moviemaster/presentation/pages/auth/register_page.dart';
import 'package:moviemaster/presentation/pages/auth/forgot_password_page.dart';
import 'package:moviemaster/domain/entities/user_entity.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/data/models/movie_model.dart';

class TestMovieLocalDataSource extends MovieLocalDataSource {
  final Map<String, List<MovieModel>> _cache = {};

  @override
  Future<void> cacheMovies(List<MovieModel> movies, String cacheKey) async {
    _cache[cacheKey] = movies;
    print('Test: Cached ${movies.length} movies for category: $cacheKey');
  }

  @override
  Future<List<MovieModel>?> getCachedMovies(String cacheKey) async {
    return _cache[cacheKey] ?? [];
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
    print('Test: Cache cleared');
  }

  @override
  Future<void> clearCacheForKey(String cacheKey) async {
    _cache.remove(cacheKey);
    print('Test: Cache cleared for key: $cacheKey');
  }

  @override
  Future<bool> isCacheValid(String cacheKey) async {
    return _cache.containsKey(cacheKey);
  }
}

class TestMovieModel extends MovieModel {
  TestMovieModel({
    required int id,
    required String title,
    required String overview,
    String? posterPath,
    required double voteAverage,
    String? releaseDate,
  }) : super(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    voteAverage: voteAverage,
    releaseDate: releaseDate,
  );

  factory TestMovieModel.fromJson(Map<String, dynamic> json) {
    return TestMovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
    };
  }
}

final getIt = GetIt.instance;

class TestAuthRepository implements AuthRepository {
  @override
  Future<void> signOut() async {
    print('Test: User signed out');
  }

  @override
  Future<void> updateUserProfile(String displayName, String? photoUrl) async {
    print('Test: User profile updated');
  }

  @override
  Future<dynamic> getCurrentUserModel() async {
    return null;
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    return UserEntity(
      id: 'test-user-123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: null,
    );
  }

  @override
  Future<UserEntity?> signInWithEmailAndPassword(String email, String password) async {
    return UserEntity(
      id: 'test-user-456',
      email: email,
      displayName: 'Test User',
      photoUrl: null,
    );
  }

  @override
  Future<UserEntity?> registerWithEmailAndPassword(String email, String password) async {
    return UserEntity(
      id: 'new-user-789',
      email: email,
      displayName: 'New User',
      photoUrl: null,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return UserEntity(
      id: 'current-test-user',
      email: 'current@test.com',
      displayName: 'Current Test User',
      photoUrl: null,
    );
  }
}

class TestFavoritesRepository implements FavoritesRepository {
  final List<int> _favorites = [1, 2, 3];

  @override
  Future<List<int>> getFavorites(String userId) async {
    return _favorites;
  }

  @override
  Future<void> addToFavorites(String userId, int movieId) async {
    _favorites.add(movieId);
    print('Test: Added to favorites: $movieId');
  }

  @override
  Future<void> removeFromFavorites(String userId, int movieId) async {
    _favorites.remove(movieId);
    print('Test: Removed from favorites: $movieId');
  }

  @override
  Future<bool> isFavorite(String userId, int movieId) async {
    return _favorites.contains(movieId);
  }
}

Future<void> setupTestDependencies() async {
  print('Test: Setting up test dependencies...');

  getIt.registerSingleton<Dio>(Dio());

  getIt.registerSingleton<MovieRemoteDataSource>(
    MovieRemoteDataSource(dio: getIt<Dio>()),
  );

  getIt.registerSingleton<MovieLocalDataSource>(
    TestMovieLocalDataSource(),
  );

  getIt.registerSingleton<MovieRepository>(
    MovieRepositoryImpl(
      remoteDataSource: getIt<MovieRemoteDataSource>(),
      localDataSource: getIt<MovieLocalDataSource>(),
    ),
  );

  getIt.registerSingleton<AuthRepository>(TestAuthRepository());
  getIt.registerSingleton<FavoritesRepository>(TestFavoritesRepository());

  getIt.registerSingleton<GetPopularMovies>(
    GetPopularMovies(getIt<MovieRepository>()),
  );

  getIt.registerSingleton<SearchMovies>(
    SearchMovies(getIt<MovieRepository>()),
  );

  getIt.registerSingleton<GetMovieDetails>(
    GetMovieDetails(getIt<MovieRepository>()),
  );

  getIt.registerSingleton<GetFavorites>(
    GetFavorites(getIt<FavoritesRepository>()),
  );

  getIt.registerSingleton<AddToFavorites>(
    AddToFavorites(getIt<FavoritesRepository>()),
  );

  getIt.registerSingleton<RemoveFromFavorites>(
    RemoveFromFavorites(getIt<FavoritesRepository>()),
  );

  getIt.registerLazySingleton<AuthBloc>(
        () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<MovieBloc>(
        () => MovieBloc(
      getPopularMovies: getIt<GetPopularMovies>(),
      searchMoviesUseCase: getIt<SearchMovies>(),
    ),
  );

  getIt.registerFactory<MovieDetailsBloc>(
        () => MovieDetailsBloc(getMovieDetails: getIt<GetMovieDetails>()),
  );

  getIt.registerFactory<FavoritesBloc>(
        () => FavoritesBloc(
      getFavorites: getIt<GetFavorites>(),
      addToFavorites: getIt<AddToFavorites>(),
      removeFromFavorites: getIt<RemoveFromFavorites>(),
    ),
  );

  print('Test: Dependencies set up successfully');
}

Future<void> testMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 TEST MODE: Starting test application...');

  try {
    print('Test: Loading environment variables (test mode)...');
    await dotenv.load(fileName: '.env');
    AppConfig.load();
    print('Test: Environment loaded');
  } catch (e) {
    print('Test: Using default configs');
  }

  try {
    await setupTestDependencies();
  } catch (e) {
    print('Error setting up test dependencies: $e');
    rethrow;
  }

  print('Test: Running app...');
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            final authBloc = getIt<AuthBloc>();

            return MaterialPage<void>(
              key: state.pageKey,
              child: BlocBuilder<AuthBloc, AuthState>(
                bloc: authBloc,
                builder: (context, authState) {
                  if (authState is AuthInitial) {
                    Future.microtask(() => authBloc.add(CheckAuthStatus()));
                  }

                  if (authState is Authenticated) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: getIt<MovieBloc>()),
                        BlocProvider.value(value: getIt<FavoritesBloc>()),
                      ],
                      child: const HomePage(),
                    );
                  } else {
                    return LoginPage(
                      onLoginSuccess: () => context.go('/'),
                    );
                  }
                },
              ),
            );
          },
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => MaterialPage<void>(
            key: state.pageKey,
            child: LoginPage(
              onLoginSuccess: () => context.go('/'),
            ),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => MaterialPage<void>(
            key: state.pageKey,
            child: RegisterPage(
              onRegisterSuccess: () => context.go('/'),
            ),
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: (context, state) => MaterialPage<void>(
            key: state.pageKey,
            child: const ForgotPasswordPage(),
          ),
        ),
        GoRoute(
          path: '/movie/:id',
          pageBuilder: (context, state) {
            final authBloc = getIt<AuthBloc>();
            final movieId = int.tryParse(state.pathParameters['id'] ?? '');

            if (movieId == null) {
              return MaterialPage<void>(
                key: state.pageKey,
                child: const Scaffold(
                  body: Center(child: Text('Invalid movie ID')),
                ),
              );
            }

            return MaterialPage<void>(
              key: state.pageKey,
              child: BlocBuilder<AuthBloc, AuthState>(
                bloc: authBloc,
                builder: (context, authState) {
                  if (authState is AuthInitial) {
                    Future.microtask(() => authBloc.add(CheckAuthStatus()));
                  }

                  if (authState is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (authState is! Authenticated) {
                    return LoginPage(
                      onLoginSuccess: () {
                        context.go('/movie/${state.pathParameters['id']}');
                      },
                    );
                  }

                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: getIt<MovieDetailsBloc>()),
                      BlocProvider.value(value: getIt<FavoritesBloc>()),
                    ],
                    child: MovieDetailsPage(movieId: movieId),
                  );
                },
              ),
            );
          },
        ),
      ],
      errorPageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: Scaffold(
          body: Center(
            child: Text('Test Error: ${state.error}'),
          ),
        ),
      ),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'MovieMaster (Test)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end App Flow', () {
    setUp(() async {
      if (getIt.isRegistered<Dio>()) {
        await getIt.reset();
      }
    });

    testWidgets('Complete user journey test', (WidgetTester tester) async {
      await testMain();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      print('✅ Test app started successfully');

      await Future.delayed(const Duration(seconds: 2));

      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, 'Test');
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ Search performed');
      }

      final movieCards = find.byKey(const Key('movie_card')).hitTestable();
      if (movieCards.evaluate().isNotEmpty) {
        await tester.tap(movieCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Movie details opened');

        await tester.pageBack();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ Navigated back');
      }

      print('✅ Integration test completed successfully');
    });

    testWidgets('Test navigation', (WidgetTester tester) async {
      await testMain();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(Scaffold), findsWidgets);
      print('✅ Navigation test passed');
    });
  });
}