import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moviemaster/presentation/blocs/movie_details_bloc/movie_details_bloc.dart';
import 'package:moviemaster/presentation/pages/home_page.dart';
import 'package:moviemaster/presentation/pages/movie_details_page.dart';
import 'data/datasources/movie_local_data_source.dart';
import 'domain/usecases/add_to_favorites.dart';
import 'domain/usecases/get_favorites.dart';
import 'domain/usecases/get_movie_details.dart';
import 'domain/usecases/remove_from_favorites.dart';
import 'firebase_options.dart';
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

final getIt = GetIt.instance;

Future<void> setupDependencies(bool isTestEnvironment) async {
  getIt.registerSingleton<Dio>(DioClient().dio);
  getIt.registerSingleton<MovieRemoteDataSource>(
    MovieRemoteDataSource(dio: getIt<Dio>()),
  );
  getIt.registerSingleton<MovieLocalDataSource>(
    MovieLocalDataSource(),
  );
  getIt.registerSingleton<MovieRepository>(
    MovieRepositoryImpl(
      remoteDataSource: getIt<MovieRemoteDataSource>(),
      localDataSource: getIt<MovieLocalDataSource>(),
    ),
  );

  if (isTestEnvironment) {
    getIt.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(
        firebaseAuth: null,
        googleSignIn: null,
        firestore: null,
      ),
    );
  } else {
    getIt.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(),
    );
  }

  getIt.registerSingleton<FavoritesRepository>(
    FavoritesRepositoryImpl(),
  );
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
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isTestEnvironment = false;

  try {
    const flutterTest = String.fromEnvironment('FLUTTER_TEST');
    if (flutterTest == 'true') {
      isTestEnvironment = true;
    }

    const integrationTest = bool.fromEnvironment('INTEGRATION_TEST');
    if (integrationTest) {
      isTestEnvironment = true;
    }
  } catch (e) {
    // Ігноруємо помилки читання змінних середовища
  }

  if (!isTestEnvironment) {
    print('Початок ініціалізації додатка...');

    try {
      print('Ініціалізація Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase успішно ініціалізовано');
    } catch (e) {
      print('Помилка ініціалізації Firebase: $e');
    }

    try {
      print('Ініціалізація Hive...');
      await Hive.initFlutter();
      print('Hive успішно ініціалізовано');
      await Hive.close();

      print('Видалення старих боксів...');
      try {
        await Hive.deleteBoxFromDisk('movies_cache');
        print('Бокс movies_cache видалено');
      } catch (e) {
        print('Бокс movies_cache не існував або не може бути видалений: $e');
      }

      try {
        await Hive.deleteBoxFromDisk('favorites');
        print('Бокс favorites видалено');
      } catch (e) {
        print('Бокс favorites не існував або не може бути видалений: $e');
      }

      print('Відкриття боксів...');
      final moviesBox = await Hive.openBox<String>('movies_cache');
      print('Бокс movies_cache успішно відкрито як Box<String>');

      final favoritesBox = await Hive.openBox('favorites');
      print('Бокс favorites успішно відкрито');
    } catch (e) {
      print('Помилка при роботі з Hive: $e');
      rethrow;
    }
  } else {
    print('ТЕСТОВИЙ РЕЖИМ: пропускаємо Firebase та Hive');

    try {
      Hive.init(null);
      await Hive.openBox<String>('movies_cache');
      await Hive.openBox('favorites');
    } catch (e) {
      print('Помилка ініціалізації Hive в тестовому режимі: $e');
    }
  }

  try {
    print('Завантаження змінних середовища...');
    await dotenv.load(fileName: '.env');
    AppConfig.load();
    print('Змінні середовища успішно завантажені');
  } catch (e) {
    print('Помилка завантаження змінних середовища: $e');
  }

  try {
    print('Налаштування залежностей...');
    await setupDependencies(isTestEnvironment);
    print('Залежності успішно налаштовані');
  } catch (e) {
    print('Помилка налаштування залежностей: $e');
    rethrow;
  }

  print('Запуск додатка...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                  body: Center(child: Text('Невірний ID фільму')),
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
          appBar: AppBar(title: const Text('Помилка')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Помилка: ${state.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('На головну'),
                ),
              ],
            ),
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
        title: 'MovieMaster',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.dark,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade800,
          ),
        ),
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}