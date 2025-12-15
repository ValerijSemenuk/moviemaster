import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:moviemaster/domain/entities/movie_entity.dart';
import 'package:moviemaster/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:moviemaster/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:moviemaster/presentation/widgets/movie_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Увійдіть, щоб переглядати улюблені фільми',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('Увійти'),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, favoritesState) {
            if (favoritesState is FavoritesLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Завантаження улюблених фільмів...'),
                  ],
                ),
              );
            }

            if (favoritesState is FavoritesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Помилка завантаження',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      favoritesState.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FavoritesBloc>().add(
                          LoadFavoritesEvent(userId: authState.user.id),
                        );
                      },
                      child: const Text('Спробувати знову'),
                    ),
                  ],
                ),
              );
            }

            if (favoritesState is FavoritesLoaded) {
              if (favoritesState.favoriteMovies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'У вас ще немає улюблених фільмів',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Додавайте фільми, натискаючи на сердечко',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
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
                itemCount: favoritesState.favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoritesState.favoriteMovies[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () {
                      context.go('/movie/${movie.id}');
                    },
                  );
                },
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<FavoritesBloc>().add(
                LoadFavoritesEvent(userId: authState.user.id),
              );
            });

            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Завантаження...'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}