import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:moviemaster/presentation/blocs/movie_bloc/movie_bloc.dart';
import 'package:moviemaster/presentation/widgets/movie_card.dart';
import 'package:moviemaster/presentation/pages/favorites_page.dart';
import 'package:moviemaster/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:moviemaster/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:moviemaster/presentation/blocs/theme_bloc/theme_bloc.dart';
import 'package:moviemaster/presentation/widgets/search_bar.dart';
import 'package:moviemaster/presentation/widgets/theme_switch.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.read<FavoritesBloc>().add(
                LoadFavoritesEvent(userId: state.user.id),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'MovieMaster',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            const ThemeSwitch(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<MovieBloc>().add(const LoadPopularMovies());
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.movie), text: 'Фільми'),
              Tab(icon: Icon(Icons.favorite), text: 'Улюблені'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            MoviesTab(),
            FavoritesPage(),
          ],
        ),
      ),
    );
  }
}

class MoviesTab extends StatelessWidget {
  const MoviesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MovieSearchBar(
            onSearch: (query) {
              if (query.isNotEmpty) {
                context.read<MovieBloc>().add(SearchMoviesEvent(query));
              } else {
                context.read<MovieBloc>().add(const LoadPopularMovies());
              }
            },
          ),
        ),
        Expanded(
          child: BlocConsumer<MovieBloc, MovieState>(
            listener: (context, state) {
              if (state is MovieError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is MovieInitial) {
                context.read<MovieBloc>().add(const LoadPopularMovies());
                return _buildLoading();
              }

              if (state is MovieLoading) {
                return _buildLoading();
              }

              if (state is MovieSearching) {
                return _buildLoading();
              }

              if (state is MovieError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Помилка завантаження',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<MovieBloc>().add(const LoadPopularMovies());
                        },
                        child: const Text('Спробувати знову'),
                      ),
                    ],
                  ),
                );
              }

              if (state is MovieLoaded || state is MovieSearchLoaded) {
                final movies = state is MovieLoaded
                    ? state.movies
                    : (state as MovieSearchLoaded).movies;

                if (movies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          state is MovieSearchLoaded
                              ? 'Не знайдено фільмів за запитом "${state.query}"'
                              : 'Фільми не знайдені',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(movie: movie);
                  },
                );
              }

              return Container();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Завантаження фільмів...'),
        ],
      ),
    );
  }
}